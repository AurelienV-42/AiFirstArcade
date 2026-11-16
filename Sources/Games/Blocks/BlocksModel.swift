enum PieceKind: Int, CaseIterable {
    case i, o, t, s, z, j, l

    var cells: [GridPoint] {
        let raw: [(Int, Int)]
        switch self {
        case .i: raw = [(-1, 0), (0, 0), (1, 0), (2, 0)]
        case .o: raw = [(0, 0), (1, 0), (0, 1), (1, 1)]
        case .t: raw = [(-1, 0), (0, 0), (1, 0), (0, 1)]
        case .s: raw = [(0, 0), (1, 0), (-1, 1), (0, 1)]
        case .z: raw = [(-1, 0), (0, 0), (0, 1), (1, 1)]
        case .j: raw = [(-1, 0), (0, 0), (1, 0), (1, 1)]
        case .l: raw = [(-1, 0), (0, 0), (1, 0), (-1, 1)]
        }
        return raw.map { GridPoint(x: $0.0, y: $0.1) }
    }
}

struct FallingPiece: Equatable {
    let kind: PieceKind
    var cells: [GridPoint]
    var origin: GridPoint

    var absoluteCells: [GridPoint] {
        cells.map { GridPoint(x: $0.x + origin.x, y: $0.y + origin.y) }
    }

    func rotated() -> FallingPiece {
        guard kind != .o else { return self }
        var copy = self
        copy.cells = cells.map { GridPoint(x: -$0.y, y: $0.x) }
        return copy
    }

    func shifted(dx: Int, dy: Int) -> FallingPiece {
        var copy = self
        copy.origin = GridPoint(x: origin.x + dx, y: origin.y + dy)
        return copy
    }
}

struct BlocksModel {
    static let width = 10
    static let height = 14
    private static let kicks = [(0, 0), (-1, 0), (1, 0), (-2, 0), (2, 0), (0, 1)]

    enum StepResult: Equatable {
        case moved
        case locked(cleared: Int)
        case over
    }

    let targetLines: Int
    private(set) var board: [[PieceKind?]]
    private(set) var current: FallingPiece
    private(set) var next: PieceKind = .i
    private(set) var lines = 0
    private(set) var isOver = false
    private var bag: [PieceKind] = []
    private let shuffle: ([PieceKind]) -> [PieceKind]

    init(targetLines: Int, board: [[PieceKind?]]? = nil, shuffle: @escaping ([PieceKind]) -> [PieceKind] = { $0.shuffled() }) {
        self.targetLines = targetLines
        self.shuffle = shuffle
        self.board = board ?? Array(repeating: Array(repeating: nil, count: Self.width), count: Self.height)
        current = FallingPiece(kind: .i, cells: [], origin: GridPoint(x: 0, y: 0))
        next = drawKind()
        spawn()
    }

    var isWon: Bool { lines >= targetLines }

    mutating func move(_ dx: Int) -> Bool {
        place(current.shifted(dx: dx, dy: 0))
    }

    mutating func rotate() -> Bool {
        let rotated = current.rotated()
        for (dx, dy) in Self.kicks {
            if place(rotated.shifted(dx: dx, dy: dy)) { return true }
        }
        return false
    }

    mutating func step() -> StepResult {
        guard !isOver else { return .over }
        return place(current.shifted(dx: 0, dy: 1)) ? .moved : lock()
    }

    mutating func drop() -> StepResult {
        guard !isOver else { return .over }
        while place(current.shifted(dx: 0, dy: 1)) {}
        return lock()
    }

    func fits(_ piece: FallingPiece) -> Bool {
        piece.absoluteCells.allSatisfy { cell in
            cell.x >= 0 && cell.x < Self.width && cell.y >= 0 && cell.y < Self.height && board[cell.y][cell.x] == nil
        }
    }

    private mutating func place(_ piece: FallingPiece) -> Bool {
        guard !isOver, fits(piece) else { return false }
        current = piece
        return true
    }

    private mutating func lock() -> StepResult {
        for cell in current.absoluteCells { board[cell.y][cell.x] = current.kind }
        let cleared = clearLines()
        lines += cleared
        spawn()
        return isOver ? .over : .locked(cleared: cleared)
    }

    private mutating func clearLines() -> Int {
        let kept = board.filter { row in row.contains { $0 == nil } }
        let cleared = Self.height - kept.count
        board = Array(repeating: Array(repeating: nil, count: Self.width), count: cleared) + kept
        return cleared
    }

    private mutating func spawn() {
        let piece = FallingPiece(kind: next, cells: next.cells, origin: GridPoint(x: Self.width / 2 - 1, y: 0))
        next = drawKind()
        isOver = !fits(piece)
        current = piece
    }

    private mutating func drawKind() -> PieceKind {
        if bag.isEmpty { bag = shuffle(PieceKind.allCases) }
        return bag.removeFirst()
    }
}

enum BlocksRules {
    static func stars(lines: Int) -> Int {
        lines >= 15 ? 3 : lines >= 8 ? 2 : lines >= 3 ? 1 : 0
    }

    static func outcome(lines: Int, target: Int) -> GameOutcome {
        let plural = lines > 1 ? "s" : ""
        guard lines >= target else {
            return GameOutcome(stars: stars(lines: lines), title: "Bien joué !", detail: "Tu as effacé \(lines) ligne\(plural) avant que les paquets n'atteignent le haut.")
        }
        return GameOutcome(stars: stars(lines: lines), title: "Bravo !", detail: "Tu as effacé \(lines) ligne\(plural). Tout est bien rangé !")
    }
}
