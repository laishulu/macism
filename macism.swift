import Foundation

@main
struct MacISM {
    static func main() {
        if CommandLine.arguments.contains(where: { arg in
            arg.caseInsensitiveCompare("--version") == .orderedSame
        }) {
            print("v3.0.11")
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

            // Set wait time if provided
            if filteredArgs.count == 3, let waitTime = Int(filteredArgs[2]) {
                // ignore waitTime of none-zero
                if waitTime == 0 {
                    InputSourceManager.waitTimeMs = waitTime
                }
            }

            dstSource.select()
        }
    }
}
