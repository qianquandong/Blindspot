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
    @AppStorage("app_language") private var appLanguageRaw: String = AppLanguage.en.rawValue

    var body: some Scene {
        WindowGroup {
            let lang = AppLanguage(rawValue: appLanguageRaw) ?? .en
            RootView()
                .environmentObject(appState)
                .environment(\.appLanguage, lang)
                .environment(\.locale, Locale(identifier: lang.rawValue))
        }
    }
}
