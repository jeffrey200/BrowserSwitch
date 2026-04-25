//
//  BrowserPreferenceStore.swift
//  BrowserSwitch
//

import Foundation

struct BrowserPreferenceStore {
    private static let lastBrowserKey = "lastBrowserBundleIdentifier"

    var lastUsedBrowser: Browser? {
        guard let bundleIdentifier = UserDefaults.standard.string(forKey: Self.lastBrowserKey) else {
            return nil
        }

        return Browser.allCases.first { $0.bundleIdentifier == bundleIdentifier }
    }

    func saveLastUsedBrowser(_ browser: Browser) {
        UserDefaults.standard.set(browser.bundleIdentifier, forKey: Self.lastBrowserKey)
    }
}
