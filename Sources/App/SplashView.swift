import SwiftUI

struct SplashView: View {
    let isShort: Bool
    let onFinish: () -> Void
    @State private var taps = 0
    @State private var shake: CGFloat = 0
    @State private var isOpen = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.nightSoft, Theme.night], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            SnowfallView(count: 70, color: .white.opacity(0.8))
                .ignoresSafeArea()
            Circle()
                .fill(Theme.gold.opacity(0.6))
                .frame(width: 80, height: 80)
                .blur(radius: 30)
                .scaleEffect(isOpen ? 14 : 0.01)
                .opacity(isOpen ? 0 : 1)
            content
        }
        .task { await autoOpenIfShort() }
    }

    private var content: some View {
        VStack(spacing: 36) {
            Text("Avent Arcade")
                .font(.system(size: 46, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            GiftView(isOpen: isOpen)
                .scaleEffect(1 + CGFloat(taps) * 0.07)
                .modifier(ShakeEffect(amount: 4 + CGFloat(taps) * 5, animatableData: shake))
                .contentShape(Rectangle())
                .onTapGesture(perform: tapGift)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel("Ouvrir le cadeau")
            hint
        }
    }

    private var hint: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index < taps ? Theme.gold : .clear)
                        .overlay(Circle().stroke(Theme.gold, lineWidth: 3))
                        .frame(width: 18, height: 18)
                }
            }
            Text("Touche 3 fois le cadeau")
                .font(Theme.font(.title3, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .opacity(isOpen || isShort ? 0 : 1)
    }

    private func tapGift() {
        guard !isOpen else { return }
        taps += 1
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy]
        Haptics.impact(styles[min(taps, 3) - 1])
        withAnimation(.linear(duration: 0.4)) { shake += 1 }
        if taps >= 3 { open() }
    }

    private func open() {
        Haptics.burst()
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) { isOpen = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            onFinish()
        }
    }

    private func autoOpenIfShort() async {
        guard isShort else { return }
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard !isOpen else { return }
        taps = 3
        open()
    }
}

struct GiftView: View {
    let isOpen: Bool

    var body: some View {
        ZStack {
            Image(systemName: "star.fill")
                .font(.system(size: 90))
                .foregroundStyle(Theme.gold)
                .shadow(color: Theme.gold, radius: 20)
                .offset(y: isOpen ? -120 : 20)
                .scaleEffect(isOpen ? 1.3 : 0.2)
                .opacity(isOpen ? 1 : 0)
            box
            lid
                .offset(y: isOpen ? -260 : -78)
                .rotationEffect(.degrees(isOpen ? -35 : 0))
                .opacity(isOpen ? 0 : 1)
        }
        .frame(width: 210, height: 230)
    }

    private var box: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.red)
            Rectangle().fill(Theme.gold).frame(width: 28)
        }
        .frame(width: 170, height: 140)
        .offset(y: 30)
    }

    private var lid: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.redDeep)
            Rectangle().fill(Theme.gold).frame(width: 28)
            bow.offset(y: -34)
        }
        .frame(width: 196, height: 46)
        .offset(y: 30)
    }

    private var bow: some View {
        HStack(spacing: 2) {
            Ellipse().stroke(Theme.gold, lineWidth: 9).frame(width: 46, height: 30).rotationEffect(.degrees(-20))
            Ellipse().stroke(Theme.gold, lineWidth: 9).frame(width: 46, height: 30).rotationEffect(.degrees(20))
        }
    }
}
