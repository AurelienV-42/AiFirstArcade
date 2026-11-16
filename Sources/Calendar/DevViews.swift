import SwiftUI

struct DevCodeView: View {
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var shake: CGFloat = 0

    private let keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "⌫"]

    var body: some View {
        VStack(spacing: 24) {
            Text("Code développeur")
                .font(Theme.font(.title2, weight: .heavy))
                .foregroundStyle(Theme.ink)
            dots.modifier(ShakeEffect(amount: 12, animatableData: shake))
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(keys, id: \.self) { key in keyButton(key) }
            }
            Button("Annuler") { dismiss() }
                .font(Theme.font(.title3, weight: .semibold))
                .foregroundStyle(Theme.inkSoft)
        }
        .padding(28)
        .frame(maxHeight: .infinity)
        .background(Theme.sky)
    }

    private var dots: some View {
        HStack(spacing: 12) {
            ForEach(0..<DoorRules.devCode.count, id: \.self) { index in
                Circle()
                    .fill(index < code.count ? Theme.ink : .clear)
                    .overlay(Circle().stroke(Theme.ink, lineWidth: 2))
                    .frame(width: 18, height: 18)
            }
        }
    }

    @ViewBuilder private func keyButton(_ key: String) -> some View {
        if key.isEmpty {
            Color.clear.frame(height: 76)
        } else {
            Button { press(key) } label: {
                Text(key).font(.system(size: 30, weight: .bold, design: .rounded))
            }
            .buttonStyle(RoundToyStyle(size: 76))
        }
    }

    private func press(_ key: String) {
        if key == "⌫" {
            code = String(code.dropLast())
            return
        }
        guard code.count < DoorRules.devCode.count else { return }
        code += key
        if code.count == DoorRules.devCode.count { validate() }
    }

    private func validate() {
        if DoorRules.isValidDevCode(code) {
            Haptics.notify(.success)
            onSuccess()
            dismiss()
        } else {
            Haptics.notify(.error)
            withAnimation(.linear(duration: 0.4)) { shake += 1 }
            code = ""
        }
    }
}

struct DevMenuView: View {
    let onOpen: (AdventDay) -> Void
    @Environment(ProgressStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Menu dev")
                    .font(Theme.font(.largeTitle, weight: .heavy))
                    .foregroundStyle(Theme.ink)
                Text("Touche une case pour l'ouvrir tout de suite.")
                    .font(Theme.font(.title3, weight: .semibold))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                grid
                Button("Ouvrir toutes les cases") { store.devOpenAll() }.buttonStyle(.toyGreen)
                Button("Tout remettre à zéro") { store.resetAll() }.buttonStyle(.toyWhite)
                Button("Quitter le mode dev") {
                    store.isDevMode = false
                    dismiss()
                }
                .buttonStyle(.toyRed)
            }
            .padding(24)
        }
        .background(Theme.sky)
    }

    private var grid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(AdventCalendar.days) { day in
                Button {
                    store.devOpen(day.id)
                    onOpen(day)
                } label: {
                    Text(verbatim: "\(day.id)")
                }
                .buttonStyle(day.isGame ? ToyButtonStyle() : ToyButtonStyle(fill: .white, shadow: Theme.wood, text: Theme.ink))
            }
        }
    }
}
