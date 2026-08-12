import SwiftUI

@main
struct CarplayOSApp: App {
    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                DashView(openBrowser: { selectedTab = 1 })
                    .tabItem { Label("Dash", systemImage: "car.rear.road.lane.distant") }
                    .tag(0)
                BrowserView()
                    .tabItem { Label("Browser", systemImage: "globe") }
                    .tag(1)
                DeviceView(openBrowser: { selectedTab = 1 })
                    .tabItem { Label("Device", systemImage: "antenna.radiowaves.left.and.right" ) }
                    .tag(2)
            }
            .onOpenURL { url in
                if url.scheme == "carplayos" {
                    selectedTab = 1
                }
            }
        }
    }
}
