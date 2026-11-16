import SwiftUI

struct RPGGameView: View {
    let onFinish: (GameOutcome) -> Void
    let onQuit: () -> Void
    @State private var game: RPGGame
    @State private var isPaused = false

    init(bonusStars: Int, onFinish: @escaping (GameOutcome) -> Void, onQuit: @escaping () -> Void) {
        self.onFinish = onFinish
        self.onQuit = onQuit
        _game = State(initialValue: RPGGame(bonusStars: bonusStars))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                hud
                RPGMapView(game: game)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal, 12)
                DPad(isEnabled: !game.isBusy) { dx, dy in game.move(dx: dx, dy: dy) }
            }
            if let line = game.dialogue.first {
                DialogueBox(line: line, onNext: game.advanceDialogue)
            }
            if let combat = game.combat {
                RPGCombatView(state: combat, onAction: game.combatAction, onEnd: game.endCombat)
                    .transition(.opacity)
            }
            if isPaused {
                PauseOverlay(onResume: { isPaused = false }, onQuit: onQuit)
            }
        }
        .background(Theme.sky)
        .animation(.easeInOut(duration: 0.25), value: game.combat == nil)
        .fullScreenCover(item: $game.miniGame) { mini in miniGameView(mini) }
        .onChange(of: game.isFinished) { _, finished in
            guard finished else { return }
            onFinish(GameOutcome(stars: 3, title: "Tu as sauvé Noël !", detail: "Ton héros a atteint le niveau \(game.hero.level) et rapporté l'étoile au village."))
        }
    }

    private var hud: some View {
        HStack(spacing: 12) {
            CircleIconButton(systemName: "pause.fill", label: "Pause") { isPaused = true }
            VStack(alignment: .leading, spacing: 2) {
                Text(game.map.id.title)
                    .font(Theme.font(.title3, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                Text("Niv. \(game.hero.level) · ❤️ \(game.hero.hp)/\(game.hero.maxHP) · ☕️ \(game.cocoa)")
                    .font(Theme.font(.headline, weight: .semibold))
                    .foregroundStyle(Theme.inkSoft)
            }
            Spacer()
            if game.items.contains(.iceKey) {
                Text("🔑").font(.system(size: 32))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder private func miniGameView(_ mini: MiniGame) -> some View {
        switch mini {
        case .pong:
            PongGameView(twoPlayers: false, target: 3, onFinish: { game.finishMiniGame(won: $0.stars > 0) }, onQuit: { game.finishMiniGame(won: false) })
        case .blocks:
            BlocksGameView(targetLines: 3, onFinish: { game.finishMiniGame(won: $0.stars > 0) }, onQuit: { game.finishMiniGame(won: false) })
        }
    }
}

struct RPGMapView: View {
    let game: RPGGame

    var body: some View {
        GeometryReader { geo in
            let tile = geo.size.width / 9
            let map = game.map
            let mapSize = CGSize(width: CGFloat(map.width) * tile, height: CGFloat(map.height) * tile)
            let camera = cameraOffset(view: geo.size, mapSize: mapSize, tile: tile)
            ZStack(alignment: .topLeading) {
                RPGMapCanvas(map: map, entities: game.visibleEntities, tile: tile)
                    .frame(width: mapSize.width, height: mapSize.height)
                Text("🧝")
                    .font(.system(size: tile * 0.8))
                    .scaleEffect(x: game.facingLeft ? 1 : -1)
                    .frame(width: tile, height: tile)
                    .offset(x: CGFloat(game.position.x) * tile, y: CGFloat(game.position.y) * tile)
            }
            .frame(width: mapSize.width, height: mapSize.height, alignment: .topLeading)
            .offset(x: -camera.x, y: -camera.y)
            .animation(.easeOut(duration: 0.18), value: game.position)
            .id(game.mapID)
        }
        .background(RPGPalette.floor(game.mapID))
    }

    private func cameraOffset(view: CGSize, mapSize: CGSize, tile: CGFloat) -> CGPoint {
        func axis(_ hero: CGFloat, _ viewLength: CGFloat, _ mapLength: CGFloat) -> CGFloat {
            guard mapLength > viewLength else { return (mapLength - viewLength) / 2 }
            return min(max(hero - viewLength / 2, 0), mapLength - viewLength)
        }
        return CGPoint(
            x: axis((CGFloat(game.position.x) + 0.5) * tile, view.width, mapSize.width),
            y: axis((CGFloat(game.position.y) + 0.5) * tile, view.height, mapSize.height)
        )
    }
}

enum RPGPalette {
    static func floor(_ map: RPGMapID) -> Color {
        switch map {
        case .village: Color(hex: 0xF4F8FC)
        case .forest: Color(hex: 0xE3F1E6)
        case .dungeon: Color(hex: 0xC3D3E6)
        }
    }
}

struct RPGMapCanvas: View {
    let map: RPGMap
    let entities: [RPGEntity]
    let tile: CGFloat

    var body: some View {
        Canvas { context, _ in
            for y in 0..<map.height {
                for x in 0..<map.width {
                    let rect = CGRect(x: CGFloat(x) * tile, y: CGFloat(y) * tile, width: tile, height: tile)
                    drawTile(map.tile(at: GridPoint(x: x, y: y)), in: rect, context: context)
                }
            }
            for entity in entities {
                draw(emoji: entity.emoji, at: entity.position, context: context)
            }
        }
    }

    private func drawTile(_ tileKind: Character, in rect: CGRect, context: GraphicsContext) {
        switch tileKind {
        case "#": drawWall(in: rect, context: context)
        case "~": context.fill(Path(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: tile * 0.2), with: .color(Color(hex: 0x9CCBEA)))
        case "H": context.draw(Text("🏠").font(.system(size: tile * 0.85)), at: CGPoint(x: rect.midX, y: rect.midY))
        case "T": context.draw(Text("🎄").font(.system(size: tile * 0.9)), at: CGPoint(x: rect.midX, y: rect.midY))
        case ">", "<":
            let arrow = Text(Image(systemName: tileKind == ">" ? "arrow.up" : "arrow.down"))
                .font(.system(size: tile * 0.4, weight: .heavy))
                .foregroundStyle(Theme.inkSoft)
            context.draw(arrow, at: CGPoint(x: rect.midX, y: rect.midY))
        default: break
        }
    }

    private func drawWall(in rect: CGRect, context: GraphicsContext) {
        switch map.id {
        case .village:
            context.fill(Path(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: tile * 0.2), with: .color(Theme.wood))
        case .forest:
            context.draw(Text("🌲").font(.system(size: tile * 0.85)), at: CGPoint(x: rect.midX, y: rect.midY))
        case .dungeon:
            context.fill(Path(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: tile * 0.15), with: .color(Color(hex: 0x8FB3D9)))
        }
    }

    private func draw(emoji: String, at point: GridPoint, context: GraphicsContext) {
        let center = CGPoint(x: (CGFloat(point.x) + 0.5) * tile, y: (CGFloat(point.y) + 0.5) * tile)
        context.draw(Text(emoji).font(.system(size: tile * 0.78)), at: center)
    }
}

struct DPad: View {
    let isEnabled: Bool
    let onMove: (Int, Int) -> Void

    var body: some View {
        VStack(spacing: 4) {
            RepeatButton(symbol: "arrow.up", label: "Haut") { onMove(0, -1) }
            HStack(spacing: 76) {
                RepeatButton(symbol: "arrow.left", label: "Gauche") { onMove(-1, 0) }
                RepeatButton(symbol: "arrow.right", label: "Droite") { onMove(1, 0) }
            }
            RepeatButton(symbol: "arrow.down", label: "Bas") { onMove(0, 1) }
        }
        .opacity(isEnabled ? 1 : 0.4)
        .padding(.bottom, 8)
    }
}

struct RepeatButton: View {
    let symbol: String
    let label: String
    let action: () -> Void
    @State private var repeater: Task<Void, Never>?

    var body: some View {
        HoldButton(systemName: symbol, label: label, size: 70) { pressed in
            repeater?.cancel()
            repeater = nil
            guard pressed else { return }
            action()
            repeater = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 350_000_000)
                while !Task.isCancelled {
                    action()
                    try? await Task.sleep(nanoseconds: 230_000_000)
                }
            }
        }
    }
}

struct DialogueBox: View {
    let line: DialogueLine
    let onNext: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Text(line.emoji).font(.system(size: 44))
                    Text(line.speaker)
                        .font(Theme.font(.title3, weight: .heavy))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    Button {
                        Speaker.shared.say(line.text)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill").font(.system(size: 22, weight: .bold))
                    }
                    .buttonStyle(RoundToyStyle(fill: Theme.sky, shadow: Theme.skyDeep, size: 52))
                    .accessibilityLabel("Écouter")
                }
                Text(line.text)
                    .font(Theme.font(.title2, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Suivant", action: onNext).buttonStyle(.toyRed)
            }
            .padding(22)
            .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.white))
            .background(RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Theme.wood).offset(y: 6))
            .padding(16)
        }
        .background(Color.black.opacity(0.15).ignoresSafeArea())
    }
}
