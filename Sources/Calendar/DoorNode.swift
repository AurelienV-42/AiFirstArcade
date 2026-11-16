import SwiftUI

struct DoorNode: View {
    let day: AdventDay
    let isOpen: Bool
    let isToday: Bool
    let stars: Int?
    let isRead: Bool
    let action: () -> Void
    @State private var pulse = false

    private var size: CGFloat { day.isGame ? 124 : 92 }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                bubble
                caption
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOpen ? "Jour \(day.id), \(day.title)" : "Jour \(day.id), fermé")
    }

    private var bubble: some View {
        ZStack {
            Circle().fill(shadowColor).offset(y: 7)
            Circle().fill(fillColor)
            if isToday && isOpen {
                Circle()
                    .stroke(Theme.gold, lineWidth: 6)
                    .scaleEffect(pulse ? 1.25 : 1.02)
                    .opacity(pulse ? 0 : 1)
            }
            label
            if day.isGame { gameBadge }
        }
        .frame(width: size, height: size)
        .onAppear {
            guard isToday else { return }
            withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) { pulse = true }
        }
    }

    @ViewBuilder private var label: some View {
        if isOpen {
            VStack(spacing: 0) {
                Text(verbatim: "\(day.id)")
                    .font(.system(size: day.isGame ? 50 : 38, weight: .heavy, design: .rounded))
                if !day.isGame && isRead {
                    Image(systemName: "checkmark").font(.system(size: 16, weight: .black))
                }
            }
            .foregroundStyle(day.isGame ? .white : Theme.ink)
        } else {
            VStack(spacing: 2) {
                Image(systemName: "lock.fill").font(.system(size: 20, weight: .bold))
                Text(verbatim: "\(day.id)").font(.system(size: 28, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(Theme.inkSoft)
        }
    }

    private var gameBadge: some View {
        Text("JEU")
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Capsule().fill(Theme.gold))
            .offset(y: -size / 2)
    }

    private var caption: some View {
        VStack(spacing: 4) {
            Text(isOpen ? day.title : "Le \(day.id == 1 ? "1er" : String(day.id)) décembre")
                .font(Theme.font(.title3, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
            if day.isGame, let stars {
                StarsRow(count: stars, size: 20)
            }
        }
        .frame(width: 200)
    }

    private var fillColor: Color {
        guard isOpen else { return Theme.locked }
        return day.isGame ? Theme.red : .white
    }

    private var shadowColor: Color {
        guard isOpen else { return Theme.skyDeep }
        return day.isGame ? Theme.redDeep : Theme.wood
    }
}
