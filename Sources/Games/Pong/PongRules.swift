enum PongRules {
    static func stars(player: Int, opponent: Int) -> Int {
        guard player > opponent else { return 0 }
        return 1 + (opponent <= 4 ? 1 : 0) + (opponent <= 2 ? 1 : 0)
    }

    static func outcome(bottom: Int, top: Int, twoPlayers: Bool) -> GameOutcome {
        if twoPlayers {
            let winner = bottom > top ? "Le joueur du bas" : "Le joueur du haut"
            return GameOutcome(
                stars: 0,
                title: "\(winner) gagne !",
                detail: "Score final : \(max(bottom, top)) à \(min(bottom, top)).",
                showsStars: false
            )
        }
        let earned = stars(player: bottom, opponent: top)
        guard earned > 0 else {
            return GameOutcome(stars: 0, title: "Presque !", detail: "L'ordinateur gagne \(top) à \(bottom). Tu prends ta revanche ?")
        }
        return GameOutcome(stars: earned, title: "Bravo !", detail: "Tu as gagné \(bottom) à \(top).")
    }
}
