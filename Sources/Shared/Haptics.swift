import CoreHaptics
import UIKit

enum Haptics {
    private static var engine: CHHapticEngine?

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1) {
        UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: intensity)
    }

    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    static func burst() {
        play(times: [0, 0.06, 0.12, 0.2, 0.3, 0.42, 0.56], intensities: [1, 0.85, 0.7, 0.6, 0.5, 0.4, 0.3])
    }

    static func heartbeat() {
        play(times: [0, 0.16, 0.7, 0.86], intensities: [0.9, 0.55, 0.9, 0.55])
    }

    private static func play(times: [Double], intensities: [Float]) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let events = zip(times, intensities).map { time, value in
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: value),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ], relativeTime: time)
            }
            let player = try readyEngine().makePlayer(with: CHHapticPattern(events: events, parameters: []))
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            engine = nil
        }
    }

    private static func readyEngine() throws -> CHHapticEngine {
        if let engine { return engine }
        let created = try CHHapticEngine()
        created.isAutoShutdownEnabled = true
        created.resetHandler = { try? created.start() }
        try created.start()
        engine = created
        return created
    }
}
