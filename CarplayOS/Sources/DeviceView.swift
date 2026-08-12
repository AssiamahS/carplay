import SwiftUI

struct DeviceView: View {
    let openBrowser: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Your unit") {
                    LabeledContent("Model", value: "Onn CarPlay dashcam mount")
                    LabeledContent("Wi-Fi network", value: "CARLINK-24FD40")
                    LabeledContent("Default password", value: "12345678 or 88888888")
                    LabeledContent("Backend", value: "192.168.50.2")
                }

                Section("First-time pairing") {
                    stepRow(1, "Power the mount from the car's USB/12V. Wait for its home screen.")
                    stepRow(2, "iPhone: Settings → Bluetooth → pair with the CARLINK device when it appears.")
                    stepRow(3, "It hands off to Wi-Fi automatically and CarPlay starts on the mount.")
                    stepRow(4, "If it doesn't: Settings → Wi-Fi → join CARLINK-24FD40 with the default password, then retry.")
                }

                Section("Device settings page") {
                    Text("With the phone on the CARLINK Wi-Fi, the unit's config page (firmware, resolution, mic, auto-connect) is at 192.168.50.2.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button {
                        openBrowser()
                    } label: {
                        Label("Open backend in SlyBrowser", systemImage: "wrench.and.screwdriver")
                    }
                }

                Section("Good to know") {
                    Text("CarPlay apps on the mount's main screen come from your iPhone. Widgets are the fast lane: any small widget you pin under Settings → General → CarPlay → Widgets shows on the car screen — that's how the carplayOS pack gets there.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Onn Mount")
        }
    }

    private func stepRow(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(n)")
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.accentColor.opacity(0.2)))
            Text(text).font(.subheadline)
        }
    }
}
