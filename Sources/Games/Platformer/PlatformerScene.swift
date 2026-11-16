import SpriteKit
import SwiftUI

struct PlatformerInput {
    var left = false
    var right = false
    var jumpQueued = false
}

final class PlatformerScene: SKScene {
    static let tile: CGFloat = 44
    var input = PlatformerInput()
    var onLevelStart: ((Int) -> Void)?
    var onGift: ((Int) -> Void)?
    var onFinish: ((Int, Int) -> Void)?

    private let levels = PlatformerLevels.all
    private var levelIndex = 0
    private var level: PlatformerLevel { levels[levelIndex] }
    private let world = SKNode()
    private let cam = SKCameraNode()
    private let player = SKNode()
    private let playerSprite = PlatformerNodes.elf()
    private var enemies: [SnowmanNode] = []
    private var gifts: [SKNode] = []
    private var spikes: [SKNode] = []
    private var flags: [SKNode] = []
    private var goal = SKNode()
    private var respawnPoint = CGPoint.zero
    private var collected = 0
    private var lastUpdate: TimeInterval = 0
    private var coyote: TimeInterval = 0
    private var jumpBuffer: TimeInterval = 0
    private var fallSpeed: CGFloat = 0
    private var invulnerable: TimeInterval = 0
    private var isTransitioning = false
    private var hasStarted = false

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = UIColor(Theme.sky)
        player.addChild(playerSprite)
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 24, height: 40))
        body.allowsRotation = false
        body.friction = 0
        body.restitution = 0
        body.linearDamping = 0
        player.physicsBody = body
    }

    required init?(coder: NSCoder) { nil }

    private var totalGifts: Int { levels.reduce(0) { $0 + $1.gifts.count } }

    override func didMove(to view: SKView) {
        guard !hasStarted else { return }
        hasStarted = true
        physicsWorld.gravity = CGVector(dx: 0, dy: -14)
        addChild(world)
        addChild(cam)
        camera = cam
        load(level: 0)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.height > 0 else { return }
        cam.setScale(CGFloat(PlatformerLevel.height) * Self.tile / size.height)
    }

    private func load(level index: Int) {
        levelIndex = index
        world.removeAllChildren()
        buildTiles()
        gifts = level.gifts.map { add(PlatformerNodes.gift(), at: $0) }
        enemies = level.enemies.map { add(SnowmanNode(), at: $0) }
        spikes = level.spikes.map { add(PlatformerNodes.icicles(), at: $0) }
        flags = level.checkpoints.map { add(PlatformerNodes.tree(), at: $0) }
        goal = add(PlatformerNodes.star(radius: 22, color: UIColor(Theme.gold)), at: level.goal)
        goal.run(.repeatForever(.rotate(byAngle: .pi, duration: 2)))
        respawnPoint = position(of: level.start)
        player.position = respawnPoint
        player.physicsBody?.velocity = .zero
        world.addChild(player)
        didChangeSize(size)
        isTransitioning = false
        onLevelStart?(index)
    }

    @discardableResult
    private func add<Node: SKNode>(_ node: Node, at point: GridPoint) -> Node {
        node.position = position(of: point)
        world.addChild(node)
        return node
    }

    private func position(of point: GridPoint) -> CGPoint {
        CGPoint(x: (CGFloat(point.x) + 0.5) * Self.tile, y: (CGFloat(point.y) + 0.5) * Self.tile)
    }

    private func buildTiles() {
        for y in 0..<PlatformerLevel.height {
            var x = 0
            while x < level.width {
                guard level.isSolid(GridPoint(x: x, y: y)) else {
                    x += 1
                    continue
                }
                var end = x
                while end + 1 < level.width && level.isSolid(GridPoint(x: end + 1, y: y)) { end += 1 }
                addRun(from: x, to: end, y: y)
                x = end + 1
            }
        }
    }

    private func addRun(from start: Int, to end: Int, y: Int) {
        let count = CGFloat(end - start + 1)
        let runSize = CGSize(width: count * Self.tile, height: Self.tile)
        let run = SKSpriteNode(color: UIColor(Theme.woodDeep), size: runSize)
        run.position = CGPoint(x: (CGFloat(start) + count / 2) * Self.tile, y: (CGFloat(y) + 0.5) * Self.tile)
        run.physicsBody = SKPhysicsBody(rectangleOf: runSize)
        run.physicsBody?.isDynamic = false
        run.physicsBody?.friction = 0
        world.addChild(run)
        for x in start...end where !level.isSolid(GridPoint(x: x, y: y + 1)) {
            let snow = SKShapeNode(rectOf: CGSize(width: Self.tile + 2, height: 12), cornerRadius: 6)
            snow.fillColor = .white
            snow.strokeColor = .clear
            snow.position = CGPoint(x: (CGFloat(x) + 0.5) * Self.tile, y: (CGFloat(y) + 1) * Self.tile - 4)
            world.addChild(snow)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdate == 0 ? 1.0 / 60 : min(currentTime - lastUpdate, 1.0 / 30)
        lastUpdate = currentTime
        guard hasStarted, !isTransitioning, let body = player.physicsBody else { return }
        invulnerable = max(0, invulnerable - dt)
        movePlayer(body, dt: dt)
        moveEnemies(dt: CGFloat(dt))
        checkPickups()
        checkDangers(body)
        followCamera()
    }

    private func movePlayer(_ body: SKPhysicsBody, dt: TimeInterval) {
        let direction: CGFloat = (input.right ? 1 : 0) - (input.left ? 1 : 0)
        body.velocity.dx = direction * 210
        if direction != 0 { playerSprite.xScale = direction }
        let grounded = isGrounded(body)
        if grounded && fallSpeed < -650 { Haptics.impact(.medium) }
        fallSpeed = grounded ? 0 : min(fallSpeed, body.velocity.dy)
        coyote = grounded ? 0.12 : max(0, coyote - dt)
        if input.jumpQueued {
            jumpBuffer = 0.15
            input.jumpQueued = false
        } else {
            jumpBuffer = max(0, jumpBuffer - dt)
        }
        guard jumpBuffer > 0, coyote > 0 else { return }
        body.velocity.dy = 790
        jumpBuffer = 0
        coyote = 0
    }

    private func isGrounded(_ body: SKPhysicsBody) -> Bool {
        guard body.velocity.dy < 20 else { return false }
        let feet = player.position.y - 22
        return [-10, 10].contains { (offset: CGFloat) in
            guard let found = physicsWorld.body(at: CGPoint(x: player.position.x + offset, y: feet)) else { return false }
            return found !== body
        }
    }

    private func moveEnemies(dt: CGFloat) {
        for enemy in enemies {
            let ahead = GridPoint(x: Int(floor((enemy.position.x + enemy.direction * 18) / Self.tile)), y: Int(floor(enemy.position.y / Self.tile)))
            let below = GridPoint(x: ahead.x, y: ahead.y - 1)
            if level.isSolid(ahead) || !level.isSolid(below) { enemy.direction *= -1 }
            enemy.position.x += enemy.direction * 55 * dt
            enemy.xScale = enemy.direction < 0 ? 1 : -1
        }
    }

    private var playerFrame: CGRect {
        CGRect(x: player.position.x - 12, y: player.position.y - 20, width: 24, height: 40)
    }

    private func box(around node: SKNode, size: CGFloat) -> CGRect {
        CGRect(x: node.position.x - size / 2, y: node.position.y - size / 2, width: size, height: size)
    }

    private func checkPickups() {
        let frame = playerFrame
        let hits = gifts.filter { frame.intersects(box(around: $0, size: 30)) }
        gifts.removeAll { gift in hits.contains { $0 === gift } }
        hits.forEach(collect)
        for flag in flags where flag.name != "on" && frame.intersects(box(around: flag, size: 40)) {
            activate(flag)
        }
        if frame.intersects(box(around: goal, size: 40)) { completeLevel() }
    }

    private func collect(_ gift: SKNode) {
        collected += 1
        onGift?(collected)
        Haptics.impact(.light)
        gift.removeAllActions()
        gift.run(.sequence([.group([.scale(to: 1.8, duration: 0.2), .fadeOut(withDuration: 0.2)]), .removeFromParent()]))
    }

    private func activate(_ flag: SKNode) {
        flag.name = "on"
        (flag.childNode(withName: "star") as? SKShapeNode)?.fillColor = UIColor(Theme.gold)
        respawnPoint = CGPoint(x: flag.position.x, y: flag.position.y + 4)
        Haptics.notify(.success)
    }

    private func checkDangers(_ body: SKPhysicsBody) {
        guard invulnerable == 0 else { return }
        if player.position.y < -80 { return hurt(body) }
        let frame = playerFrame
        if spikes.contains(where: { frame.intersects(CGRect(x: $0.position.x - 18, y: $0.position.y - 22, width: 36, height: 20)) }) {
            return hurt(body)
        }
        for enemy in enemies where frame.intersects(box(around: enemy, size: 30)) {
            guard body.velocity.dy < -40, player.position.y > enemy.position.y + 8 else { return hurt(body) }
            stomp(enemy, body: body)
        }
    }

    private func stomp(_ enemy: SnowmanNode, body: SKPhysicsBody) {
        enemies.removeAll { $0 === enemy }
        body.velocity.dy = 520
        Haptics.impact(.heavy)
        enemy.run(.sequence([.scaleY(to: 0.2, duration: 0.15), .fadeOut(withDuration: 0.2), .removeFromParent()]))
    }

    private func hurt(_ body: SKPhysicsBody) {
        Haptics.notify(.error)
        player.position = respawnPoint
        body.velocity = .zero
        invulnerable = 1.2
        playerSprite.run(.repeat(.sequence([.fadeAlpha(to: 0.2, duration: 0.1), .fadeAlpha(to: 1, duration: 0.1)]), count: 5))
    }

    private func completeLevel() {
        guard !isTransitioning else { return }
        isTransitioning = true
        player.physicsBody?.velocity = .zero
        Haptics.burst()
        goal.run(.scale(to: 2.4, duration: 0.5))
        let next = levelIndex + 1
        run(.wait(forDuration: 1.4)) { [weak self] in
            guard let self else { return }
            if next < self.levels.count {
                self.load(level: next)
            } else {
                self.onFinish?(self.collected, self.totalGifts)
            }
        }
    }

    private func followCamera() {
        let visibleWidth = size.width * cam.xScale
        let levelWidth = CGFloat(level.width) * Self.tile
        let half = visibleWidth / 2
        let x = levelWidth <= visibleWidth ? levelWidth / 2 : min(max(player.position.x, half), levelWidth - half)
        cam.position = CGPoint(x: x, y: CGFloat(PlatformerLevel.height) * Self.tile / 2)
    }
}
