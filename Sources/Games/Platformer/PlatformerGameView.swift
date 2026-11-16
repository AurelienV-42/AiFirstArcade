import SpriteKit
import SwiftUI

struct PlatformerGameView: View {
    let onFinish: (GameOutcome) -> Void
    let onQuit: () -> Void
    @State private var scene = PlatformerScene(size: CGSize(width: 390, height: 640))
    @State private var level = 0
    @State private var gifts = 0
    @State private var isPaused = false
    @State private var banner: String?

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                SpriteView(scene: scene, isPaused: isPaused)
                    .ignoresSafeArea(edges: .top)
                hud
                if let banner { bannerView(banner) }
            }
            controls
        }
        .background(Theme.sky)
        .overlay {
            if isPaused { PauseOverlay(onResume: { isPaused = false }, onQuit: onQuit) }
        }
        .onAppear(perform: bind)
    }

    private var hud: some View {
        HStack(spacing: 10) {
            CircleIconButton(systemName: "pause.fill", label: "Pause") { isPaused = true }
            Spacer()
            InfoPill(text: "Niveau \(level + 1)/4")
            InfoPill(text: "🎁 \(gifts)")
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private func bannerView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 34, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(Capsule().fill(Theme.ink.opacity(0.85)))
            .padding(.top, 140)
            .transition(.scale.combined(with: .opacity))
    }

    private var controls: some View {
        HStack(spacing: 16) {
            HoldButton(systemName: "arrow.left", label: "Gauche", size: 84) { scene.input.left = $0 }
            HoldButton(systemName: "arrow.right", label: "Droite", size: 84) { scene.input.right = $0 }
            Spacer()
            HoldButton(systemName: "arrow.up", label: "Sauter", size: 100, fill: Theme.green, shadow: Theme.greenDeep, tint: .white) { pressed in
                if pressed { scene.input.jumpQueued = true }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    private func bind() {
        scene.onLevelStart = { index in
            level = index
            showBanner("Niveau \(index + 1)")
        }
        scene.onGift = { gifts = $0 }
        scene.onFinish = { collected, total in
            onFinish(PlatformerRules.outcome(collected: collected, total: total))
        }
        showBanner("Niveau \(level + 1)")
    }

    private func showBanner(_ text: String) {
        withAnimation(.spring(response: 0.4)) { banner = text }
        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            withAnimation { if banner == text { banner = nil } }
        }
    }
}
