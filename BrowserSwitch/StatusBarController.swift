//
//  StatusBarController.swift
//  BrowserSwitch
//

import AppKit

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let onTestOverlay: () -> Void
    private let onSetDefaultBrowser: () -> Void

    init(
        onTestOverlay: @escaping () -> Void,
        onSetDefaultBrowser: @escaping () -> Void
    ) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.onTestOverlay = onTestOverlay
        self.onSetDefaultBrowser = onSetDefaultBrowser

        super.init()

        configureStatusItem()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "BrowserSwitch")
            button.image?.isTemplate = true
            button.toolTip = "BrowserSwitch"
        }

        let menu = NSMenu()

        let testItem = NSMenuItem(
            title: "Test Overlay",
            action: #selector(testOverlay),
            keyEquivalent: ""
        )
        testItem.target = self
        menu.addItem(testItem)

        let defaultBrowserItem = NSMenuItem(
            title: "Set as Default Browser",
            action: #selector(setDefaultBrowser),
            keyEquivalent: ""
        )
        defaultBrowserItem.target = self
        menu.addItem(defaultBrowserItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit BrowserSwitch",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func testOverlay() {
        onTestOverlay()
    }

    @objc private func setDefaultBrowser() {
        onSetDefaultBrowser()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
