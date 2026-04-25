//
//  BrowserSwitchApp.swift
//  BrowserSwitch
//
//  Created by Jeffrey on 25.04.26.
//

import SwiftUI

@main
struct BrowserSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
