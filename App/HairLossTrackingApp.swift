import SwiftUI

@main
struct HairLossTrackingApp: App {
    @StateObject private var dataController = DataController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataController)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "photo.stack")
                }
                .tag(1)

            TreatmentsListView()
                .tabItem {
                    Label("Treatments", systemImage: "pills")
                }
                .tag(2)
        }
        .tint(.accentColor)
    }
}

#Preview {
    ContentView()
        .environmentObject(DataController.shared)
}
