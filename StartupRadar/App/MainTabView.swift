import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sparkles") }

            SignalsView()
                .tabItem { Label("Signals", systemImage: "dot.radiowaves.left.and.right") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
}

