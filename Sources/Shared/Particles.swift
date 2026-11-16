import SwiftUI

struct SnowfallView: View {
    var count = 40
    var color: Color = .white

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for index in 0..<count {
                    context.fill(Path(ellipseIn: Self.flake(index: index, time: time, size: size)), with: .color(color))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private static func flake(index: Int, time: Double, size: CGSize) -> CGRect {
        let seed = Double(index) * 97.31
        let radius = 1.5 + seed.truncatingRemainder(dividingBy: 3.5)
        let speed = 22 + (seed * 7).truncatingRemainder(dividingBy: 40)
        let baseX = (seed * 13).truncatingRemainder(dividingBy: max(size.width, 1))
        let y = (time * speed + seed * 31).truncatingRemainder(dividingBy: size.height + 20) - 10
        let x = baseX + sin(time * 0.8 + seed) * 12
        return CGRect(x: x, y: y, width: radius * 2, height: radius * 2)
    }
}

struct ConfettiView: View {
    @State private var start = Date()
    private let colors: [Color] = [Theme.red, Theme.green, Theme.gold, Theme.blue, .white]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSince(start)
                for index in 0..<90 {
                    drawPiece(index: index, elapsed: elapsed, size: size, context: context)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func drawPiece(index: Int, elapsed: Double, size: CGSize, context: GraphicsContext) {
        let seed = Double(index) * 53.7
        let speed = 150 + (seed * 3).truncatingRemainder(dividingBy: 170)
        let y = -20 - seed.truncatingRemainder(dividingBy: 400) + elapsed * speed
        guard y < size.height + 20 else { return }
        let x = (seed * 11).truncatingRemainder(dividingBy: max(size.width, 1)) + sin(elapsed * 2 + seed) * 20
        var piece = context
        piece.translateBy(x: x, y: y)
        piece.rotate(by: .degrees(elapsed * 200 + seed))
        piece.fill(Path(CGRect(x: -5, y: -8, width: 10, height: 16)), with: .color(colors[index % colors.count]))
    }
}
