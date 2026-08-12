import SwiftUI

@main
struct CarplayOSApp: App {
    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                DashView()
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
                if url.host == "browser" || url.scheme == "carplayos" && url.host == nil && url.path.contains("browser") {
                    selectedTab = 1
                }
            }
        }
    }
}
