//
//  LifeDeckWatchApp.swift
//  LifeDeckWatch Watch App
//
//  Created on 2024
//

import SwiftUI

@main
struct LifeDeckWatch_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor var delegate: ExtensionDelegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                WatchDashboardView()
            }
        }
    }
}