import SwiftUI

struct BravoView: View {
    let day: AdventDay
    let outcome: GameOutcome
    let onReplay: () -> Void
    let onDone: () -> Void
    @State private var shownStars = 0

    var body: some View {
        ZStack {
            if outcome.stars > 0 || !outcome.showsStars {
                ConfettiView().ignoresSafeArea()
            }
            VStack(spacing: 22) {
                Spacer()
                if outcome.showsStars {
                    StarsRow(count: shownStars, size: 56)
                        .animation(.spring(response: 0.35, dampingFraction: 0.5), value: shownStars)
                }
                Text(outcome.title)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                Text(outcome.detail)
                    .font(Theme.font(.title2, weight: .semibold))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                teaser
                Spacer()
                Button("Retour au calendrier", action: onDone).buttonStyle(.toyRed)
                Button("Rejouer", action: onReplay).buttonStyle(.toyWhite)
            }
            .padding(24)
        }
        .task { await revealStars() }
    }

    private var teaser: some View {
        VStack(spacing: 6) {
            Text(day.id == 24 ? "JOYEUX NOËL" : "DEMAIN")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(Theme.red)
            Text(day.id == 24 ? "Merci d'avoir joué pendant tout le mois de décembre !" : day.teaser)
                .font(Theme.font(.title3, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Theme.inkSoft.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [8, 6])))
    }

    private func revealStars() async {
        guard outcome.showsStars, outcome.stars > 0 else { return }
        for index in 1...outcome.stars {
            try? await Task.sleep(nanoseconds: 450_000_000)
            shownStars = index
            Haptics.impact(.heavy)
        }
        if outcome.stars == 3 { Haptics.burst() }
    }
}
