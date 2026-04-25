//
//  KeyboardHandlingView.swift
//  BrowserSwitch
//

import AppKit
import SwiftUI

struct KeyboardHandlingView: NSViewRepresentable {
    let onKeyDown: (NSEvent) -> Bool

    func makeNSView(context: Context) -> KeyHandlingNSView {
        let view = KeyHandlingNSView()
        view.onKeyDown = onKeyDown
        return view
    }

    func updateNSView(_ view: KeyHandlingNSView, context: Context) {
        view.onKeyDown = onKeyDown
    }
}

final class KeyHandlingNSView: NSView {
    var onKeyDown: ((NSEvent) -> Bool)?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }

            window?.makeFirstResponder(self)
        }
    }

    override func keyDown(with event: NSEvent) {
        if onKeyDown?(event) == true {
            return
        }

        super.keyDown(with: event)
    }
}
