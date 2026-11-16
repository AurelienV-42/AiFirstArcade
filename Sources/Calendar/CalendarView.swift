import SwiftUI

struct CalendarView: View {
    @Environment(ProgressStore.self) private var store
    @State private var selected: AdventDay?
    @State private var pendingDay: AdventDay?
    @State private var shakes: [Int: CGFloat] = [:]
    @State private var toast: String?
    @State private var titleTaps: [Date] = []
    @State private var showCode = false
    @State private var showDevMenu = false

    var body: some View {
        ZStack(alignment: .top) {
            Theme.sky.ignoresSafeArea()
            SnowfallView(count: 30, color: .white.opacity(0.9)).ignoresSafeArea()
            path
            topBar
            toastView
        }
        .fullScreenCover(item: $selected) { day in DayFlowView(day: day) }
        .sheet(isPresented: $showCode, onDismiss: { if store.isDevMode { showDevMenu = true } }) {
            DevCodeView { store.isDevMode = true }
        }
        .sheet(isPresented: $showDevMenu, onDismiss: openPending) {
            DevMenuView { day in
                pendingDay = day
                showDevMenu = false
            }
        }
    }

    private var path: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 26) {
                    Text("Chaque jour de décembre, une case s'ouvre. Touche la case du jour !")
                        .font(Theme.font(.title3, weight: .semibold))
                        .foregroundStyle(Theme.inkSoft)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    ForEach(Array(AdventCalendar.days.enumerated()), id: \.element.id) { index, day in
                        node(for: day)
                            .offset(x: sin(Double(index) * 0.9) * 78)
                            .id(day.id)
                    }
                    Text("Joyeux Noël !")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.red)
                        .padding(.vertical, 30)
                }
                .padding(.top, 100)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
            }
            .onAppear { proxy.scrollTo(focusDay, anchor: .center) }
        }
    }

    private var focusDay: Int {
        DoorRules.decemberDay(now: .now).map { min($0, 24) } ?? 1
    }

    private func node(for day: AdventDay) -> some View {
        DoorNode(
            day: day,
            isOpen: store.isOpen(day.id),
            isToday: DoorRules.decemberDay(now: .now) == day.id,
            stars: store.stars[day.id],
            isRead: store.readDays.contains(day.id),
            action: { tap(day) }
        )
        .modifier(ShakeEffect(amount: 10, animatableData: shakes[day.id] ?? 0))
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Text("Avent Arcade")
                .font(Theme.font(.title2, weight: .heavy))
                .foregroundStyle(Theme.ink)
                .padding(.vertical, 10)
                .padding(.trailing, 24)
                .contentShape(Rectangle())
                .onTapGesture(perform: titleTapped)
            Spacer()
            if store.isDevMode {
                Button("DEV") { showDevMenu = true }
                    .font(Theme.font(.headline, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Capsule().fill(Theme.ink))
            }
            InfoPill(text: "★ \(store.totalStars)")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(Theme.sky.opacity(0.94).ignoresSafeArea(edges: .top))
    }

    private var toastView: some View {
        VStack {
            Spacer()
            if let toast {
                Text(toast)
                    .font(Theme.font(.title3))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Theme.ink))
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom, 30)
        .animation(.spring(response: 0.4), value: toast)
        .allowsHitTesting(false)
    }

    private func tap(_ day: AdventDay) {
        guard store.isOpen(day.id) else { return refuse(day) }
        Haptics.impact(.medium)
        selected = day
    }

    private func refuse(_ day: AdventDay) {
        Haptics.notify(.warning)
        withAnimation(.linear(duration: 0.4)) { shakes[day.id, default: 0] += 1 }
        let wait = DoorRules.daysUntilOpen(day: day.id, now: .now)
        switch wait {
        case 0: showToast("Cette case s'ouvrira en décembre.")
        case 1: showToast("Patience ! Cette case s'ouvre demain.")
        default: showToast("Patience ! Cette case s'ouvre dans \(wait) jours.")
        }
    }

    private func showToast(_ text: String) {
        toast = text
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if toast == text { toast = nil }
        }
    }

    private func titleTapped() {
        let now = Date()
        titleTaps = titleTaps.filter { now.timeIntervalSince($0) <= DoorRules.devTapWindow } + [now]
        guard DoorRules.shouldOpenDevPrompt(taps: titleTaps, now: now) else { return }
        titleTaps = []
        Haptics.impact(.rigid)
        if store.isDevMode { showDevMenu = true } else { showCode = true }
    }

    private func openPending() {
        guard let day = pendingDay else { return }
        pendingDay = nil
        selected = day
    }
}
