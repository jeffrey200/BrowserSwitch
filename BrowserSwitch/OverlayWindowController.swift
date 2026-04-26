//
//  OverlayWindowController.swift
//  BrowserSwitch
//

import AppKit
import SwiftUI

final class OverlayWindowController {
    private enum Layout {
        static let panelSize = NSSize(width: 430, height: 172)
    }

    private let preferenceStore = BrowserPreferenceStore()
    private var panel: OverlayPanel?

    func show(url: URL, router: BrowserRouter) {
        let options = Browser.options()
        guard let initialSelection = initialSelection(from: options) else {
            NSSound.beep()
            return
        }

        let view = BrowserSelectionView(
            options: options,
            initialSelection: initialSelection,
            onChoose: { [weak self] browser in
                self?.preferenceStore.saveLastUsedBrowser(browser)
                router.open(url, in: browser) {
                    self?.close()
                }
            },
            onCancel: { [weak self] in
                self?.close()
            }
        )

        let hostingController = NSHostingController(rootView: view)
        let panel = makePanel()
        panel.contentViewController = hostingController
        panel.setFrame(centeredFrame(for: Layout.panelSize), display: true)

        self.panel?.close()
        self.panel = panel

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
    }

    private func close() {
        panel?.close()
        panel = nil
    }

    private func makePanel() -> OverlayPanel {
        let panel = OverlayPanel(
            contentRect: NSRect(origin: .zero, size: Layout.panelSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.hasShadow = true
        panel.isMovableByWindowBackground = false
        panel.isOpaque = false
        panel.isReleasedWhenClosed = false
        panel.level = .modalPanel
        panel.titleVisibility = .hidden

        return panel
    }

    private func centeredFrame(for size: NSSize) -> NSRect {
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { screen in
            NSMouseInRect(mouseLocation, screen.frame, false)
        } ?? NSScreen.main ?? NSScreen.screens.first

        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 900, height: 700)
        let origin = NSPoint(
            x: round(visibleFrame.origin.x + (visibleFrame.width - size.width) / 2),
            y: round(visibleFrame.origin.y + (visibleFrame.height - size.height) / 2)
        )

        return NSRect(origin: origin, size: size)
    }

    private func initialSelection(from options: [BrowserOption]) -> Browser? {
        if
            let lastUsedBrowser = preferenceStore.lastUsedBrowser,
            options.contains(where: { $0.browser == lastUsedBrowser && $0.isInstalled })
        {
            return lastUsedBrowser
        }

        if options.contains(where: { $0.browser == .safari && $0.isInstalled }) {
            return .safari
        }

        return options.first(where: \.isInstalled)?.browser
    }
}

final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
