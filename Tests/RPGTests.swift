import Testing
@testable import AiFirstArcade

struct RPGWorldTests {
    @Test func mapsAreRectangular() {
        for id in RPGMapID.allCases {
            let map = RPGWorld.map(id)
            #expect(map.rows.allSatisfy { $0.count == map.width }, "\(id)")
        }
    }

    @Test func entitiesStandOnWalkableTiles() {
        for entity in RPGWorld.entities {
            #expect(RPGWorld.map(entity.map).isWalkable(entity.position), "\(entity.id)")
        }
    }

    @Test func linksArriveOnWalkableTiles() {
        for link in RPGWorld.links {
            #expect(RPGWorld.map(link.from).isWalkable(link.at))
            #expect(RPGWorld.map(link.to).isWalkable(link.arrival))
        }
    }

    @Test func everyEntityCanBeReached() {
        for id in RPGMapID.allCases {
            let reachable = Self.reachable(in: id)
            for entity in RPGWorld.entities where entity.map == id {
                let neighbours = Self.neighbours(of: entity.position)
                #expect(neighbours.contains { reachable.contains($0) }, "\(entity.id)")
            }
        }
    }

    private static func entries(of id: RPGMapID) -> [GridPoint] {
        var points = RPGWorld.links.filter { $0.to == id }.map(\.arrival)
        if RPGWorld.start.map == id { points.append(RPGWorld.start.position) }
        return points
    }

    private static func neighbours(of point: GridPoint) -> [GridPoint] {
        [(1, 0), (-1, 0), (0, 1), (0, -1)].map { GridPoint(x: point.x + $0.0, y: point.y + $0.1) }
    }

    private static func reachable(in id: RPGMapID) -> Set<GridPoint> {
        let map = RPGWorld.map(id)
        var seen = Set(entries(of: id))
        var queue = Array(seen)
        while let point = queue.popLast() {
            for next in neighbours(of: point) where map.isWalkable(next) && !seen.contains(next) {
                seen.insert(next)
                queue.append(next)
            }
        }
        return seen
    }
}

struct RPGCombatTests {
    private func fight(_ enemy: RPGEnemy, hero: HeroStats = .starting(bonusStars: 0)) -> CombatState {
        CombatState(entityID: "test", enemy: enemy, hero: hero, cocoa: 1)
    }

    @Test func damageIsAtLeastOne() {
        #expect(CombatState.damage(attack: 1, defense: 10, roll: -1) == 1)
    }

    @Test func attackHurtsTheEnemyThenItsTheirTurn() {
        var state = fight(.wolf)
        state.heroActs(.attack, roll: 0)
        #expect(state.enemyHP == RPGEnemy.wolf.maxHP - 6)
        #expect(state.phase == .enemyTurn)
    }

    @Test func snowballCostsMagic() {
        var state = fight(.wolf)
        state.heroActs(.snowball, roll: 0)
        #expect(state.hero.mp == 10 - CombatState.snowballCost)
    }

    @Test func defeatingAnEnemyGivesExperience() {
        var state = fight(.wolf)
        state.enemyHP = 1
        state.heroActs(.attack, roll: 0)
        #expect(state.phase == .won(levelsGained: 0))
        #expect(state.hero.xp == RPGEnemy.wolf.xp)
    }

    @Test func heroCanLoseAndCannotFleeTheBoss() {
        var state = fight(.krampus)
        #expect(!state.canUse(.flee))
        state.hero.hp = 1
        state.heroActs(.attack, roll: 0)
        state.enemyActs(roll: 0)
        #expect(state.phase == .lost)
    }

    @Test func levelUpRaisesStats() {
        var hero = HeroStats.starting(bonusStars: 0)
        #expect(hero.gainXP(12) == 1)
        #expect(hero.level == 2)
        #expect(hero.attack == 8)
        #expect(hero.hp == hero.maxHP)
    }

    @Test func starsGiveBonusHealthAndCocoa() {
        let game = RPGGame(bonusStars: 6, roll: { 0 })
        #expect(game.hero.maxHP == 42)
        #expect(game.cocoa == 3)
    }
}

struct RPGGameTests {
    private func drain(_ game: RPGGame) {
        while !game.dialogue.isEmpty { game.advanceDialogue() }
    }

    @Test func innkeeperDuelOpensTheGate() {
        let game = RPGGame(bonusStars: 0, roll: { 0 })
        drain(game)
        for _ in 0..<3 { game.move(dx: 1, dy: 0) }
        for _ in 0..<4 { game.move(dx: 0, dy: -1) }
        game.move(dx: 1, dy: 0)
        drain(game)
        #expect(game.miniGame == .pong)
        game.finishMiniGame(won: true)
        #expect(game.gateOpen)
    }

    @Test func gateBlocksTheForestUntilOpened() {
        let game = RPGGame(bonusStars: 0, roll: { 0 })
        drain(game)
        game.move(dx: -1, dy: 0)
        for _ in 0..<6 { game.move(dx: 0, dy: -1) }
        game.move(dx: 1, dy: 0)
        for _ in 0..<4 {
            game.move(dx: 0, dy: -1)
            drain(game)
        }
        #expect(game.mapID == .village)
        #expect(game.position == GridPoint(x: 7, y: 2))
    }
}
