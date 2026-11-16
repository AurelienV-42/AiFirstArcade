import SwiftUI

@main
struct AiFirstArcadeApp: App {
    @State private var store = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @Environment(ProgressStore.self) private var store
    @State private var showSplash = true

    var body: some View {
        ZStack {
            CalendarView()
            if showSplash {
                SplashView(isShort: store.hasSeenSplash, onFinish: finishSplash)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .statusBarHidden(showSplash)
    }

    private func finishSplash() {
        store.hasSeenSplash = true
        withAnimation(.easeInOut(duration: 0.6)) { showSplash = false }
    }
}
