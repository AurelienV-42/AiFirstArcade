import Testing
@testable import AiFirstArcade

struct PongRulesTests {
    @Test func losingGivesNoStar() {
        #expect(PongRules.stars(player: 5, opponent: 7) == 0)
    }

    @Test func biggerWinsGiveMoreStars() {
        #expect(PongRules.stars(player: 7, opponent: 6) == 1)
        #expect(PongRules.stars(player: 7, opponent: 4) == 2)
        #expect(PongRules.stars(player: 7, opponent: 1) == 3)
    }

    @Test func twoPlayerGameHidesStars() {
        #expect(!PongRules.outcome(bottom: 7, top: 3, twoPlayers: true).showsStars)
    }
}

struct BlocksModelTests {
    private static func emptyBoard() -> [[PieceKind?]] {
        Array(repeating: Array(repeating: nil, count: BlocksModel.width), count: BlocksModel.height)
    }

    @Test func movingLeftStopsAtTheWall() {
        var model = BlocksModel(targetLines: 15, shuffle: { _ in [.o] })
        var moves = 0
        while model.move(-1) { moves += 1 }
        #expect(moves == 4)
        #expect(model.current.absoluteCells.map(\.x).min() == 0)
    }

    @Test func dropClearsAFullLine() {
        var board = Self.emptyBoard()
        for x in 0..<BlocksModel.width where !(3...6).contains(x) {
            board[BlocksModel.height - 1][x] = .t
        }
        var model = BlocksModel(targetLines: 15, board: board, shuffle: { _ in [.i] })
        #expect(model.drop() == .locked(cleared: 1))
        #expect(model.lines == 1)
        #expect(model.board[BlocksModel.height - 1].allSatisfy { $0 == nil })
    }

    @Test func blockedSpawnEndsTheGame() {
        var board = Self.emptyBoard()
        board[0][4] = .t
        let model = BlocksModel(targetLines: 15, board: board, shuffle: { _ in [.o] })
        #expect(model.isOver)
    }

    @Test func rotationNearTheWallStaysInside() {
        var model = BlocksModel(targetLines: 15, shuffle: { _ in [.i] })
        _ = model.step()
        while model.move(1) {}
        let rotated = model.rotate()
        #expect(rotated)
        #expect(model.current.absoluteCells.allSatisfy { $0.x >= 0 && $0.x < BlocksModel.width && $0.y >= 0 })
    }

    @Test func starsFollowClearedLines() {
        #expect(BlocksRules.stars(lines: 2) == 0)
        #expect(BlocksRules.stars(lines: 3) == 1)
        #expect(BlocksRules.stars(lines: 8) == 2)
        #expect(BlocksRules.stars(lines: 15) == 3)
    }
}

struct PlatformerLevelTests {
    @Test func thereAreFourLevels() {
        #expect(PlatformerLevels.all.count == 4)
    }

    @Test func keyPointsAreFreeSpace() {
        for level in PlatformerLevels.all {
            let points = [level.start, level.goal] + level.gifts + level.enemies + level.spikes + level.checkpoints
            #expect(points.allSatisfy { !level.isSolid($0) })
        }
    }

    @Test func walkersStandOnGround() {
        for level in PlatformerLevels.all {
            let walkers = level.enemies + level.spikes + level.checkpoints + [level.start]
            #expect(walkers.allSatisfy { level.isSolid(GridPoint(x: $0.x, y: $0.y - 1)) })
        }
    }

    @Test func starsRewardGifts() {
        #expect(PlatformerRules.stars(collected: 0, total: 10) == 1)
        #expect(PlatformerRules.stars(collected: 6, total: 10) == 2)
        #expect(PlatformerRules.stars(collected: 9, total: 10) == 3)
    }
}
