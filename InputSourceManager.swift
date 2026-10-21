import Cocoa
import Foundation
import Carbon

class InputSource: Equatable {
    static func == (
        lhs: InputSource,
        rhs: InputSource
    ) -> Bool {
        return lhs.id == rhs.id
    }

    let tisInputSource: TISInputSource

    var id: String {
        return tisInputSource.id
    }

    var isCJKV: Bool {
        if let lang = tisInputSource.sourceLanguages.first {
            return lang == "ko" ||
                   lang == "ja" ||
                   lang == "vi" ||
                   lang.hasPrefix("zh")
        }
        return false
    }

    init(tisInputSource: TISInputSource) {
        self.tisInputSource = tisInputSource
    }

    func select() {
        // Before the already-selected check: after a broken switch the menu
        // bar shows this source while the focused app still types latin.
        if self.isCJKV && InputSourceManager.useTSM &&
            selectInFocusedApp(tisInputSource) {
            return
        }

        let currentSource = InputSourceManager.getCurrentSource()
        if currentSource.id == self.id {
            return
        }

        TISSelectInputSource(tisInputSource)

        // fcitx and non-CJKV don't need special treat
        if !self.isCJKV {
            return
        }

        showTemporaryInputWindow(
          waitTimeMs: InputSourceManager.waitTimeMs
        )
    }
}

class InputSourceManager {
    static var inputSources: [InputSource] = []
    static var waitTimeMs: Int = -1  // less than 0 means using default
    static var useTSM = true
    static var level: Int = 1

    static func initialize() {
        let inputSourceList = TISCreateInputSourceList(
            nil, false
        ).takeRetainedValue() as! [TISInputSource]

        inputSources = inputSourceList
            .filter {
                $0.isSelectable
            }
            .map { InputSource(tisInputSource: $0) }
    }

    static func getCurrentSource() -> InputSource {
        return InputSource(
            tisInputSource:
                TISCopyCurrentKeyboardInputSource()
                .takeRetainedValue()
        )
    }

    static func getInputSource(name: String) -> InputSource? {
        return inputSources.first { $0.id == name }
    }
}

extension TISInputSource {
    enum Category {
        static var keyboardInputSource: String {
            return kTISCategoryKeyboardInputSource as String
        }
    }

    private func getProperty(_ key: CFString) -> AnyObject? {
        if let cfType = TISGetInputSourceProperty(self, key) {
            return Unmanaged<AnyObject>
                .fromOpaque(cfType)
                .takeUnretainedValue()
        }
        return nil
    }

    var id: String {
        return getProperty(kTISPropertyInputSourceID) as! String
    }

    var category: String {
        return getProperty(kTISPropertyInputSourceCategory) as! String
    }

    var isSelectable: Bool {
        return getProperty(
            kTISPropertyInputSourceIsSelectCapable
        ) as! Bool
    }

    var sourceLanguages: [String] {
        return getProperty(kTISPropertyInputSourceLanguages) as! [String]
    }
}
