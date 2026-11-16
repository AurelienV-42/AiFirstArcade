import SwiftUI

struct RPGCombatView: View {
    let state: CombatState
    let onAction: (CombatAction) -> Void
    let onEnd: () -> Void
    @State private var enemyHits: CGFloat = 0
    @State private var heroHits: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.nightSoft, Theme.night], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                enemyPanel
                Text(state.log)
                    .font(Theme.font(.title3, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 60)
                heroPanel
                Spacer(minLength: 0)
                actions
            }
            .padding(20)
        }
        .onChange(of: state.enemyHP) { _, _ in withAnimation(.linear(duration: 0.4)) { enemyHits += 1 } }
        .onChange(of: state.hero.hp) { old, new in
            guard new < old else { return }
            withAnimation(.linear(duration: 0.4)) { heroHits += 1 }
        }
    }

    private var enemyPanel: some View {
        VStack(spacing: 10) {
            Text(state.enemy.name)
                .font(Theme.font(.title2, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(state.enemy.emoji)
                .font(.system(size: 120))
                .modifier(ShakeEffect(amount: 16, animatableData: enemyHits))
                .opacity(state.enemyHP == 0 ? 0.3 : 1)
            StatBar(label: "Vie : \(state.enemyHP)/\(state.enemy.maxHP)", value: state.enemyHP, maximum: state.enemy.maxHP, color: Theme.red, labelColor: .white)
        }
    }

    private var heroPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🧝 Toi · niveau \(state.hero.level)")
                .font(Theme.font(.title3, weight: .heavy))
                .foregroundStyle(Theme.ink)
            StatBar(label: "❤️ Vie : \(state.hero.hp)/\(state.hero.maxHP)", value: state.hero.hp, maximum: state.hero.maxHP, color: Theme.green, labelColor: Theme.ink)
            StatBar(label: "✨ Magie : \(state.hero.mp)/\(state.hero.maxMP)", value: state.hero.mp, maximum: state.hero.maxMP, color: Theme.blue, labelColor: Theme.ink)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.white))
        .modifier(ShakeEffect(amount: 12, animatableData: heroHits))
    }

    @ViewBuilder private var actions: some View {
        switch state.phase {
        case .heroTurn, .enemyTurn:
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                actionButton(.attack, title: "⚔️ Attaquer")
                actionButton(.snowball, title: "❄️ Boule de neige")
                actionButton(.cocoa, title: "☕️ Chocolat (\(state.cocoa))")
                actionButton(.flee, title: "🏃 Fuir")
            }
        case .won, .lost, .fled:
            Button("Continuer", action: onEnd).buttonStyle(.toyGreen)
        }
    }

    private func actionButton(_ action: CombatAction, title: String) -> some View {
        Button(title) { onAction(action) }
            .buttonStyle(ToyButtonStyle(fill: .white, shadow: Theme.wood, text: Theme.ink, height: 70))
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .disabled(!state.canUse(action))
            .opacity(state.canUse(action) ? 1 : 0.45)
    }
}

struct StatBar: View {
    let label: String
    let value: Int
    let maximum: Int
    let color: Color
    let labelColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Theme.font(.headline))
                .foregroundStyle(labelColor)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.locked)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / CGFloat(max(maximum, 1)))
                }
            }
            .frame(height: 14)
        }
        .animation(.easeOut(duration: 0.3), value: value)
    }
}
