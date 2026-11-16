import SpriteKit
import SwiftUI

final class PongScene: SKScene {
    var onFinish: ((Int, Int) -> Void)?
    let twoPlayers: Bool
    let target: Int

    private static let ballRadius: CGFloat = 14
    private static let paddleSize = CGSize(width: 120, height: 24)
    private let startSpeed: CGFloat = 330
    private let maxSpeed: CGFloat = 720
    private let aiSpeed: CGFloat = 250

    private let ball = SKShapeNode(circleOfRadius: PongScene.ballRadius)
    private let bottomPaddle = PongScene.makePaddle(color: UIColor(Theme.red))
    private let topPaddle = PongScene.makePaddle(color: UIColor(Theme.green))
    private let bottomLabel = PongScene.makeLabel()
    private let topLabel = PongScene.makeLabel()
    private let centerLine = SKNode()
    private var velocity = CGVector.zero
    private var ballSpeed: CGFloat = 330
    private var bottomScore = 0
    private var topScore = 0
    private var lastUpdate: TimeInterval = 0
    private var serveTimer: TimeInterval = 1.2
    private var serveTowardBottom = true
    private var isFinished = false

    init(size: CGSize, twoPlayers: Bool, target: Int) {
        self.twoPlayers = twoPlayers
        self.target = target
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = UIColor(Theme.sky)
        ball.fillColor = .white
        ball.strokeColor = UIColor(Theme.skyDeep)
        ball.lineWidth = 3
        [centerLine, bottomLabel, topLabel, bottomPaddle, topPaddle, ball].forEach(addChild)
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = true
        layout()
        resetBall()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layout()
    }

    private func layout() {
        bottomPaddle.position = CGPoint(x: size.width / 2, y: 120)
        topPaddle.position = CGPoint(x: size.width / 2, y: size.height - 160)
        bottomLabel.position = CGPoint(x: 28, y: size.height / 2 - 80)
        topLabel.position = CGPoint(x: 28, y: size.height / 2 + 24)
        centerLine.removeAllChildren()
        for x in stride(from: CGFloat(12), to: size.width, by: 36) {
            let dash = SKSpriteNode(color: .white, size: CGSize(width: 18, height: 6))
            dash.position = CGPoint(x: x, y: size.height / 2)
            centerLine.addChild(dash)
        }
        updateLabels()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { follow(touches) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { follow(touches) }

    private func follow(_ touches: Set<UITouch>) {
        for touch in touches {
            let point = touch.location(in: self)
            if point.y < size.height / 2 {
                bottomPaddle.position.x = clampX(point.x)
            } else if twoPlayers {
                topPaddle.position.x = clampX(point.x)
            }
        }
    }

    private func clampX(_ x: CGFloat) -> CGFloat {
        min(max(x, Self.paddleSize.width / 2), size.width - Self.paddleSize.width / 2)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = CGFloat(lastUpdate == 0 ? 0 : min(currentTime - lastUpdate, 1.0 / 30))
        lastUpdate = currentTime
        guard !isFinished else { return }
        if !twoPlayers { moveAI(dt) }
        if serveTimer > 0 {
            serveTimer -= Double(dt)
            if serveTimer <= 0 { serve() }
            return
        }
        ball.position.x += velocity.dx * dt
        ball.position.y += velocity.dy * dt
        bounceOnWalls()
        bounce(on: bottomPaddle, goingUp: true)
        bounce(on: topPaddle, goingUp: false)
        checkScore()
    }

    private func moveAI(_ dt: CGFloat) {
        let goal = velocity.dy > 0 && serveTimer <= 0 ? ball.position.x : size.width / 2
        let diff = goal - topPaddle.position.x
        let step = min(abs(diff), aiSpeed * dt)
        topPaddle.position.x = clampX(topPaddle.position.x + (diff < 0 ? -step : step))
    }

    private func bounceOnWalls() {
        let radius = Self.ballRadius
        if ball.position.x < radius {
            ball.position.x = radius
            velocity.dx = abs(velocity.dx)
        } else if ball.position.x > size.width - radius {
            ball.position.x = size.width - radius
            velocity.dx = -abs(velocity.dx)
        }
    }

    private func bounce(on paddle: SKShapeNode, goingUp: Bool) {
        guard goingUp ? velocity.dy < 0 : velocity.dy > 0 else { return }
        let half = CGSize(width: Self.paddleSize.width / 2, height: Self.paddleSize.height / 2)
        let dx = ball.position.x - paddle.position.x
        let dy = ball.position.y - paddle.position.y
        guard abs(dx) <= half.width + Self.ballRadius, abs(dy) <= half.height + Self.ballRadius else { return }
        ballSpeed = min(ballSpeed * 1.07, maxSpeed)
        let angle = min(max(dx / half.width, -1), 1) * (.pi / 3)
        velocity = CGVector(dx: ballSpeed * sin(angle), dy: ballSpeed * cos(angle) * (goingUp ? 1 : -1))
        ball.position.y = paddle.position.y + (half.height + Self.ballRadius) * (goingUp ? 1 : -1)
        Haptics.impact(.rigid)
        paddle.run(.sequence([.scale(to: 1.12, duration: 0.06), .scale(to: 1, duration: 0.1)]))
    }

    private func checkScore() {
        if ball.position.y < -Self.ballRadius * 2 {
            point(forBottom: false)
        } else if ball.position.y > size.height + Self.ballRadius * 2 {
            point(forBottom: true)
        }
    }

    private func point(forBottom: Bool) {
        if forBottom { bottomScore += 1 } else { topScore += 1 }
        Haptics.notify(forBottom || twoPlayers ? .success : .error)
        updateLabels()
        serveTowardBottom = !forBottom
        resetBall()
        if max(bottomScore, topScore) >= target { finish() }
    }

    private func resetBall() {
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        velocity = .zero
        ballSpeed = startSpeed
        serveTimer = 1.2
    }

    private func serve() {
        let angle = CGFloat.random(in: -0.4...0.4)
        velocity = CGVector(dx: ballSpeed * sin(angle), dy: ballSpeed * cos(angle) * (serveTowardBottom ? -1 : 1))
    }

    private func finish() {
        isFinished = true
        run(.wait(forDuration: 0.6)) { [weak self] in
            guard let self else { return }
            self.onFinish?(self.bottomScore, self.topScore)
        }
    }

    private func updateLabels() {
        bottomLabel.text = "\(bottomScore)"
        topLabel.text = "\(topScore)"
    }

    private static func makePaddle(color: UIColor) -> SKShapeNode {
        let paddle = SKShapeNode(rectOf: paddleSize, cornerRadius: 12)
        paddle.fillColor = color
        paddle.strokeColor = .clear
        return paddle
    }

    private static func makeLabel() -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.fontSize = 64
        label.fontColor = UIColor(Theme.ink).withAlphaComponent(0.35)
        label.horizontalAlignmentMode = .left
        return label
    }
}
