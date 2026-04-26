//
//  OverlayWindowController.swift
//  BrowserSwitch
//

import AppKit
import SwiftUI

final class OverlayWindowController {
    private let preferenceStore = BrowserPreferenceStore()
    private var panel: OverlayPanel?

    func show(url: URL, router: BrowserRouter) {
        let options = Browser.options()
        let panelSize = BrowserSelectionView.panelSize(for: options.count)
        let initialSelection = initialSelection(from: options)

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
        let panel = makePanel(size: panelSize)
        panel.contentViewController = hostingController
        panel.setFrame(centeredFrame(for: panelSize), display: true)

        self.panel?.close()
        self.panel = panel

        NSApp.activate(ignoringOtherApps: true)
        NSRunningApplication.current.activate(options: [.activateAllWindows])
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
        panel.makeMain()
    }

    private func close() {
        panel?.close()
        panel = nil
    }

    private func makePanel(size: NSSize) -> OverlayPanel {
        let panel = OverlayPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.isMovableByWindowBackground = false
        panel.isOpaque = false
        panel.isReleasedWhenClosed = false
        panel.level = .popUpMenu
        panel.titleVisibility = .hidden
        panel.worksWhenModal = true

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

    private func initialSelection(from options: [BrowserOption]) -> Browser {
        let installedBrowsers = options
            .filter(\.isInstalled)
            .map(\.browser)

        if
            let lastUsedBrowser = preferenceStore.lastUsedBrowser,
            installedBrowsers.contains(lastUsedBrowser)
        {
            return lastUsedBrowser
        }

        if installedBrowsers.contains(.safari) {
            return .safari
        }

        return installedBrowsers.first ?? .safari
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
