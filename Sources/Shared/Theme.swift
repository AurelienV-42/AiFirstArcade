import SwiftUI

enum Theme {
    static let sky = Color(hex: 0xDCEBF5)
    static let skyDeep = Color(hex: 0xB9D4E8)
    static let red = Color(hex: 0xF0645A)
    static let redDeep = Color(hex: 0xB8433B)
    static let green = Color(hex: 0x4FB27E)
    static let greenDeep = Color(hex: 0x2F7D53)
    static let blue = Color(hex: 0x5B8DEF)
    static let wood = Color(hex: 0xE2B07A)
    static let woodDeep = Color(hex: 0xB9834D)
    static let ink = Color(hex: 0x2B3A55)
    static let inkSoft = Color(hex: 0x5B6B86)
    static let gold = Color(hex: 0xF2B23E)
    static let night = Color(hex: 0x121A33)
    static let nightSoft = Color(hex: 0x24345F)
    static let locked = Color(hex: 0xC9D6E3)

    static func font(_ style: Font.TextStyle, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .rounded, weight: weight)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

struct ToyButtonStyle: ButtonStyle {
    var fill: Color = Theme.red
    var shadow: Color = Theme.redDeep
    var text: Color = .white
    var height: CGFloat = 64

    func makeBody(configuration: Configuration) -> some View {
        let depth: CGFloat = configuration.isPressed ? 1 : 6
        configuration.label
            .font(Theme.font(.title3))
            .foregroundStyle(text)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(fill))
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(shadow).offset(y: depth))
            .offset(y: 6 - depth)
            .padding(.bottom, 6)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Haptics.impact(.light) }
            }
    }
}

extension ButtonStyle where Self == ToyButtonStyle {
    static var toyRed: ToyButtonStyle { ToyButtonStyle() }
    static var toyGreen: ToyButtonStyle { ToyButtonStyle(fill: Theme.green, shadow: Theme.greenDeep) }
    static var toyWhite: ToyButtonStyle { ToyButtonStyle(fill: .white, shadow: Theme.wood, text: Theme.ink) }
}

struct RoundToyStyle: ButtonStyle {
    var fill: Color = .white
    var shadow: Color = Theme.wood
    var size: CGFloat = 76

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Theme.ink)
            .frame(width: size, height: size)
            .background(Circle().fill(fill))
            .background(Circle().fill(shadow).offset(y: configuration.isPressed ? 1 : 6))
            .offset(y: configuration.isPressed ? 5 : 0)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Haptics.impact(.light) }
            }
    }
}
