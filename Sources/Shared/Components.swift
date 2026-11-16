import SwiftUI

struct GridPoint: Hashable {
    var x: Int
    var y: Int
}

struct GameOutcome: Equatable {
    let stars: Int
    let title: String
    let detail: String
    var showsStars = true
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * 4), y: 0))
    }
}

struct StarsRow: View {
    let count: Int
    var size: CGFloat = 24

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < count ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(index < count ? Theme.gold : Theme.inkSoft.opacity(0.4))
                    .scaleEffect(index < count ? 1 : 0.85)
            }
        }
        .accessibilityLabel("\(count) étoiles sur 3")
    }
}

struct CircleIconButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .bold))
        }
        .buttonStyle(RoundToyStyle(size: 60))
        .accessibilityLabel(label)
    }
}

struct ListenButton: View {
    let text: String

    var body: some View {
        Button {
            Speaker.shared.say(text)
        } label: {
            Label("Écouter", systemImage: "speaker.wave.2.fill")
                .font(Theme.font(.title3))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 20)
                .frame(height: 60)
                .background(Capsule().fill(.white))
                .background(Capsule().fill(Theme.wood).offset(y: 5))
        }
    }
}

struct HoldButton: View {
    let systemName: String
    let label: String
    var size: CGFloat = 76
    var fill: Color = .white
    var shadow: Color = Theme.wood
    var tint: Color = Theme.ink
    let onChange: (Bool) -> Void
    @State private var isPressed = false

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.4, weight: .heavy))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(Circle().fill(fill))
            .background(Circle().fill(shadow).offset(y: isPressed ? 1 : 6))
            .offset(y: isPressed ? 5 : 0)
            .contentShape(Circle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in press(true) }
                .onEnded { _ in press(false) })
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
    }

    private func press(_ pressed: Bool) {
        guard pressed != isPressed else { return }
        isPressed = pressed
        if pressed { Haptics.impact(.light) }
        onChange(pressed)
    }
}

struct PauseOverlay: View {
    let onResume: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 18) {
                Text("Pause")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Button("Reprendre", action: onResume).buttonStyle(.toyGreen)
                Button("Quitter le jeu", action: onQuit).buttonStyle(.toyWhite)
            }
            .padding(28)
            .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(Theme.sky))
            .padding(30)
        }
    }
}

struct InfoPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.font(.title3, weight: .heavy))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Capsule().fill(.white.opacity(0.92)))
    }
}
