import Foundation

@main
struct MacISM {
    static func main() {
        if CommandLine.arguments.contains(where: { arg in
            arg.caseInsensitiveCompare("--version") == .orderedSame
        }) {
            print("v3.1.1")
            return
        }

        // Initialize input sources
        InputSourceManager.initialize()

        if CommandLine.arguments.count == 1 {
            let currentSource = InputSourceManager.getCurrentSource()
            print(currentSource.id)
        } else {
            // Process command line arguments for flags
            let arguments = CommandLine.arguments

            // Filter out flag arguments to get the input source name
            let filteredArgs = arguments.filter { arg in
                !arg.hasPrefix("--")
            }

            if filteredArgs.count < 2 {
                print("No input source name provided!")
                return
            }

            guard let dstSource = InputSourceManager.getInputSource(
                name: filteredArgs[1]
            ) else {
                print("Input source \(filteredArgs[1]) does not exist!")
                return
            }

            // Set wait time if provided (any integer accepted).
            // 0  = skip the TemporaryWindow workaround entirely.
            // <0 = use built-in default (150ms).
            // >0 = wait that many milliseconds. Lower it (e.g. 50) to trade
            //      reliability for latency on older macOS where the CJK race
            //      is less likely.
            if filteredArgs.count == 3, let waitTime = Int(filteredArgs[2]) {
                InputSourceManager.waitTimeMs = waitTime
            }

            dstSource.select()
        }
    }
}
