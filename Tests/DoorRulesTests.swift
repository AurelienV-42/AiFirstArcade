import Foundation
import Testing
@testable import AiFirstArcade

struct DoorRulesTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .current
        return calendar
    }()

    private func date(month: Int, day: Int) throws -> Date {
        try #require(calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: 10)))
    }

    @Test func everyDoorIsClosedInNovember() throws {
        let now = try date(month: 11, day: 30)
        #expect(!DoorRules.isOpen(day: 1, now: now, calendar: calendar))
    }

    @Test func doorOpensOnItsDayOnly() throws {
        let now = try date(month: 12, day: 5)
        #expect(DoorRules.isOpen(day: 5, now: now, calendar: calendar))
        #expect(!DoorRules.isOpen(day: 6, now: now, calendar: calendar))
    }

    @Test func pastDoorsStayOpen() throws {
        #expect(DoorRules.isOpen(day: 1, now: try date(month: 12, day: 20), calendar: calendar))
    }

    @Test func devOpenedDoorIsOpenAnyDay() throws {
        let now = try date(month: 11, day: 16)
        #expect(DoorRules.isOpen(day: 24, now: now, calendar: calendar, devOpened: [24]))
    }

    @Test func countsDaysUntilOpening() throws {
        #expect(DoorRules.daysUntilOpen(day: 1, now: try date(month: 11, day: 16), calendar: calendar) == 15)
    }

    @Test func onlyTheDevCodeIsAccepted() {
        #expect(DoorRules.isValidDevCode("01051999"))
        #expect(!DoorRules.isValidDevCode("12345678"))
    }

    @Test func fiveQuickTapsOpenTheDevPrompt() {
        let now = Date()
        let quick = (0..<5).map { now.addingTimeInterval(-Double($0) * 0.3) }
        let slow = (0..<5).map { now.addingTimeInterval(-Double($0) * 2) }
        #expect(DoorRules.shouldOpenDevPrompt(taps: quick, now: now))
        #expect(!DoorRules.shouldOpenDevPrompt(taps: Array(quick.prefix(4)), now: now))
        #expect(!DoorRules.shouldOpenDevPrompt(taps: slow, now: now))
    }

    @Test func calendarHasFourGamesOnTheRightDays() {
        #expect(AdventCalendar.days.map(\.id) == Array(1...24))
        #expect(AdventCalendar.days.filter(\.isGame).map(\.id) == [1, 8, 15, 24])
    }
}
