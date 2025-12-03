import WidgetKit
import SwiftUI
import Intents

struct StreaklyWidgetEntry: TimelineEntry {
    let date: Date
    let streakCount: Int
    let todayCompleted: Bool
    let habitName: String
    let nextReminder: String
}

struct StreaklyWidgetProvider: TimelineProvider {
    typealias Entry = StreaklyWidgetEntry
    func placeholder(in context: Context) -> StreaklyWidgetEntry {
        StreaklyWidgetEntry(
            date: Date(),
            streakCount: 7,
            todayCompleted: false,
            habitName: "Morning Exercise",
            nextReminder: "Tomorrow at 6:00 AM"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StreaklyWidgetEntry) -> ()) {
        let entry = StreaklyWidgetEntry(
            date: Date(),
            streakCount: loadStreakData()["streakCount"] as? Int ?? 0,
            todayCompleted: loadStreakData()["todayCompleted"] as? Bool ?? false,
            habitName: loadStreakData()["habitName"] as? String ?? "Streakly",
            nextReminder: loadStreakData()["nextReminder"] as? String ?? "No reminders"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [StreaklyWidgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from now.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = StreaklyWidgetEntry(
                date: entryDate,
                streakCount: loadStreakData()["streakCount"] as? Int ?? 0,
                todayCompleted: loadStreakData()["todayCompleted"] as? Bool ?? false,
                habitName: loadStreakData()["habitName"] as? String ?? "Streakly",
                nextReminder: loadStreakData()["nextReminder"] as? String ?? "No reminders"
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    // Load streak data from shared app group
    private func loadStreakData() -> [String: Any] {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.streakly.app") {
            let data: [String: Any] = [
                "streakCount": sharedDefaults.integer(forKey: "streakCount"),
                "todayCompleted": sharedDefaults.bool(forKey: "todayCompleted"),
                "habitName": sharedDefaults.string(forKey: "habitName") ?? "Streakly",
                "nextReminder": sharedDefaults.string(forKey: "nextReminder") ?? "No reminders"
            ]
            return data
        }
        return [:]
    }
}

struct StreaklyWidgetEntryView: View {
    var entry: StreaklyWidgetProvider.Entry

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.7),
                    Color(red: 0.2, green: 0.4, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🔥 Streakly")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    if entry.todayCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.habitName)
                        .font(.system(.subheadline, design: .default))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Text("\(entry.streakCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading) {
                            Text("Day Streak")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                            Text("Keep it up! 💪")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.3))

                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Text(entry.nextReminder)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                    Spacer()
                }
            }
            .padding()
        }
        .cornerRadius(12)
    }
}

@main
struct StreaklyWidget: Widget {
    let kind: String = "StreaklyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreaklyWidgetProvider()) { entry in
            StreaklyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streakly Widget")
        .description("Keep track of your daily habits and streaks right from your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Preview providers are optional — remove invalid preview block.
