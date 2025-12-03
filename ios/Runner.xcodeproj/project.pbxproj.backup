import Foundation
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let defaults = UserDefaults(suiteName: "group.com.streakly.app")
    
    func updateStreakData(
        streakCount: Int,
        todayCompleted: Bool,
        habitName: String,
        nextReminder: String
    ) {
        defaults?.set(streakCount, forKey: "streakCount")
        defaults?.set(todayCompleted, forKey: "todayCompleted")
        defaults?.set(habitName, forKey: "habitName")
        defaults?.set(nextReminder, forKey: "nextReminder")
        defaults?.synchronize()
        
        // Notify widget to refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getStreakData() -> [String: Any] {
        guard let defaults = defaults else { return [:] }
        
        return [
            "streakCount": defaults.integer(forKey: "streakCount"),
            "todayCompleted": defaults.bool(forKey: "todayCompleted"),
            "habitName": defaults.string(forKey: "habitName") ?? "Streakly",
            "nextReminder": defaults.string(forKey: "nextReminder") ?? "No reminders"
        ]
    }
    
    func clearAll() {
        defaults?.removePersistentDomain(forName: "group.com.streakly.app")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
