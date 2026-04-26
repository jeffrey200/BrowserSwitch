//
//  AppDelegate.swift
//  BrowserSwitch
//

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum LaunchArgument {
        static let debugURL = "--debug-url"
        static let setDefaultBrowser = "--set-default-browser"
    }

    private enum Timing {
        static let overlayPresentationDelay: TimeInterval = 0.1
    }

    fileprivate static let supportedSchemes = ["http", "https"]

    private let overlayWindowController = OverlayWindowController()
    private let browserRouter = BrowserRouter()
    private var statusBarController: StatusBarController?
    private var didFinishLaunching = false
    private var pendingURL: URL?

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Set this as early as possible to minimize the temporary Dock icon when macOS launches the app.
        NSApp.setActivationPolicy(.accessory)

        // Register before launch finishes so the initial URL event is not missed.
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep BrowserSwitch out of the Dock while still letting macOS treat it as a normal app bundle.
        NSApp.setActivationPolicy(.accessory)
        didFinishLaunching = true
        statusBarController = StatusBarController(
            onTestOverlay: { [weak self] in
                self?.handle(urlString: "https://example.com")
            },
            onSetDefaultBrowser: { [weak self] in
                self?.setAsDefaultBrowser(terminateWhenDone: false)
            }
        )

        setAsDefaultBrowserIfRequested()
        showDebugURLIfRequested()
        showPendingURLIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSAppleEventManager.shared().removeEventHandler(
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    @objc private func handleGetURLEvent(
        _ event: NSAppleEventDescriptor,
        withReplyEvent replyEvent: NSAppleEventDescriptor
    ) {
        guard let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue else {
            return
        }

        handle(urlString: urlString)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else {
            return
        }

        handle(url: url)
    }

    func application(
        _ application: NSApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void
    ) -> Bool {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL
        else {
            return false
        }

        handle(url: url)
        return true
    }

    private func showDebugURLIfRequested() {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            let debugURLIndex = arguments.firstIndex(of: LaunchArgument.debugURL),
            arguments.indices.contains(debugURLIndex + 1)
        else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.handle(urlString: arguments[debugURLIndex + 1])
        }
    }

    private func setAsDefaultBrowserIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains(LaunchArgument.setDefaultBrowser) else {
            return
        }

        setAsDefaultBrowser(terminateWhenDone: true)
    }

    private func setAsDefaultBrowser(terminateWhenDone: Bool) {
        let applicationURL = Bundle.main.bundleURL
        let group = DispatchGroup()

        for scheme in Self.supportedSchemes {
            group.enter()
            NSWorkspace.shared.setDefaultApplication(
                at: applicationURL,
                toOpenURLsWithScheme: scheme
            ) { error in
                if let error {
                    NSLog("Failed to set BrowserSwitch as default handler for \(scheme): \(error)")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if terminateWhenDone {
                NSApp.terminate(nil)
            }
        }
    }

    private func handle(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        handle(url: url)
    }

    private func handle(url: URL) {
        guard url.isSupportedBrowserSwitchURL else {
            return
        }

        guard didFinishLaunching else {
            pendingURL = url
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.overlayPresentationDelay) { [weak self] in
            guard let self else {
                return
            }

            overlayWindowController.show(url: url, router: browserRouter)
        }
    }

    private func showPendingURLIfNeeded() {
        guard let pendingURL else {
            return
        }

        self.pendingURL = nil
        handle(url: pendingURL)
    }
}

private extension URL {
    var isSupportedBrowserSwitchURL: Bool {
        guard let scheme = scheme?.lowercased() else {
            return false
        }

        return AppDelegate.supportedSchemes.contains(scheme)
    }
}
