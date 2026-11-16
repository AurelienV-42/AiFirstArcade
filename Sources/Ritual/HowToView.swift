import SwiftUI

struct HowToView: View {
    let game: GameKind
    let onPlay: (Bool) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                CircleIconButton(systemName: "xmark", label: "Fermer", action: onClose)
                Spacer()
                ListenButton(text: "\(instructions) Objectif : \(goal)")
            }
            Text("Comment jouer")
                .font(Theme.font(.largeTitle, weight: .heavy))
                .foregroundStyle(Theme.ink)
            HandDemo(game: game).frame(height: 190)
            Text(instructions)
                .font(Theme.font(.title2, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                StarsRow(count: 3, size: 22)
                Text(goal)
                    .font(Theme.font(.title3))
                    .foregroundStyle(Theme.inkSoft)
            }
            Spacer(minLength: 0)
            buttons
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    @ViewBuilder private var buttons: some View {
        if game == .pong {
            Button("Jouer seul") { onPlay(false) }.buttonStyle(.toyRed)
            Button("Jouer à deux sur ce téléphone") { onPlay(true) }.buttonStyle(.toyGreen)
        } else {
            Button("Jouer") { onPlay(false) }.buttonStyle(.toyRed)
        }
    }

    private var instructions: String {
        switch game {
        case .pong: "Pose ton doigt en bas de l'écran et glisse à gauche ou à droite : ta raquette rouge suit ton doigt."
        case .blocks: "Les flèches déplacent le paquet. Le bouton du milieu le fait tourner. Remplis une ligne entière pour l'effacer."
        case .platformer: "Les flèches font marcher le lutin. Le gros bouton vert le fait sauter. Saute sur les bonshommes de neige !"
        case .rpg: "Les flèches font marcher ton héros. Marche vers quelqu'un pour lui parler, ou vers un monstre pour le combattre."
        }
    }

    private var goal: String {
        switch game {
        case .pong: "Marque 7 points avant l'ordinateur."
        case .blocks: "Efface 15 lignes."
        case .platformer: "Traverse les 4 niveaux et ramasse les cadeaux."
        case .rpg: "Retrouve l'étoile du sapin, volée par le Krampus."
        }
    }
}

struct HandDemo: View {
    let game: GameKind
    @State private var phase = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Theme.wood).offset(y: 6)
            RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.white)
            if game == .pong { pongDemo } else { buttonsDemo }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { phase = true }
        }
    }

    private var pongDemo: some View {
        ZStack {
            Circle().fill(Theme.skyDeep).frame(width: 26).offset(x: phase ? -60 : 60, y: phase ? 20 : -50)
            Capsule().fill(Theme.red).frame(width: 110, height: 22).offset(x: phase ? 80 : -80, y: 40)
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 54))
                .foregroundStyle(Theme.ink)
                .offset(x: phase ? 95 : -65, y: 92)
        }
    }

    private var buttonsDemo: some View {
        HStack(spacing: 18) {
            ForEach(symbols, id: \.self) { symbol in
                Image(systemName: symbol)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 70, height: 70)
                    .background(Circle().fill(Theme.sky))
            }
        }
        .overlay {
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 50))
                .foregroundStyle(Theme.ink)
                .offset(x: phase ? 100 : -70, y: 58)
        }
    }

    private var symbols: [String] {
        switch game {
        case .blocks: ["arrow.left", "arrow.clockwise", "arrow.right"]
        case .platformer: ["arrow.left", "arrow.right", "arrow.up"]
        default: ["arrow.left", "arrow.up", "arrow.right"]
        }
    }
}
