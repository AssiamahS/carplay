import WidgetKit
import SwiftUI

@main
struct CarWidgetsBundle: WidgetBundle {
    var body: some Widget {
        DashClockWidget()
        DayProgressWidget()
        QuickLaunchWidget()
    }
}

// MARK: - Shared timeline

struct MinuteEntry: TimelineEntry {
    let date: Date
}

struct MinuteProvider: TimelineProvider {
    func placeholder(in context: Context) -> MinuteEntry {
        MinuteEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (MinuteEntry) -> Void) {
        completion(MinuteEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MinuteEntry>) -> Void) {
        let calendar = Calendar.current
        let now = Date.now
        var entries: [MinuteEntry] = []
        for offset in 0..<30 {
            if let date = calendar.date(byAdding: .minute, value: offset, to: now) {
                entries.append(MinuteEntry(date: date))
            }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Dash Clock

struct DashClockWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DashClock", provider: MinuteProvider()) { entry in
            DashClockView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(colors: [Color(red: 0.05, green: 0.09, blue: 0.16), Color(red: 0.02, green: 0.19, blue: 0.25)], startPoint: .top, endPoint: .bottom)
                }
        }
        .configurationDisplayName("Dash Clock")
        .description("Big, glanceable time for the car screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DashClockView: View {
    let entry: MinuteEntry

    var body: some View {
        VStack(spacing: 2) {
            Text(entry.date, style: .time)
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(.white)
            Text(entry.date, format: .dateTime.weekday(.wide).month().day())
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

// MARK: - Day Progress

struct DayProgressWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DayProgress", provider: MinuteProvider()) { entry in
            DayProgressView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.07, green: 0.07, blue: 0.09)
                }
        }
        .configurationDisplayName("Day Progress")
        .description("How much of today is behind you.")
        .supportedFamilies([.systemSmall])
    }
}

struct DayProgressView: View {
    let entry: MinuteEntry

    private var fraction: Double {
        let start = Calendar.current.startOfDay(for: entry.date)
        return min(1, entry.date.timeIntervalSince(start) / 86400)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Int(fraction * 100))%")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("of today")
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))
            Gauge(value: fraction) { EmptyView() }
                .gaugeStyle(.accessoryLinear)
                .tint(.orange)
        }
    }
}

// MARK: - Quick Launch

struct QuickLaunchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "QuickLaunch", provider: MinuteProvider()) { entry in
            QuickLaunchView()
                .containerBackground(for: .widget) {
                    LinearGradient(colors: [Color(red: 0.0, green: 0.25, blue: 0.24), Color(red: 0.0, green: 0.12, blue: 0.14)], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
                .widgetURL(URL(string: "carplayos://browser"))
        }
        .configurationDisplayName("SlyBrowser")
        .description("Jump straight into the browser.")
        .supportedFamilies([.systemSmall])
    }
}

struct QuickLaunchView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "globe")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.teal)
            Text("SlyBrowser")
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
        }
    }
}
