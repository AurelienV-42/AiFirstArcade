import SpriteKit
import SwiftUI

final class SnowmanNode: SKNode {
    var direction: CGFloat = -1

    override init() {
        super.init()
        let bottom = PlatformerNodes.circle(radius: 14, color: .white)
        bottom.position.y = -8
        let top = PlatformerNodes.circle(radius: 10, color: .white)
        top.position.y = 12
        let nose = SKShapeNode(rectOf: CGSize(width: 9, height: 4), cornerRadius: 2)
        nose.fillColor = UIColor(Color(hex: 0xF5934A))
        nose.strokeColor = .clear
        nose.position = CGPoint(x: -7, y: 12)
        let eye = PlatformerNodes.circle(radius: 2, color: UIColor(Theme.ink))
        eye.position = CGPoint(x: -3, y: 16)
        [bottom, top, nose, eye].forEach(addChild)
    }

    required init?(coder: NSCoder) { nil }
}

enum PlatformerNodes {
    static func circle(radius: CGFloat, color: UIColor) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = color
        node.strokeColor = color == .white ? UIColor(Theme.skyDeep) : .clear
        node.lineWidth = 2
        return node
    }

    static func triangle(width: CGFloat, height: CGFloat, color: UIColor, pointingUp: Bool = true) -> SKShapeNode {
        let path = CGMutablePath()
        let tip: CGFloat = pointingUp ? height / 2 : -height / 2
        path.move(to: CGPoint(x: -width / 2, y: -tip))
        path.addLine(to: CGPoint(x: width / 2, y: -tip))
        path.addLine(to: CGPoint(x: 0, y: tip))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor = color
        node.strokeColor = .clear
        return node
    }

    static func star(radius: CGFloat, color: UIColor) -> SKShapeNode {
        let path = CGMutablePath()
        for index in 0..<10 {
            let length = index.isMultiple(of: 2) ? radius : radius * 0.45
            let angle = CGFloat(index) * .pi / 5 + .pi / 2
            let point = CGPoint(x: cos(angle) * length, y: sin(angle) * length)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.fillColor = color
        node.strokeColor = .clear
        return node
    }

    static func elf() -> SKNode {
        let sprite = SKNode()
        let body = SKShapeNode(rectOf: CGSize(width: 26, height: 22), cornerRadius: 8)
        body.fillColor = UIColor(Theme.green)
        body.strokeColor = .clear
        body.position.y = -9
        let head = circle(radius: 10, color: UIColor(Color(hex: 0xF6D2B4)))
        head.position.y = 8
        let hat = triangle(width: 24, height: 18, color: UIColor(Theme.red))
        hat.position = CGPoint(x: 0, y: 20)
        let eye = circle(radius: 2, color: UIColor(Theme.ink))
        eye.position = CGPoint(x: 4, y: 9)
        [body, head, hat, eye].forEach(sprite.addChild)
        return sprite
    }

    static func gift() -> SKNode {
        let node = SKNode()
        let box = SKShapeNode(rectOf: CGSize(width: 24, height: 22), cornerRadius: 5)
        box.fillColor = UIColor(Theme.red)
        box.strokeColor = .clear
        let ribbonV = SKSpriteNode(color: UIColor(Theme.gold), size: CGSize(width: 5, height: 22))
        let ribbonH = SKSpriteNode(color: UIColor(Theme.gold), size: CGSize(width: 24, height: 5))
        [box, ribbonV, ribbonH].forEach(node.addChild)
        node.run(.repeatForever(.sequence([.moveBy(x: 0, y: 5, duration: 0.6), .moveBy(x: 0, y: -5, duration: 0.6)])))
        return node
    }

    static func icicles() -> SKNode {
        let node = SKNode()
        for offset in [-12, 0, 12] as [CGFloat] {
            let spike = triangle(width: 14, height: 26, color: UIColor(Color(hex: 0x8FC6F0)))
            spike.position = CGPoint(x: offset, y: -9)
            node.addChild(spike)
        }
        return node
    }

    static func tree() -> SKNode {
        let node = SKNode()
        let trunk = SKSpriteNode(color: UIColor(Theme.woodDeep), size: CGSize(width: 8, height: 10))
        trunk.position.y = -17
        let leaves = triangle(width: 34, height: 34, color: UIColor(Theme.greenDeep))
        leaves.position.y = 2
        let top = star(radius: 8, color: UIColor(Theme.locked))
        top.position.y = 22
        top.name = "star"
        [trunk, leaves, top].forEach(node.addChild)
        return node
    }
}
