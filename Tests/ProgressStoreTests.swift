import Foundation
import Testing
@testable import AiFirstArcade

struct ProgressStoreTests {
    private func makeDefaults() throws -> UserDefaults {
        let name = "tests-\(UUID().uuidString)"
        return try #require(UserDefaults(suiteName: name))
    }

    @Test func keepsTheBestScore() throws {
        let store = ProgressStore(defaults: try makeDefaults())
        store.record(stars: 2, day: 1)
        store.record(stars: 1, day: 1)
        #expect(store.stars[1] == 2)
    }

    @Test func persistsAcrossLaunches() throws {
        let defaults = try makeDefaults()
        let store = ProgressStore(defaults: defaults)
        store.record(stars: 3, day: 8)
        store.markRead(2)
        store.devOpen(24)
        let reloaded = ProgressStore(defaults: defaults)
        #expect(reloaded.stars[8] == 3)
        #expect(reloaded.readDays.contains(2))
        #expect(reloaded.devOpenedDays.contains(24))
    }

    @Test func rpgBonusCountsTheThreeWeeklyGames() throws {
        let store = ProgressStore(defaults: try makeDefaults())
        store.record(stars: 3, day: 1)
        store.record(stars: 2, day: 8)
        store.record(stars: 1, day: 15)
        store.record(stars: 3, day: 24)
        #expect(store.bonusStarsForRPG == 6)
    }

    @Test func resetClearsEverything() throws {
        let store = ProgressStore(defaults: try makeDefaults())
        store.record(stars: 3, day: 1)
        store.devOpenAll()
        store.resetAll()
        #expect(store.totalStars == 0)
        #expect(store.devOpenedDays.isEmpty)
    }
}
