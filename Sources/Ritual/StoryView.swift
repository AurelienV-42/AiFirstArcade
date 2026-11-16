import SwiftUI

struct StoryView: View {
    let day: AdventDay
    let onContinue: () -> Void
    let onClose: () -> Void
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                CircleIconButton(systemName: "xmark", label: "Fermer", action: onClose)
                Spacer()
                ListenButton(text: "\(day.title). \(day.bridge) \(day.fact)")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    illustration
                    Text(day.bridge)
                        .font(Theme.font(.title2, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text(day.fact)
                        .font(Theme.font(.title3, weight: .regular))
                        .foregroundStyle(Theme.inkSoft)
                }
                .padding(24)
            }
            Button(day.isGame ? "Continuer" : "J'ai compris", action: onContinue)
                .buttonStyle(.toyRed)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Jour \(day.id) · \(day.genre)")
                .font(Theme.font(.title3, weight: .semibold))
                .foregroundStyle(Theme.inkSoft)
            Text(verbatim: String(day.year))
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.red)
            Text(day.title)
                .font(Theme.font(.largeTitle, weight: .heavy))
                .foregroundStyle(Theme.ink)
            Text("D'après \(day.origin)")
                .font(Theme.font(.title3, weight: .medium))
                .foregroundStyle(Theme.inkSoft)
        }
    }

    private var illustration: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Theme.wood).offset(y: 6)
            RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.white)
            Image(systemName: day.symbol)
                .font(.system(size: 84, weight: .bold))
                .foregroundStyle(day.isGame ? Theme.red : Theme.green)
                .offset(y: bounce ? -10 : 10)
        }
        .frame(height: 180)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { bounce = true }
        }
    }
}
