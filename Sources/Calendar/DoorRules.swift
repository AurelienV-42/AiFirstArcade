import Foundation

enum DoorRules {
    static let devCode = "01051999"
    static let devTapCount = 5
    static let devTapWindow: TimeInterval = 3

    static func isOpen(day: Int, now: Date, calendar: Calendar = .current, devOpened: Set<Int> = []) -> Bool {
        if devOpened.contains(day) { return true }
        guard let today = decemberDay(now: now, calendar: calendar) else { return false }
        return day <= today
    }

    static func decemberDay(now: Date, calendar: Calendar = .current) -> Int? {
        let parts = calendar.dateComponents([.month, .day], from: now)
        guard parts.month == 12 else { return nil }
        return parts.day
    }

    static func daysUntilOpen(day: Int, now: Date, calendar: Calendar = .current) -> Int {
        let year = calendar.component(.year, from: now)
        guard let target = calendar.date(from: DateComponents(year: year, month: 12, day: day)) else { return 0 }
        let start = calendar.startOfDay(for: now)
        return max(0, calendar.dateComponents([.day], from: start, to: target).day ?? 0)
    }

    static func isValidDevCode(_ code: String) -> Bool {
        code == devCode
    }

    static func shouldOpenDevPrompt(taps: [Date], now: Date) -> Bool {
        taps.filter { now.timeIntervalSince($0) <= devTapWindow }.count >= devTapCount
    }
}
