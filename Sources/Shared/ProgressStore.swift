import Foundation
import Observation

@Observable
final class ProgressStore {
    private let defaults: UserDefaults
    private(set) var stars: [Int: Int]
    private(set) var readDays: Set<Int>
    private(set) var devOpenedDays: Set<Int>
    var hasSeenSplash: Bool {
        didSet { defaults.set(hasSeenSplash, forKey: Key.splash) }
    }
    var isDevMode = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let raw = defaults.dictionary(forKey: Key.stars) as? [String: Int] ?? [:]
        stars = Dictionary(uniqueKeysWithValues: raw.compactMap { key, value in Int(key).map { ($0, value) } })
        readDays = Set(defaults.array(forKey: Key.read) as? [Int] ?? [])
        devOpenedDays = Set(defaults.array(forKey: Key.devOpened) as? [Int] ?? [])
        hasSeenSplash = defaults.bool(forKey: Key.splash)
    }

    var totalStars: Int { stars.values.reduce(0, +) }

    var bonusStarsForRPG: Int {
        [1, 8, 15].reduce(0) { $0 + (stars[$1] ?? 0) }
    }

    func isOpen(_ day: Int, now: Date = .now) -> Bool {
        DoorRules.isOpen(day: day, now: now, devOpened: devOpenedDays)
    }

    func record(stars value: Int, day: Int) {
        stars[day] = max(stars[day] ?? 0, value)
        persist()
    }

    func markRead(_ day: Int) {
        readDays.insert(day)
        persist()
    }

    func devOpen(_ day: Int) {
        devOpenedDays.insert(day)
        persist()
    }

    func devOpenAll() {
        devOpenedDays = Set(1...24)
        persist()
    }

    func resetAll() {
        stars = [:]
        readDays = []
        devOpenedDays = []
        hasSeenSplash = false
        persist()
    }

    private func persist() {
        defaults.set(Dictionary(uniqueKeysWithValues: stars.map { (String($0.key), $0.value) }), forKey: Key.stars)
        defaults.set(Array(readDays), forKey: Key.read)
        defaults.set(Array(devOpenedDays), forKey: Key.devOpened)
    }

    private enum Key {
        static let stars = "stars"
        static let read = "readDays"
        static let devOpened = "devOpenedDays"
        static let splash = "hasSeenSplash"
    }
}
