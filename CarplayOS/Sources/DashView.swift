import SwiftUI
import EventKit
import WidgetKit

struct DashView: View {
    let openBrowser: () -> Void

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
                previewCard { MonthPreview() }
                previewCard { RemindersPreview() }
            }
            Text("These are previews — the real widgets live on your home screen and the CarPlay widget screen. The Reminders widget needs access:")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Button {
                Task {
                    _ = try? await EKEventStore().requestFullAccessToReminders()
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } label: {
                Label("Allow Reminders", systemImage: "checklist")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
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
            StepRow(number: 1, text: "Connect the phone to your Onn CarPlay mount (Device tab has the steps).")
            StepRow(number: 2, text: "On iPhone: Settings → General → CarPlay → your car.")
            StepRow(number: 3, text: "Tap Widgets → Add Widgets → pick the carplayOS widgets.")
            StepRow(number: 4, text: "Swipe to the widget screen on the car display.")
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

struct MonthPreview: View {
    var body: some View {
        VStack(spacing: 4) {
            Text(Date.now, format: .dateTime.month(.wide))
                .font(.caption.bold())
                .foregroundStyle(.orange)
            Text(Date.now, format: .dateTime.day())
                .font(.system(size: 26, weight: .heavy, design: .rounded))
            Text("month grid")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(8)
    }
}

struct RemindersPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Reminders", systemImage: "checklist")
                .font(.caption2.bold())
                .foregroundStyle(.orange)
            ForEach(["Call Lomedico", "Pick up keys"], id: \.self) { item in
                HStack(spacing: 4) {
                    Circle().strokeBorder(.orange, lineWidth: 1.5).frame(width: 7, height: 7)
                    Text(item).font(.system(size: 9, weight: .semibold)).lineLimit(1)
                }
            }
        }
        .padding(8)
    }
}
