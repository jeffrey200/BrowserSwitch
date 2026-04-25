//
//  BrowserRouter.swift
//  BrowserSwitch
//

import AppKit

struct BrowserRouter {
    func open(_ url: URL, in browser: Browser) {
        let targetBrowser = browser.applicationURL == nil ? Browser.safari : browser

        guard let applicationURL = targetBrowser.applicationURL else {
            NSSound.beep()
            return
        }

        // Opening with an explicit application URL prevents handing the URL back to the default browser.
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        NSWorkspace.shared.open(
            [url],
            withApplicationAt: applicationURL,
            configuration: configuration
        )
    }
}
