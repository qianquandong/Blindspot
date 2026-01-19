//
//  StartupRadarApp.swift
//  StartupRadar
//
//  Created by Cheryl's on 2026/1/18.
//

import SwiftUI

@main
struct StartupRadarApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
