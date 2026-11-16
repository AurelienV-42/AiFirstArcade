import SwiftUI

struct DayFlowView: View {
    let day: AdventDay
    @Environment(\.dismiss) private var dismiss
    @Environment(ProgressStore.self) private var store
    @State private var step: Step = .story

    enum Step: Equatable {
        case story
        case howTo
        case playing(twoPlayers: Bool)
        case bravo(GameOutcome)
    }

    var body: some View {
        ZStack {
            Theme.sky.ignoresSafeArea()
            content
        }
        .onDisappear { Speaker.shared.stop() }
    }

    @ViewBuilder private var content: some View {
        switch step {
        case .story:
            StoryView(day: day, onContinue: afterStory, onClose: close)
        case .howTo:
            if let game = day.game {
                HowToView(game: game, onPlay: { step = .playing(twoPlayers: $0) }, onClose: close)
            }
        case .playing(let twoPlayers):
            if let game = day.game { gameView(game, twoPlayers: twoPlayers) }
        case .bravo(let outcome):
            BravoView(day: day, outcome: outcome, onReplay: { step = .howTo }, onDone: close)
        }
    }

    @ViewBuilder private func gameView(_ game: GameKind, twoPlayers: Bool) -> some View {
        switch game {
        case .pong:
            PongGameView(twoPlayers: twoPlayers, target: 7, onFinish: finish, onQuit: close)
        case .blocks:
            BlocksGameView(targetLines: 15, onFinish: finish, onQuit: close)
        case .platformer:
            PlatformerGameView(onFinish: finish, onQuit: close)
        case .rpg:
            RPGGameView(bonusStars: store.bonusStarsForRPG, onFinish: finish, onQuit: close)
        }
    }

    private func afterStory() {
        Speaker.shared.stop()
        store.markRead(day.id)
        if day.isGame { step = .howTo } else { close() }
    }

    private func finish(_ outcome: GameOutcome) {
        if outcome.showsStars { store.record(stars: outcome.stars, day: day.id) }
        step = .bravo(outcome)
    }

    private func close() {
        Speaker.shared.stop()
        dismiss()
    }
}
