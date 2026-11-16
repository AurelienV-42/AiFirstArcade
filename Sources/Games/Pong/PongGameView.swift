import SpriteKit
import SwiftUI

struct PongGameView: View {
    let twoPlayers: Bool
    let onFinish: (GameOutcome) -> Void
    let onQuit: () -> Void
    @State private var scene: PongScene
    @State private var isPaused = false

    init(twoPlayers: Bool, target: Int, onFinish: @escaping (GameOutcome) -> Void, onQuit: @escaping () -> Void) {
        self.twoPlayers = twoPlayers
        self.onFinish = onFinish
        self.onQuit = onQuit
        _scene = State(initialValue: PongScene(size: CGSize(width: 390, height: 844), twoPlayers: twoPlayers, target: target))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            SpriteView(scene: scene, isPaused: isPaused)
                .ignoresSafeArea()
            CircleIconButton(systemName: "pause.fill", label: "Pause") { isPaused = true }
                .padding(20)
            if isPaused {
                PauseOverlay(onResume: { isPaused = false }, onQuit: onQuit)
            }
        }
        .onAppear {
            scene.onFinish = { bottom, top in
                onFinish(PongRules.outcome(bottom: bottom, top: top, twoPlayers: twoPlayers))
            }
        }
    }
}
