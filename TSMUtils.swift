import Cocoa
import Carbon

// Select an input source the way the Input menu does: ask the app that has
// keyboard focus to switch, through its Text Services Manager port.
//
// TISSelectInputSource from a process without keyboard focus (like this CLI)
// commits the new source system-wide before sending the focused app this
// message (ID 7). A third-party input method is then activated and dropped a
// millisecond or two later: the menu bar shows the new source, typing stays
// latin. Without that early commit, as from the Input menu, the switch sticks.
//
// The symbols are private and resolved at run time. When one is missing or
// the request fails, selectInFocusedApp returns false and the caller falls
// back to TISSelectInputSource.

private let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)

private func sym<T>(_ name: String, _: T.Type) -> T? {
    return dlsym(rtldDefault, name).map { unsafeBitCast($0, to: T.self) }
}

private typealias KeyFocusFn = @convention(c) (
    UnsafeMutablePointer<ProcessSerialNumber>,
    UnsafeMutablePointer<DarwinBoolean>
) -> Int32
private typealias PSNToPIDFn = @convention(c) (
    UnsafePointer<ProcessSerialNumber>, UnsafeMutablePointer<pid_t>
) -> OSStatus
private typealias RemotePortFn = @convention(c) (
    CFAllocator?, CFString, pid_t
) -> Unmanaged<CFMessagePort>?
private typealias FlattenFn = @convention(c) (
    TISInputSource, UnsafeMutablePointer<Unmanaged<AnyObject>?>
) -> DarwinBoolean

// The process that receives key events, which is not always the frontmost
// app (a non-activating panel can have keyboard focus).
private func keyFocusPID() -> pid_t? {
    guard
        let keyFocus = sym("CPSGetKeyFocusProcess", KeyFocusFn.self),
        let psnToPID = sym("GetProcessPID", PSNToPIDFn.self)
    else { return nil }
    // CPSGetKeyFocusProcess needs a connection to the window server.
    _ = NSApplication.shared
    var psn = ProcessSerialNumber()
    var ignored: DarwinBoolean = false
    var pid: pid_t = -1
    guard keyFocus(&psn, &ignored) == 0,
          psnToPID(&psn, &pid) == noErr,
          pid > 0
    else { return nil }
    return pid
}

func selectInFocusedApp(_ source: TISInputSource) -> Bool {
    guard
        let remotePort = sym(
            "CFMessagePortCreatePerProcessRemote", RemotePortFn.self
        ),
        let flatten = sym("_CreateFlattenedInputSource", FlattenFn.self),
        let pid = keyFocusPID()
    else { return false }

    var flatRef: Unmanaged<AnyObject>?
    guard flatten(source, &flatRef).boolValue,
          let flat = flatRef?.takeRetainedValue()
    else { return false }
    let request = ["tsmInputSourceSelectedInpSrcKey": flat] as CFDictionary
    guard
        let data = CFPropertyListCreateData(
            nil, request, .xmlFormat_v1_0, 0, nil
        )?.takeRetainedValue(),
        let port = remotePort(
            nil, "com.apple.tsm.portname" as CFString, pid
        )?.takeRetainedValue()
    else { return false }

    // Synchronous, so the app has switched before we exit and the keys typed
    // next go to the new input method. Bounded in case the app hangs.
    var reply: Unmanaged<CFData>?
    let status = CFMessagePortSendRequest(
        port, 7, data, 0.3, 0.3, CFRunLoopMode.defaultMode.rawValue, &reply
    )
    guard status == kCFMessagePortSuccess else { return false }
    if let replyData = reply?.takeRetainedValue(),
       let dict = CFPropertyListCreateWithData(
           nil, replyData, 0, nil, nil
       )?.takeRetainedValue() as? [String: Any],
       let error = dict["tsmInputModeReplyToServerErrorKey"] as? Int,
       error != 0 {
        return false
    }
    return true
}
