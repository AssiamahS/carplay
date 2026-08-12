import WidgetKit
import SwiftUI
import EventKit

@main
struct CarWidgetsBundle: WidgetBundle {
    var body: some Widget {
        DashClockWidget()
        MonthCalendarWidget()
        RemindersWidget()
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

// MARK: - Month Calendar

struct MonthCalendarWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MonthCalendar", provider: MinuteProvider()) { entry in
            MonthCalendarView(date: entry.date)
                .containerBackground(for: .widget) {
                    Color(red: 0.07, green: 0.07, blue: 0.09)
                }
        }
        .configurationDisplayName("Month")
        .description("This month at a glance, today highlighted.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MonthCalendarView: View {
    let date: Date

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        let today = calendar.component(.day, from: date)
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        let dayCount = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        let leadingBlanks = (calendar.component(.weekday, from: monthStart) - calendar.firstWeekday + 7) % 7
        let symbols = calendar.veryShortStandaloneWeekdaySymbols

        VStack(spacing: 3) {
            Text(date, format: .dateTime.month(.wide))
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(.orange)
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Text(symbols[(index + calendar.firstWeekday - 1) % 7])
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            let cells = leadingBlanks + dayCount
            let rows = Int(ceil(Double(cells) / 7))
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        let cell = row * 7 + col
                        let day = cell - leadingBlanks + 1
                        Group {
                            if day >= 1 && day <= dayCount {
                                Text("\(day)")
                                    .font(.system(size: 9, weight: day == today ? .heavy : .regular))
                                    .foregroundStyle(day == today ? Color.black : .white.opacity(0.85))
                                    .frame(width: 14, height: 11)
                                    .background(
                                        day == today
                                            ? Capsule().fill(Color.orange)
                                            : nil
                                    )
                            } else {
                                Color.clear.frame(width: 14, height: 11)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Reminders

struct RemindersEntry: TimelineEntry {
    let date: Date
    let items: [String]
    let granted: Bool
}

struct RemindersProvider: TimelineProvider {
    func placeholder(in context: Context) -> RemindersEntry {
        RemindersEntry(date: .now, items: ["Call Lomedico", "Pick up keys"], granted: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (RemindersEntry) -> Void) {
        fetch(completion: completion)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RemindersEntry>) -> Void) {
        fetch { entry in
            let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    private func fetch(completion: @escaping (RemindersEntry) -> Void) {
        let store = EKEventStore()
        guard EKEventStore.authorizationStatus(for: .reminder) == .fullAccess else {
            completion(RemindersEntry(date: .now, items: [], granted: false))
            return
        }
        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: nil, ending: nil, calendars: nil)
        store.fetchReminders(matching: predicate) { reminders in
            let sorted = (reminders ?? [])
                .sorted {
                    let a = $0.dueDateComponents?.date ?? .distantFuture
                    let b = $1.dueDateComponents?.date ?? .distantFuture
                    return a < b
                }
                .prefix(4)
                .compactMap(\.title)
            completion(RemindersEntry(date: .now, items: Array(sorted), granted: true))
        }
    }
}

struct RemindersWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CarReminders", provider: RemindersProvider()) { entry in
            RemindersView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(colors: [Color(red: 0.16, green: 0.07, blue: 0.02), Color(red: 0.25, green: 0.12, blue: 0.02)], startPoint: .top, endPoint: .bottom)
                }
        }
        .configurationDisplayName("Reminders")
        .description("Your next reminders, glanceable in the car.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct RemindersView: View {
    let entry: RemindersEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "checklist")
                    .font(.system(size: 10, weight: .bold))
                Text("Reminders")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
            }
            .foregroundStyle(.orange)
            if !entry.granted {
                Text("Allow Reminders in the carplayOS app")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            } else if entry.items.isEmpty {
                Text("All clear")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                ForEach(entry.items.prefix(3), id: \.self) { item in
                    HStack(spacing: 5) {
                        Circle()
                            .strokeBorder(Color.orange, lineWidth: 1.5)
                            .frame(width: 8, height: 8)
                        Text(item)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
