import Cocoa
import Carbon

// `macism --serve` stays running so that a query or switch skips the setup a
// fresh process pays for: the first TIS call, TISCreateInputSourceList and the
// window server connection. `macism` hands its request to the server; when none
// answers, it starts one and does this request itself.
//
// Requests are JSON datagrams on a Unix socket, the format Karabiner-Elements'
// send_user_command sends. Only senders with a bound address get a reply.
//   {"select": "<input source ID>"}  "ok", "fallback" or an error message
//   {"current": true}                the current input source ID
// "fallback": the focused app couldn't be asked to switch. The client then runs
// the TemporaryWindow workaround itself, since showing the window ends the
// process.

let serverSocketPath = NSHomeDirectory() + "/.local/state/macism/sock"

private func unixAddress(_ path: String) -> sockaddr_un? {
    var address = sockaddr_un()
    address.sun_family = sa_family_t(AF_UNIX)
    let bytes = Array(path.utf8)
    guard bytes.count < MemoryLayout.size(ofValue: address.sun_path) else {
        return nil
    }
    withUnsafeMutableBytes(of: &address.sun_path) { $0.copyBytes(from: bytes) }
    return address
}

private func withSockaddr<T>(
    _ address: inout sockaddr_un,
    _ body: (UnsafePointer<sockaddr>, socklen_t) -> T
) -> T {
    return withUnsafePointer(to: &address) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            body($0, socklen_t(MemoryLayout<sockaddr_un>.size))
        }
    }
}

// MARK: client

// In its own session and without the caller's descriptors, so that it outlives
// this process and the caller doesn't wait for it to close a pipe.
private func startServer() {
    guard let path = Bundle.main.executablePath else { return }
    var attributes: posix_spawnattr_t?
    posix_spawnattr_init(&attributes)
    defer { posix_spawnattr_destroy(&attributes) }
    posix_spawnattr_setflags(
        &attributes, Int16(POSIX_SPAWN_SETSID | POSIX_SPAWN_CLOEXEC_DEFAULT)
    )
    var files: posix_spawn_file_actions_t?
    posix_spawn_file_actions_init(&files)
    defer { posix_spawn_file_actions_destroy(&files) }
    for fd: Int32 in 0...2 {
        posix_spawn_file_actions_addopen(&files, fd, "/dev/null", O_RDWR, 0)
    }
    let argv = [strdup(path), strdup("--serve"), nil]
    defer { argv.forEach { free($0) } }
    var pid: pid_t = 0
    posix_spawn(&pid, path, &files, &attributes, argv, environ)
}

// The server's reply, or nil when no server answers.
private func askServer(_ request: [String: Any]) -> String? {
    guard var server = unixAddress(serverSocketPath),
          let data = try? JSONSerialization.data(withJSONObject: request)
    else { return nil }
    let clientPath = NSTemporaryDirectory() + "macism-\(getpid())"
    guard var client = unixAddress(clientPath) else { return nil }
    let fd = socket(AF_UNIX, SOCK_DGRAM, 0)
    guard fd >= 0 else { return nil }
    defer { close(fd) }
    unlink(clientPath)
    guard withSockaddr(&client, { bind(fd, $0, $1) }) == 0 else { return nil }
    defer { unlink(clientPath) }
    // Longer than the server's own bound on asking the focused app.
    var timeout = timeval(tv_sec: 1, tv_usec: 0)
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout,
               socklen_t(MemoryLayout<timeval>.size))
    let sent = data.withUnsafeBytes { bytes in
        withSockaddr(&server) {
            sendto(fd, bytes.baseAddress, bytes.count, 0, $0, $1)
        }
    }
    guard sent == data.count else {
        startServer()
        return nil
    }
    var buffer = [UInt8](repeating: 0, count: 1024)
    let count = recv(fd, &buffer, buffer.count, 0)
    guard count > 0 else { return nil }
    return String(decoding: buffer[0..<count], as: UTF8.self)
}

// Hands a query or a switch to a running server. Returns false when the caller
// should do the work itself.
func forwardToServer(_ arguments: [String]) -> Bool {
    if arguments.count == 1 {
        guard let id = askServer(["current": true]) else { return false }
        print(id)
        return true
    }
    let names = arguments.dropFirst().filter { !$0.hasPrefix("--") }
    guard !arguments.contains("--no-tsm"), names.count == 1 || names.count == 2
    else { return false }
    switch askServer(["select": names[0]]) {
    case nil:
        return false
    case "ok"?:
        return true
    case "fallback"?:
        // The server has already asked the focused app.
        InputSourceManager.useTSM = false
        return false
    case let message?:
        print(message)
        return true
    }
}

// MARK: server

private func handle(_ request: [String: Any]?, canReply: Bool) -> String {
    if request?["current"] as? Bool == true {
        return InputSourceManager.getCurrentSource().id
    }
    guard let id = request?["select"] as? String else {
        return "Expected {\"select\": \"<input source ID>\"} or {\"current\": true}"
    }
    if InputSourceManager.getInputSource(name: id) == nil {
        InputSourceManager.initialize()
    }
    guard let source = InputSourceManager.getInputSource(name: id) else {
        return "Input source \(id) does not exist!"
    }
    if source.isCJKV {
        if selectInFocusedApp(source.tisInputSource) { return "ok" }
        if canReply { return "fallback" }
    }
    if InputSourceManager.getCurrentSource() != source {
        TISSelectInputSource(source.tisInputSource)
    }
    return "ok"
}

func serve() -> Never {
    // CPSGetKeyFocusProcess needs a connection to the window server.
    _ = NSApplication.shared
    NSApp.setActivationPolicy(.prohibited)
    InputSourceManager.initialize()
    DistributedNotificationCenter.default().addObserver(
        forName: NSNotification.Name(
            kTISNotifyEnabledKeyboardInputSourcesChanged as String
        ),
        object: nil, queue: .main
    ) { _ in InputSourceManager.initialize() }

    guard var address = unixAddress(serverSocketPath) else {
        print("Socket path too long: \(serverSocketPath)")
        exit(1)
    }
    let directory = (serverSocketPath as NSString).deletingLastPathComponent
    try? FileManager.default.createDirectory(
        atPath: directory, withIntermediateDirectories: true
    )
    // Clients that find no server each start one, so several may race here.
    let lock = open(directory + "/lock", O_CREAT | O_RDWR, 0o600)
    guard lock >= 0, flock(lock, LOCK_EX | LOCK_NB) == 0 else {
        print("Already serving on \(serverSocketPath)")
        exit(1)
    }
    // Left over from a server that exited.
    unlink(serverSocketPath)
    let server = socket(AF_UNIX, SOCK_DGRAM, 0)
    guard withSockaddr(&address, { bind(server, $0, $1) }) == 0 else {
        print("Cannot listen on \(serverSocketPath): " +
              String(cString: strerror(errno)))
        exit(1)
    }
    chmod(serverSocketPath, 0o600)
    print("Serving on \(serverSocketPath)")
    fflush(stdout)

    // On the main queue, where TIS and TSM expect to be called.
    let reader = DispatchSource.makeReadSource(
        fileDescriptor: server, queue: .main
    )
    reader.setEventHandler {
        var buffer = [UInt8](repeating: 0, count: 4096)
        var sender = sockaddr_un()
        var senderLength = socklen_t(MemoryLayout<sockaddr_un>.size)
        let count = withUnsafeMutablePointer(to: &sender) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                recvfrom(server, &buffer, buffer.count, 0, $0, &senderLength)
            }
        }
        guard count > 0 else { return }
        let request = try? JSONSerialization.jsonObject(
            with: Data(buffer[0..<count])
        ) as? [String: Any]
        let canReply = sender.sun_path.0 != 0
        let reply = handle(request, canReply: canReply)
        if canReply {
            _ = withSockaddr(&sender) {
                sendto(server, reply, reply.utf8.count, 0, $0, $1)
            }
        }
    }
    reader.resume()

    // Exit when an upgrade or uninstall replaces or removes the executable, so
    // that the next call starts the new one.
    var watcher: DispatchSourceFileSystemObject?
    if let path = Bundle.main.executablePath {
        let executable = open(path, O_EVTONLY)
        if executable >= 0 {
            watcher = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: executable,
                eventMask: [.delete, .rename, .write], queue: .main
            )
            watcher?.setEventHandler { exit(0) }
            watcher?.resume()
        }
    }

    withExtendedLifetime((reader, watcher)) { NSApp.run() }
    exit(0)
}
