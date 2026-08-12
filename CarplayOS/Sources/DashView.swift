import SwiftUI

struct DashView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    widgetGallery
                    setupCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("carplayOS")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your widgets, on the car screen")
                .font(.title2.bold())
            Text("iOS 26 puts small widgets on a dedicated CarPlay screen. Pin the carplayOS pack and they show up on your Onn mount automatically.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var widgetGallery: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Widget pack").font(.headline)
            HStack(spacing: 12) {
                previewCard { DashClockPreview() }
                previewCard { DayProgressPreview() }
                previewCard { QuickLaunchPreview() }
            }
        }
    }

    private func previewCard(@ViewBuilder content: () -> some View) -> some View {
        content()
            .frame(width: 110, height: 110)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    private var setupCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Show these in CarPlay").font(.headline)
            step(1, "Connect the phone to your Onn CarPlay mount (Device tab has the steps).")
            step(2, "On iPhone: Settings → General → CarPlay → your car.")
            step(3, "Tap Widgets → Add Widgets → pick the carplayOS widgets.")
            step(4, "Swipe to the widget screen on the car display.")
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Open Settings", systemImage: "gear")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func step(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(n)")
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.accentColor.opacity(0.2)))
            Text(text).font(.subheadline)
        }
    }
}

struct DashClockPreview: View {
    var body: some View {
        VStack(spacing: 2) {
            Text(Date.now, style: .time)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.5)
            Text(Date.now, format: .dateTime.weekday(.wide))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(8)
    }
}

struct DayProgressPreview: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("\(dayPercent)%")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
            Text("of today")
                .font(.caption2)
                .foregroundStyle(.secondary)
            ProgressView(value: Double(dayPercent) / 100)
                .tint(.orange)
                .padding(.horizontal, 10)
        }
        .padding(8)
    }

    private var dayPercent: Int {
        let start = Calendar.current.startOfDay(for: .now)
        return Int(Date.now.timeIntervalSince(start) / 86400 * 100)
    }
}

struct QuickLaunchPreview: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "globe")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.teal)
            Text("SlyBrowser")
                .font(.caption2.bold())
        }
        .padding(8)
    }
}
