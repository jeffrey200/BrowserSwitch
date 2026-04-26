//
//  Browser.swift
//  BrowserSwitch
//

import AppKit
import UniformTypeIdentifiers

enum Browser: String, CaseIterable, Identifiable {
    case chrome
    case firefox
    case firefoxDeveloperEdition
    case safari

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .chrome:
            "Google Chrome"
        case .firefox:
            "Firefox"
        case .firefoxDeveloperEdition:
            "Firefox Dev"
        case .safari:
            "Safari"
        }
    }

    var bundleIdentifier: String {
        switch self {
        case .chrome:
            "com.google.Chrome"
        case .firefox:
            "org.mozilla.firefox"
        case .firefoxDeveloperEdition:
            "org.mozilla.firefoxdeveloperedition"
        case .safari:
            "com.apple.Safari"
        }
    }

    var applicationURL: URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier)
    }

    var isInstalled: Bool {
        applicationURL != nil
    }

    var icon: NSImage {
        guard let applicationURL else {
            return NSWorkspace.shared.icon(for: .applicationBundle)
        }

        let icon = NSWorkspace.shared.icon(forFile: applicationURL.path)
        icon.size = NSSize(width: 64, height: 64)
        return icon
    }
}

struct BrowserOption: Identifiable {
    let browser: Browser
    let isInstalled: Bool

    var id: Browser.ID {
        browser.id
    }
}

extension Browser {
    static func options() -> [BrowserOption] {
        allCases.map { browser in
            BrowserOption(browser: browser, isInstalled: browser.isInstalled)
        }
    }
}
