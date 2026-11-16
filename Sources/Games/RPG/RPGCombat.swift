struct HeroStats: Equatable {
    var level = 1
    var hp: Int
    var maxHP: Int
    var mp = 10
    var maxMP = 10
    var attack = 6
    var defense = 2
    var xp = 0

    static func starting(bonusStars: Int) -> HeroStats {
        let health = 30 + bonusStars * 2
        return HeroStats(hp: health, maxHP: health)
    }

    var xpToNext: Int { level * 12 }

    mutating func gainXP(_ amount: Int) -> Int {
        xp += amount
        var gained = 0
        while xp >= xpToNext {
            xp -= xpToNext
            level += 1
            gained += 1
            maxHP += 6
            maxMP += 2
            attack += 2
            defense += 1
        }
        if gained > 0 {
            hp = maxHP
            mp = maxMP
        }
        return gained
    }
}

enum CombatAction {
    case attack, snowball, cocoa, flee
}

enum CombatPhase: Equatable {
    case heroTurn
    case enemyTurn
    case won(levelsGained: Int)
    case lost
    case fled
}

struct CombatState: Equatable {
    static let snowballCost = 3
    static let cocoaHeal = 15

    let entityID: String
    let enemy: RPGEnemy
    var enemyHP: Int
    var hero: HeroStats
    var cocoa: Int
    var log: String
    var phase: CombatPhase = .heroTurn

    init(entityID: String, enemy: RPGEnemy, hero: HeroStats, cocoa: Int) {
        self.entityID = entityID
        self.enemy = enemy
        self.hero = hero
        self.cocoa = cocoa
        enemyHP = enemy.maxHP
        log = "\(enemy.name) te barre la route !"
    }

    static func damage(attack: Int, defense: Int, roll: Int) -> Int {
        max(1, attack - defense / 2 + roll)
    }

    func canUse(_ action: CombatAction) -> Bool {
        guard phase == .heroTurn else { return false }
        switch action {
        case .attack: return true
        case .snowball: return hero.mp >= Self.snowballCost
        case .cocoa: return cocoa > 0 && hero.hp < hero.maxHP
        case .flee: return !enemy.isBoss
        }
    }

    mutating func heroActs(_ action: CombatAction, roll: Int) {
        guard canUse(action) else { return }
        switch action {
        case .attack:
            hit(Self.damage(attack: hero.attack, defense: enemy.defense, roll: roll), verb: "Tu frappes")
        case .snowball:
            hero.mp -= Self.snowballCost
            hit(Self.damage(attack: hero.attack * 2, defense: enemy.defense, roll: roll), verb: "Ta boule de neige frappe")
        case .cocoa:
            cocoa -= 1
            let healed = min(Self.cocoaHeal, hero.maxHP - hero.hp)
            hero.hp += healed
            log = "Tu bois un chocolat chaud : +\(healed) points de vie."
            phase = .enemyTurn
        case .flee:
            log = "Tu prends la fuite !"
            phase = .fled
        }
    }

    mutating func enemyActs(roll: Int) {
        guard phase == .enemyTurn else { return }
        let amount = Self.damage(attack: enemy.attack, defense: hero.defense, roll: roll)
        hero.hp = max(0, hero.hp - amount)
        log = "\(enemy.name) attaque : \(amount) dégâts."
        phase = hero.hp == 0 ? .lost : .heroTurn
    }

    private mutating func hit(_ amount: Int, verb: String) {
        enemyHP = max(0, enemyHP - amount)
        log = "\(verb) : \(amount) dégâts."
        guard enemyHP == 0 else {
            phase = .enemyTurn
            return
        }
        let levels = hero.gainXP(enemy.xp)
        log = enemy.isBoss ? "\(enemy.name) est vaincu !" : "\(enemy.name) est vaincu ! +\(enemy.xp) points d'expérience."
        phase = .won(levelsGained: levels)
    }
}
