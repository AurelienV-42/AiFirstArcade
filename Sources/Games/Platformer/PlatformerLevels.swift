struct PlatformerLevel {
    static let height = 12
    let width: Int
    let start: GridPoint
    let goal: GridPoint
    private(set) var solid: Set<GridPoint> = []
    var gifts: [GridPoint] = []
    var enemies: [GridPoint] = []
    var spikes: [GridPoint] = []
    var checkpoints: [GridPoint] = []

    init(width: Int, start: GridPoint, goal: GridPoint) {
        self.width = width
        self.start = start
        self.goal = goal
    }

    func isSolid(_ point: GridPoint) -> Bool {
        solid.contains(point)
    }

    mutating func fill(_ xs: ClosedRange<Int>, _ ys: ClosedRange<Int>) {
        for x in xs {
            for y in ys { solid.insert(GridPoint(x: x, y: y)) }
        }
    }

    mutating func ground(_ ranges: ClosedRange<Int>...) {
        ranges.forEach { fill($0, 0...0) }
    }
}

private func points(_ raw: [(Int, Int)]) -> [GridPoint] {
    raw.map { GridPoint(x: $0.0, y: $0.1) }
}

enum PlatformerLevels {
    static let all = [first, second, third, fourth]

    private static var first: PlatformerLevel {
        var level = PlatformerLevel(width: 50, start: GridPoint(x: 1, y: 1), goal: GridPoint(x: 46, y: 3))
        level.ground(0...9, 13...33, 38...49)
        level.fill(4...7, 1...1)
        level.fill(12...16, 2...2)
        level.fill(25...27, 2...2)
        level.fill(33...37, 1...1)
        level.fill(42...47, 1...1)
        level.fill(44...47, 2...2)
        level.gifts = points([(5, 2), (6, 2), (13, 3), (14, 3), (15, 3), (26, 3), (35, 2)])
        level.enemies = points([(20, 1)])
        level.checkpoints = points([(23, 1)])
        return level
    }

    private static var second: PlatformerLevel {
        var level = PlatformerLevel(width: 60, start: GridPoint(x: 1, y: 1), goal: GridPoint(x: 57, y: 3))
        level.ground(0...8, 12...22, 25...40, 44...59)
        level.fill(9...11, 2...2)
        level.fill(28...31, 1...1)
        level.fill(30...31, 2...2)
        level.fill(33...36, 3...3)
        level.fill(54...57, 1...1)
        level.fill(56...57, 2...2)
        level.spikes = points([(16, 1), (17, 1)])
        level.gifts = points([(10, 3), (16, 3), (17, 3), (31, 3), (34, 4), (35, 4), (42, 3), (52, 2)])
        level.enemies = points([(20, 1), (38, 1), (50, 1)])
        level.checkpoints = points([(26, 1)])
        return level
    }

    private static var third: PlatformerLevel {
        var level = PlatformerLevel(width: 64, start: GridPoint(x: 1, y: 1), goal: GridPoint(x: 60, y: 2))
        level.ground(0...10, 30...34, 50...63)
        level.fill(13...15, 2...2)
        level.fill(18...20, 3...3)
        level.fill(23...25, 2...2)
        level.fill(27...29, 1...1)
        level.fill(37...39, 2...2)
        level.fill(42...44, 3...3)
        level.fill(46...48, 2...2)
        level.fill(59...61, 1...1)
        level.gifts = points([(14, 3), (19, 4), (20, 4), (24, 3), (28, 2), (38, 3), (43, 4), (47, 3), (52, 1), (53, 1)])
        level.enemies = points([(55, 1)])
        level.checkpoints = points([(31, 1)])
        return level
    }

    private static var fourth: PlatformerLevel {
        var level = PlatformerLevel(width: 70, start: GridPoint(x: 1, y: 1), goal: GridPoint(x: 66, y: 4))
        level.ground(0...12, 16...30, 34...45, 49...69)
        level.fill(5...6, 1...1)
        level.fill(13...15, 2...2)
        level.fill(19...22, 2...2)
        level.fill(64...67, 1...1)
        level.fill(65...67, 2...2)
        level.fill(66...67, 3...3)
        level.spikes = points([(8, 1), (9, 1), (20, 1), (21, 1), (40, 1)])
        level.gifts = points([(5, 2), (6, 2), (14, 3), (20, 3), (21, 3), (32, 3), (41, 3), (47, 3), (58, 2), (59, 2)])
        level.enemies = points([(26, 1), (37, 1), (55, 1), (61, 1)])
        level.checkpoints = points([(17, 1), (50, 1)])
        return level
    }
}

enum PlatformerRules {
    static func stars(collected: Int, total: Int) -> Int {
        guard total > 0 else { return 3 }
        let ratio = Double(collected) / Double(total)
        return 1 + (ratio >= 0.6 ? 1 : 0) + (ratio >= 0.9 ? 1 : 0)
    }

    static func outcome(collected: Int, total: Int) -> GameOutcome {
        GameOutcome(
            stars: stars(collected: collected, total: total),
            title: "Bravo !",
            detail: "Le lutin a traversé les 4 niveaux et ramassé \(collected) cadeaux sur \(total)."
        )
    }
}
