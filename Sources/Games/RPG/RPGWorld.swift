enum RPGMapID: String, CaseIterable {
    case village, forest, dungeon

    var title: String {
        switch self {
        case .village: "Le village"
        case .forest: "La forêt"
        case .dungeon: "Le donjon du Krampus"
        }
    }
}

struct RPGMap {
    let id: RPGMapID
    let rows: [[Character]]

    init(id: RPGMapID, rows: [String]) {
        self.id = id
        self.rows = rows.map(Array.init)
    }

    var width: Int { rows.first?.count ?? 0 }
    var height: Int { rows.count }

    func tile(at point: GridPoint) -> Character {
        guard point.y >= 0, point.y < height, point.x >= 0, point.x < width else { return "#" }
        return rows[point.y][point.x]
    }

    func isWalkable(_ point: GridPoint) -> Bool {
        [".", ">", "<"].contains(tile(at: point))
    }
}

struct RPGLink {
    let from: RPGMapID
    let at: GridPoint
    let to: RPGMapID
    let arrival: GridPoint
}

enum NPCID {
    case mayor, innkeeper, owl, reindeer

    var name: String {
        switch self {
        case .mayor: "Le maire"
        case .innkeeper: "La patronne de l'auberge"
        case .owl: "La chouette"
        case .reindeer: "Le renne"
        }
    }

    var emoji: String {
        switch self {
        case .mayor: "👴"
        case .innkeeper: "👵"
        case .owl: "🦉"
        case .reindeer: "🦌"
        }
    }
}

enum RPGItem {
    case iceKey, cocoa
}

struct RPGEnemy: Equatable {
    let name: String
    let emoji: String
    let maxHP: Int
    let attack: Int
    let defense: Int
    let xp: Int
    var isBoss = false

    static let wolf = RPGEnemy(name: "Le loup des neiges", emoji: "🐺", maxHP: 14, attack: 5, defense: 1, xp: 6)
    static let chief = RPGEnemy(name: "Le chef des loups", emoji: "🐺", maxHP: 24, attack: 7, defense: 2, xp: 12)
    static let snowman = RPGEnemy(name: "Le bonhomme de neige grognon", emoji: "☃️", maxHP: 22, attack: 7, defense: 3, xp: 10)
    static let krampus = RPGEnemy(name: "Le Krampus", emoji: "👹", maxHP: 50, attack: 8, defense: 3, xp: 0, isBoss: true)
}

enum RPGEntityKind: Equatable {
    case npc(NPCID)
    case enemy(RPGEnemy)
    case chest(RPGItem)
    case gate
    case door
    case star
}

struct RPGEntity: Identifiable, Equatable {
    let id: String
    let map: RPGMapID
    let position: GridPoint
    let kind: RPGEntityKind

    var emoji: String {
        switch kind {
        case .npc(let npc): npc.emoji
        case .enemy(let enemy): enemy.emoji
        case .chest: "🎁"
        case .gate: "🚧"
        case .door: "🚪"
        case .star: "⭐️"
        }
    }
}

enum RPGWorld {
    static let start = (map: RPGMapID.village, position: GridPoint(x: 7, y: 10))

    static func map(_ id: RPGMapID) -> RPGMap {
        switch id {
        case .village: village
        case .forest: forest
        case .dungeon: dungeon
        }
    }

    private static let village = RPGMap(id: .village, rows: [
        "#######>#######",
        "#.....#.#.....#",
        "#.H...#.#..H..#",
        "#.....#.#.....#",
        "#.............#",
        "#..H.......H..#",
        "#.............#",
        "#~~~.......~~~#",
        "#~~~...T...~~~#",
        "#.............#",
        "#.............#",
        "###############"
    ])

    private static let forest = RPGMap(id: .forest, rows: [
        "########>########",
        "#######...#######",
        "##.....#...#....#",
        "#..##.......##..#",
        "#.......#.......#",
        "#.##.#.....#.##.#",
        "#.......#.......#",
        "###.##.....##.###",
        "#...............#",
        "#.#.###...###.#.#",
        "#...............#",
        "#...............#",
        "########<########"
    ])

    private static let dungeon = RPGMap(id: .dungeon, rows: [
        "#############",
        "#...........#",
        "#...........#",
        "###.#####.###",
        "#...#...#...#",
        "#.#.#.#.#.#.#",
        "#...........#",
        "#####.#.#####",
        "#...........#",
        "#.##.....##.#",
        "#...........#",
        "######<######"
    ])

    static let links = [
        RPGLink(from: .village, at: GridPoint(x: 7, y: 0), to: .forest, arrival: GridPoint(x: 8, y: 11)),
        RPGLink(from: .forest, at: GridPoint(x: 8, y: 12), to: .village, arrival: GridPoint(x: 7, y: 1)),
        RPGLink(from: .forest, at: GridPoint(x: 8, y: 0), to: .dungeon, arrival: GridPoint(x: 6, y: 10)),
        RPGLink(from: .dungeon, at: GridPoint(x: 6, y: 11), to: .forest, arrival: GridPoint(x: 8, y: 2))
    ]

    static let entities = [
        RPGEntity(id: "mayor", map: .village, position: GridPoint(x: 4, y: 9), kind: .npc(.mayor)),
        RPGEntity(id: "innkeeper", map: .village, position: GridPoint(x: 11, y: 6), kind: .npc(.innkeeper)),
        RPGEntity(id: "owl", map: .village, position: GridPoint(x: 9, y: 4), kind: .npc(.owl)),
        RPGEntity(id: "gate", map: .village, position: GridPoint(x: 7, y: 1), kind: .gate),
        RPGEntity(id: "door", map: .forest, position: GridPoint(x: 8, y: 1), kind: .door),
        RPGEntity(id: "reindeer", map: .forest, position: GridPoint(x: 2, y: 11), kind: .npc(.reindeer)),
        RPGEntity(id: "wolf1", map: .forest, position: GridPoint(x: 3, y: 8), kind: .enemy(.wolf)),
        RPGEntity(id: "wolf2", map: .forest, position: GridPoint(x: 13, y: 10), kind: .enemy(.wolf)),
        RPGEntity(id: "wolf3", map: .forest, position: GridPoint(x: 6, y: 6), kind: .enemy(.wolf)),
        RPGEntity(id: "chief", map: .forest, position: GridPoint(x: 13, y: 2), kind: .enemy(.chief)),
        RPGEntity(id: "keyChest", map: .forest, position: GridPoint(x: 15, y: 2), kind: .chest(.iceKey)),
        RPGEntity(id: "cocoaChest", map: .forest, position: GridPoint(x: 1, y: 4), kind: .chest(.cocoa)),
        RPGEntity(id: "snowman1", map: .dungeon, position: GridPoint(x: 2, y: 6), kind: .enemy(.snowman)),
        RPGEntity(id: "snowman2", map: .dungeon, position: GridPoint(x: 10, y: 8), kind: .enemy(.snowman)),
        RPGEntity(id: "krampus", map: .dungeon, position: GridPoint(x: 6, y: 1), kind: .enemy(.krampus)),
        RPGEntity(id: "star", map: .dungeon, position: GridPoint(x: 6, y: 1), kind: .star)
    ]
}
