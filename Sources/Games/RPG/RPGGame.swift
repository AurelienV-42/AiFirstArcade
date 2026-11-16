import Foundation
import Observation

struct DialogueLine: Equatable {
    let speaker: String
    let emoji: String
    let text: String
}

enum MiniGame: Identifiable {
    case pong, blocks
    var id: Self { self }
}

@Observable
final class RPGGame {
    private enum Pending: Equatable {
        case none, pong, blocks, victory
        case combat(String)
    }

    private(set) var mapID = RPGWorld.start.map
    private(set) var position = RPGWorld.start.position
    private(set) var facingLeft = false
    private(set) var hero: HeroStats
    private(set) var cocoa: Int
    private(set) var items: Set<RPGItem> = []
    private(set) var removed: Set<String> = []
    private(set) var gateOpen = false
    private(set) var doorOpen = false
    private(set) var dialogue: [DialogueLine] = []
    private(set) var combat: CombatState?
    private(set) var isFinished = false
    var miniGame: MiniGame?
    private var pending = Pending.none
    private var previousPosition = RPGWorld.start.position
    private let roll: () -> Int

    init(bonusStars: Int, roll: @escaping () -> Int = { Int.random(in: -1...1) }) {
        self.roll = roll
        hero = .starting(bonusStars: bonusStars)
        cocoa = 1 + bonusStars / 3
        narrate(introLines(bonusStars: bonusStars))
    }

    var map: RPGMap { RPGWorld.map(mapID) }
    var isBusy: Bool { !dialogue.isEmpty || combat != nil || miniGame != nil || isFinished }
    var visibleEntities: [RPGEntity] {
        RPGWorld.entities.filter { $0.map == mapID && isVisible($0) }
    }

    func move(dx: Int, dy: Int) {
        guard !isBusy else { return }
        if dx != 0 { facingLeft = dx < 0 }
        let target = GridPoint(x: position.x + dx, y: position.y + dy)
        if let entity = visibleEntities.first(where: { $0.position == target }) {
            return interact(with: entity)
        }
        guard map.isWalkable(target) else { return }
        previousPosition = position
        position = target
        if let link = RPGWorld.links.first(where: { $0.from == mapID && $0.at == target }) {
            mapID = link.to
            position = link.arrival
            previousPosition = link.arrival
        }
    }

    func advanceDialogue() {
        guard !dialogue.isEmpty else { return }
        dialogue.removeFirst()
        guard dialogue.isEmpty else { return }
        let action = pending
        pending = .none
        perform(action)
    }

    func finishMiniGame(won: Bool) {
        let game = miniGame
        miniGame = nil
        switch game {
        case .pong:
            guard won else { return say(.innkeeper, ["Presque ! Reviens me voir pour une revanche."]) }
            gateOpen = true
            cocoa += 1
            say(.innkeeper, ["Quel champion ! Le portail de la forêt est ouvert.", "Prends ce chocolat chaud pour la route."])
        case .blocks:
            guard won else { return narrate(["La serrure résiste. Frappe encore à la porte pour réessayer."]) }
            doorOpen = true
            narrate(["Clac ! La porte du donjon s'ouvre.", "Le Krampus t'attend tout au fond…"])
        case nil:
            break
        }
    }

    func combatAction(_ action: CombatAction) {
        guard var state = combat, state.canUse(action) else { return }
        state.heroActs(action, roll: roll())
        combat = state
        if case .won = state.phase {
            Haptics.notify(.success)
        } else if action == .attack || action == .snowball {
            Haptics.impact(.heavy)
        }
        guard state.phase == .enemyTurn else { return }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            self.enemyTurn()
        }
    }

    func endCombat() {
        guard let state = combat else { return }
        combat = nil
        hero = state.hero
        cocoa = state.cocoa
        switch state.phase {
        case .won(let levels):
            removed.insert(state.entityID)
            narrate(victoryLines(enemy: state.enemy, levels: levels))
        case .lost:
            faint()
        case .fled:
            position = previousPosition
        case .heroTurn, .enemyTurn:
            break
        }
    }

    private func enemyTurn() {
        guard var state = combat else { return }
        state.enemyActs(roll: roll())
        combat = state
        Haptics.impact(.medium)
        if state.hero.hp > 0 && state.hero.hp * 4 < state.hero.maxHP { Haptics.heartbeat() }
    }

    private func faint() {
        hero.hp = hero.maxHP
        hero.mp = hero.maxMP
        mapID = RPGWorld.start.map
        position = RPGWorld.start.position
        narrate(["Tu t'es évanoui dans la neige…", "Tu te réveilles au village, en pleine forme. Courage, réessaie !"])
    }

    private func isVisible(_ entity: RPGEntity) -> Bool {
        guard !removed.contains(entity.id) else { return false }
        switch entity.kind {
        case .gate: return !gateOpen
        case .door: return !doorOpen
        case .star: return removed.contains("krampus")
        default: return true
        }
    }

    private func interact(with entity: RPGEntity) {
        switch entity.kind {
        case .npc(let npc):
            talk(to: npc)
        case .enemy(let enemy):
            dialogue = [DialogueLine(speaker: enemy.name, emoji: enemy.emoji, text: enemy.isBoss ? "Ha ha ! Tu ne récupéreras jamais l'étoile !" : "Grrrr !")]
            pending = .combat(entity.id)
        case .chest(let item):
            open(chest: entity, item: item)
        case .gate:
            narrate(["Le portail est fermé.", "La patronne de l'auberge en a la clé."])
        case .door:
            knockOnDoor()
        case .star:
            removed.insert(entity.id)
            Haptics.burst()
            narrate(["Tu as retrouvé l'étoile du sapin !", "Tu la rapportes au village et le grand sapin brille à nouveau.", "Joyeux Noël, héros !"])
            pending = .victory
        }
    }

    private func perform(_ action: Pending) {
        switch action {
        case .none: break
        case .pong: miniGame = .pong
        case .blocks: miniGame = .blocks
        case .victory: isFinished = true
        case .combat(let id):
            guard let entity = RPGWorld.entities.first(where: { $0.id == id }), case .enemy(let enemy) = entity.kind else { return }
            combat = CombatState(entityID: id, enemy: enemy, hero: hero, cocoa: cocoa)
        }
    }

    private func talk(to npc: NPCID) {
        switch npc {
        case .mayor:
            say(npc, gateOpen
                ? ["Le portail de la forêt est ouvert, tout en haut du village. Courage !", "Pendant un combat, un chocolat chaud te redonne des forces."]
                : ["Le Krampus a volé l'étoile du grand sapin !", "Sans elle, pas de Noël au village.", "La patronne de l'auberge, à droite, connaît le chemin de la forêt."])
        case .innkeeper:
            guard !gateOpen else { return say(npc, ["Le portail est ouvert. Bonne route, héros !"]) }
            say(npc, ["Bienvenue à l'auberge !", "Le portail de la forêt ? Je ne l'ouvre qu'aux champions de ping-pong.", "Une partie en 3 points. Ta raquette est en bas !"])
            pending = .pong
        case .owl:
            say(npc, ["Hou hou ! Derrière ce portail commence la forêt.", "Pour combattre un monstre, marche simplement vers lui."])
        case .reindeer:
            say(npc, items.contains(.iceKey)
                ? ["Tu as la clé ! La porte du donjon est tout en haut de la forêt."]
                : ["Le Krampus s'est caché dans le donjon, tout au nord.", "La clé de glace est dans un coffre, en haut à droite de la forêt."])
        }
    }

    private func open(chest: RPGEntity, item: RPGItem) {
        removed.insert(chest.id)
        Haptics.notify(.success)
        switch item {
        case .iceKey:
            items.insert(.iceKey)
            narrate(["Tu ouvres le coffre…", "Tu trouves la clé de glace ! Elle ouvre la porte du donjon."])
        case .cocoa:
            cocoa += 2
            narrate(["Tu ouvres le coffre…", "Deux chocolats chauds ! Ils te soignent pendant les combats."])
        }
    }

    private func knockOnDoor() {
        guard items.contains(.iceKey) else {
            return narrate(["La porte du donjon est gelée.", "Il faut une clé de glace. Le renne sait peut-être où la trouver."])
        }
        narrate(["La clé de glace tourne dans la serrure…", "Mais la serrure est un casse-tête de paquets ! Efface 3 lignes pour l'ouvrir."])
        pending = .blocks
    }

    private func victoryLines(enemy: RPGEnemy, levels: Int) -> [String] {
        var lines: [String] = []
        if levels > 0 { lines.append("Tu passes au niveau \(hero.level) ! Tu te sens plus fort.") }
        if enemy.isBoss { lines += ["Le Krampus s'enfuit en hurlant !", "L'étoile du sapin brille au fond du donjon. Va la chercher !"] }
        return lines
    }

    private func introLines(bonusStars: Int) -> [String] {
        var lines = ["Le soir du 24 décembre, l'étoile du grand sapin a disparu !"]
        if bonusStars > 0 {
            lines.append("Grâce à tes \(bonusStars) étoiles gagnées ce mois-ci, tu commences avec \(hero.maxHP) points de vie et \(cocoa) chocolats chauds.")
        }
        lines.append("Va parler au maire 👴, en bas à gauche du village.")
        return lines
    }

    private func say(_ npc: NPCID, _ texts: [String]) {
        dialogue = texts.map { DialogueLine(speaker: npc.name, emoji: npc.emoji, text: $0) }
    }

    private func narrate(_ texts: [String]) {
        dialogue = texts.map { DialogueLine(speaker: "Le conteur", emoji: "📖", text: $0) }
    }
}
