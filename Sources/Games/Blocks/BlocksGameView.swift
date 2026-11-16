import SwiftUI

struct BlocksGameView: View {
    let targetLines: Int
    let onFinish: (GameOutcome) -> Void
    let onQuit: () -> Void
    @State private var model: BlocksModel
    @State private var isPaused = false
    @State private var isFinished = false

    init(targetLines: Int, onFinish: @escaping (GameOutcome) -> Void, onQuit: @escaping () -> Void) {
        self.targetLines = targetLines
        self.onFinish = onFinish
        self.onQuit = onQuit
        _model = State(initialValue: BlocksModel(targetLines: targetLines))
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            BlocksBoard(model: model)
                .onTapGesture { act { _ = $0.rotate() } }
            controls
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Theme.sky)
        .overlay {
            if isPaused { PauseOverlay(onResume: { isPaused = false }, onQuit: onQuit) }
        }
        .task { await runLoop() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            CircleIconButton(systemName: "pause.fill", label: "Pause") { isPaused = true }
            Spacer()
            VStack(spacing: 0) {
                Text("Lignes").font(Theme.font(.headline)).foregroundStyle(Theme.inkSoft)
                Text(verbatim: "\(model.lines) / \(targetLines)")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
            }
            Spacer()
            NextPiecePreview(kind: model.next)
        }
        .padding(.top, 8)
    }

    private var controls: some View {
        HStack(spacing: 14) {
            control("arrow.left", label: "Gauche") { _ = $0.move(-1) }
            control("arrow.clockwise", label: "Tourner") { _ = $0.rotate() }
            control("arrow.right", label: "Droite") { _ = $0.move(1) }
            Button(action: dropNow) {
                Image(systemName: "arrow.down.to.line").font(.system(size: 28, weight: .heavy))
            }
            .buttonStyle(RoundToyStyle(fill: Theme.green, shadow: Theme.greenDeep, size: 76))
            .foregroundStyle(.white)
            .accessibilityLabel("Faire tomber")
        }
    }

    private func control(_ symbol: String, label: String, action: @escaping (inout BlocksModel) -> Void) -> some View {
        Button { act(action) } label: {
            Image(systemName: symbol).font(.system(size: 28, weight: .heavy))
        }
        .buttonStyle(RoundToyStyle(size: 76))
        .accessibilityLabel(label)
    }

    private func act(_ change: (inout BlocksModel) -> Void) {
        guard !isPaused, !isFinished, !model.isOver else { return }
        change(&model)
    }

    private func dropNow() {
        guard !isPaused, !isFinished, !model.isOver else { return }
        let result = model.drop()
        apply(result)
    }

    private func apply(_ result: BlocksModel.StepResult) {
        switch result {
        case .moved:
            break
        case .locked(let cleared):
            if cleared > 0 { Haptics.impact(.heavy) } else { Haptics.impact(.light) }
            if model.isWon { finish() }
        case .over:
            Haptics.notify(.error)
            finish()
        }
    }

    private var interval: Double {
        max(0.35, 0.9 - Double(model.lines / 4) * 0.1)
    }

    private func runLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            guard !isPaused, !isFinished else { continue }
            let result = model.step()
            apply(result)
        }
    }

    private func finish() {
        guard !isFinished else { return }
        isFinished = true
        let outcome = BlocksRules.outcome(lines: model.lines, target: targetLines)
        Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            onFinish(outcome)
        }
    }
}

enum GiftPalette {
    static func color(_ kind: PieceKind) -> Color {
        switch kind {
        case .i: Theme.red
        case .o: Theme.green
        case .t: Theme.blue
        case .s: Color(hex: 0x9B6BD6)
        case .z: Color(hex: 0xF5934A)
        case .j: Color(hex: 0x3BB6B0)
        case .l: Color(hex: 0xEC6FA8)
        }
    }

    static func drawGift(in context: GraphicsContext, rect: CGRect, color: Color) {
        let box = rect.insetBy(dx: 1.5, dy: 1.5)
        context.fill(Path(roundedRect: box, cornerRadius: box.width * 0.22), with: .color(color))
        let ribbon = box.width * 0.16
        context.fill(Path(CGRect(x: box.midX - ribbon / 2, y: box.minY, width: ribbon, height: box.height)), with: .color(Theme.gold))
        context.fill(Path(CGRect(x: box.minX, y: box.midY - ribbon / 2, width: box.width, height: ribbon)), with: .color(Theme.gold))
    }
}

struct BlocksBoard: View {
    let model: BlocksModel

    var body: some View {
        GeometryReader { geo in
            let cell = min(geo.size.width / CGFloat(BlocksModel.width), geo.size.height / CGFloat(BlocksModel.height))
            Canvas { context, _ in
                draw(in: context, cell: cell)
            }
            .frame(width: cell * CGFloat(BlocksModel.width), height: cell * CGFloat(BlocksModel.height))
            .background(RoundedRectangle(cornerRadius: 14).fill(.white))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func draw(in context: GraphicsContext, cell: CGFloat) {
        for y in 0..<BlocksModel.height {
            for x in 0..<BlocksModel.width {
                let rect = CGRect(x: CGFloat(x) * cell, y: CGFloat(y) * cell, width: cell, height: cell)
                if let kind = model.board[y][x] {
                    GiftPalette.drawGift(in: context, rect: rect, color: GiftPalette.color(kind))
                } else {
                    context.fill(Path(ellipseIn: CGRect(x: rect.midX - 1.5, y: rect.midY - 1.5, width: 3, height: 3)), with: .color(Theme.skyDeep))
                }
            }
        }
        for point in model.current.absoluteCells where point.y >= 0 {
            let rect = CGRect(x: CGFloat(point.x) * cell, y: CGFloat(point.y) * cell, width: cell, height: cell)
            GiftPalette.drawGift(in: context, rect: rect, color: GiftPalette.color(model.current.kind))
        }
    }
}

struct NextPiecePreview: View {
    let kind: PieceKind

    var body: some View {
        VStack(spacing: 2) {
            Text("Suivant").font(Theme.font(.headline)).foregroundStyle(Theme.inkSoft)
            Canvas { context, size in
                let cell = size.width / 4
                for point in kind.cells {
                    let rect = CGRect(x: CGFloat(point.x + 1) * cell, y: CGFloat(point.y) * cell + cell / 2, width: cell, height: cell)
                    GiftPalette.drawGift(in: context, rect: rect, color: GiftPalette.color(kind))
                }
            }
            .frame(width: 72, height: 54)
        }
        .frame(width: 92)
    }
}
