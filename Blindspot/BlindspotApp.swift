//
//  BlindspotApp.swift
//  Blindspot
//
//  Created by Cheryl's on 2026/1/18.
//

import SwiftUI

@main
struct BlindspotApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
