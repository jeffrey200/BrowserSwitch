//
//  BrowserRouter.swift
//  BrowserSwitch
//

import AppKit

struct BrowserRouter {
    func open(_ url: URL, in browser: Browser, completion: @escaping () -> Void) {
        let targetBrowser = browser.applicationURL == nil ? Browser.safari : browser

        guard let applicationURL = targetBrowser.applicationURL else {
            NSSound.beep()
            completion()
            return
        }

        let runningApplications = NSRunningApplication.runningApplications(
            withBundleIdentifier: targetBrowser.bundleIdentifier
        )

        if runningApplications.isEmpty {
            launchThenOpen(url, in: targetBrowser, applicationURL: applicationURL, completion: completion)
        } else {
            open(url, with: applicationURL, retryCount: 1, completion: completion)
        }
    }

    private func launchThenOpen(
        _ url: URL,
        in browser: Browser,
        applicationURL: URL,
        completion: @escaping () -> Void
    ) {
        let launchConfiguration = NSWorkspace.OpenConfiguration()
        launchConfiguration.activates = false

        NSWorkspace.shared.openApplication(at: applicationURL, configuration: launchConfiguration) { _, error in
            if let error {
                NSLog("Failed to prelaunch \(browser.displayName): \(error)")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                open(url, with: applicationURL, retryCount: 1, completion: completion)
            }
        }
    }

    private func open(
        _ url: URL,
        with applicationURL: URL,
        retryCount: Int,
        completion: @escaping () -> Void
    ) {
        // Opening with an explicit application URL prevents handing the URL back to BrowserSwitch.
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        NSWorkspace.shared.open(
            [url],
            withApplicationAt: applicationURL,
            configuration: configuration
        ) { _, error in
            if let error {
                NSLog("Failed to open \(url.absoluteString) with \(applicationURL.path): \(error)")

                if retryCount > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        open(url, with: applicationURL, retryCount: retryCount - 1, completion: completion)
                    }
                    return
                }
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
