enum GameKind: String {
    case pong, blocks, platformer, rpg
}

struct AdventDay: Identifiable, Equatable {
    let id: Int
    let title: String
    let origin: String
    let year: Int
    let genre: String
    let symbol: String
    let bridge: String
    let fact: String
    let teaser: String
    var game: GameKind?

    var isGame: Bool { game != nil }
}

enum AdventCalendar {
    static func day(_ number: Int) -> AdventDay? {
        days.first { $0.id == number }
    }

    static let days: [AdventDay] = [
        AdventDay(id: 1, title: "Ping des Neiges", origin: "Pong", year: 1972, genre: "Sport", symbol: "figure.table.tennis",
                  bridge: "Tu connais déjà : c'est le ping-pong, vu d'en haut.",
                  fact: "Pong a d'abord été installé dans un bar de Californie. On raconte que la machine est tombée en panne quelques jours plus tard : elle était pleine de pièces.",
                  teaser: "Un serpent qui a très faim…", game: .pong),
        AdventDay(id: 2, title: "Le Serpent", origin: "Blockade, puis les téléphones Nokia", year: 1976, genre: "Serpent", symbol: "scribble.variable",
                  bridge: "Tu connais déjà : c'était le jeu des anciens téléphones Nokia.",
                  fact: "Une seule règle : le serpent grandit à chaque repas et ne doit pas se mordre la queue. En 1997, Nokia l'a installé sur ses téléphones et des millions de gens y ont joué.",
                  teaser: "Un mur de briques à démolir."),
        AdventDay(id: 3, title: "Le Mur de Briques", origin: "Breakout", year: 1976, genre: "Casse-briques", symbol: "square.grid.3x2.fill",
                  bridge: "Tu connais déjà : un mur, une balle, une raquette.",
                  fact: "Breakout a été imaginé comme un Pong qu'on joue seul : au lieu d'un adversaire, il y a un mur de briques à casser une par une.",
                  teaser: "Des envahisseurs venus d'en haut."),
        AdventDay(id: 4, title: "Les Envahisseurs", origin: "Space Invaders", year: 1978, genre: "Tir", symbol: "dot.scope",
                  bridge: "Tu connais déjà : c'est une bataille navale en temps réel.",
                  fact: "Des rangées d'envahisseurs descendent vers toi. Au Japon, le jeu a eu un tel succès qu'on raconte qu'il a fait manquer de pièces de monnaie.",
                  teaser: "Un glouton dans un labyrinthe."),
        AdventDay(id: 5, title: "Le Glouton", origin: "Pac-Man", year: 1980, genre: "Labyrinthe", symbol: "face.smiling",
                  bridge: "Tu connais déjà : c'est le jeu du chat et de la souris.",
                  fact: "Pac-Man mange des pastilles dans un labyrinthe, poursuivi par quatre fantômes. Son créateur voulait un jeu qui plaise à tout le monde, pas seulement aux garçons des salles d'arcade.",
                  teaser: "Une route très fréquentée à traverser."),
        AdventDay(id: 6, title: "La Traversée", origin: "Frogger", year: 1981, genre: "Traversée", symbol: "figure.walk",
                  bridge: "Tu connais déjà : traverser au passage piéton, en plus dangereux.",
                  fact: "Une grenouille doit traverser une route puis une rivière pleine de troncs. Un jeu que tout le monde comprenait rien qu'en le regardant.",
                  teaser: "Des cartons à ranger."),
        AdventDay(id: 7, title: "Le Déménageur", origin: "Sokoban", year: 1982, genre: "Casse-tête", symbol: "shippingbox.fill",
                  bridge: "Tu connais déjà : c'est un casse-tête de déménageur.",
                  fact: "Sokoban veut dire « gardien d'entrepôt » en japonais. On pousse des caisses à leur place, sans jamais pouvoir les tirer. Les chercheurs s'en servent encore pour tester l'intelligence artificielle.",
                  teaser: "Le jeu de la semaine : des paquets qui tombent du ciel !"),
        AdventDay(id: 8, title: "Les Paquets Tombent", origin: "Tetris", year: 1984, genre: "Blocs qui tombent", symbol: "square.stack.3d.down.forward.fill",
                  bridge: "Tu connais déjà : c'est ranger une valise sans laisser de trou.",
                  fact: "Tetris a été inventé à Moscou par Alexeï Pajitnov, un chercheur, sur son ordinateur de travail. C'est l'un des jeux les plus vendus de l'histoire.",
                  teaser: "Des petites voitures sur un circuit.", game: .blocks),
        AdventDay(id: 9, title: "Le Petit Circuit", origin: "Super Sprint", year: 1986, genre: "Course", symbol: "flag.checkered",
                  bridge: "Tu connais déjà : c'est le circuit de petites voitures de ton enfance.",
                  fact: "Dans les salles d'arcade, trois joueurs pilotaient côte à côte, chacun avec son volant, sur un circuit vu d'en haut.",
                  teaser: "Une ville entière à construire."),
        AdventDay(id: 10, title: "La Ville à Bâtir", origin: "SimCity", year: 1989, genre: "Gestion", symbol: "building.2.fill",
                  bridge: "Tu connais déjà : c'est être le maire de sa propre ville.",
                  fact: "On trace les routes, on construit les maisons et les usines, on garde les habitants contents. Il n'y a ni gagnant ni perdant : c'est un jeu sans fin.",
                  teaser: "Un champ plein de pièges cachés."),
        AdventDay(id: 11, title: "Le Champ de Mines", origin: "Le Démineur de Windows", year: 1990, genre: "Déduction", symbol: "flag.fill",
                  bridge: "Tu connais déjà : c'est de la logique, comme une grille de sudoku.",
                  fact: "Installé sur des millions d'ordinateurs de bureau, le Démineur a appris à beaucoup de gens à se servir de la souris. Les chiffres disent combien de mines se cachent autour.",
                  teaser: "Une enquête chez les pirates."),
        AdventDay(id: 12, title: "L'Aventure", origin: "The Secret of Monkey Island", year: 1990, genre: "Aventure", symbol: "magnifyingglass",
                  bridge: "Tu connais déjà : c'est un roman d'aventure dont tu choisis les gestes.",
                  fact: "On clique sur les objets et on parle aux personnages pour avancer dans l'histoire. Ici, un jeune homme rêve de devenir pirate.",
                  teaser: "Une petite équipe à commander."),
        AdventDay(id: 13, title: "L'Escouade", origin: "UFO: Enemy Unknown (XCOM)", year: 1994, genre: "Tactique", symbol: "shield.lefthalf.filled",
                  bridge: "Tu connais déjà : c'est une partie d'échecs où chaque pion a ses pouvoirs.",
                  fact: "On commande une petite équipe, tour par tour, face à une invasion. Chaque soldat peut se mettre à l'abri derrière un mur ou une voiture.",
                  teaser: "Des bonbons à aligner."),
        AdventDay(id: 14, title: "Aligner Trois", origin: "Bejeweled, puis Candy Crush", year: 2001, genre: "Match-3", symbol: "circle.hexagongrid.fill",
                  bridge: "Tu connais déjà : c'est aligner trois pareils, comme au Puissance 4.",
                  fact: "Bejeweled a été l'un des premiers grands succès sur internet. Son cousin Candy Crush, en 2012, a été joué par des centaines de millions de personnes sur leur téléphone.",
                  teaser: "Le jeu de la semaine : un lutin qui saute partout !"),
        AdventDay(id: 15, title: "L'Échappée du Lutin", origin: "Super Mario Bros.", year: 1985, genre: "Plateforme", symbol: "figure.run",
                  bridge: "Tu connais déjà : c'est le genre de Mario, le plombier moustachu.",
                  fact: "Créé par Shigeru Miyamoto au Japon, Super Mario Bros. a appris à toute une génération à courir et sauter de plateforme en plateforme jusqu'au drapeau.",
                  teaser: "Une guitare en plastique.", game: .platformer),
        AdventDay(id: 16, title: "La Guitare", origin: "Guitar Hero", year: 2005, genre: "Rythme", symbol: "guitars.fill",
                  bridge: "Tu connais déjà : c'est taper la mesure en musique.",
                  fact: "On joue avec une petite guitare en plastique à cinq boutons. Le jeu vérifie que chaque note est jouée au bon moment.",
                  teaser: "Quelqu'un qui court sans jamais s'arrêter."),
        AdventDay(id: 17, title: "Le Coureur", origin: "Canabalt", year: 2009, genre: "Course infinie", symbol: "hare.fill",
                  bridge: "Tu connais déjà : un seul bouton, pour sauter.",
                  fact: "Le personnage court tout seul de toit en toit. Fait en quelques jours, ce petit jeu a lancé la mode des courses sans fin sur téléphone.",
                  teaser: "Une catapulte et des oiseaux en colère."),
        AdventDay(id: 18, title: "La Catapulte", origin: "Angry Birds", year: 2009, genre: "Physique", symbol: "scope",
                  bridge: "Tu connais déjà : c'est un jeu de quilles avec une catapulte.",
                  fact: "Créé en Finlande, Angry Birds a été téléchargé des milliards de fois. Les constructions tombent comme dans la vraie vie, grâce à la physique.",
                  teaser: "Un jardin à défendre."),
        AdventDay(id: 19, title: "La Défense", origin: "Plants vs. Zombies", year: 2009, genre: "Défense", symbol: "leaf.fill",
                  bridge: "Tu connais déjà : c'est défendre un château avec des gardes.",
                  fact: "On plante des tournesols et des petits pois devant sa maison pour arrêter une armée de zombies très lents. Un jeu de stratégie pour tous les âges.",
                  teaser: "Un oiseau très difficile à faire voler."),
        AdventDay(id: 20, title: "L'Oiseau", origin: "Flappy Bird", year: 2013, genre: "Une touche", symbol: "bird.fill",
                  bridge: "Tu connais déjà : toucher l'écran, et c'est tout.",
                  fact: "Créé au Vietnam par une seule personne, Flappy Bird est devenu si populaire que son auteur l'a retiré des magasins en 2014.",
                  teaser: "Un donjon qui change à chaque partie."),
        AdventDay(id: 21, title: "Le Donjon", origin: "Rogue", year: 1980, genre: "Roguelike", symbol: "dice.fill",
                  bridge: "Tu connais déjà : c'est une partie de petits chevaux, où tout recommence si on perd.",
                  fact: "Rogue s'affichait seulement avec des lettres et des symboles. Chaque descente dans le donjon est différente. Il a donné son nom à tout un genre : les « roguelikes ».",
                  teaser: "Un paquet de cartes magique."),
        AdventDay(id: 22, title: "Les Cartes", origin: "Slay the Spire", year: 2019, genre: "Cartes", symbol: "rectangle.stack.fill",
                  bridge: "Tu connais déjà : c'est une belote où ton paquet s'améliore après chaque partie.",
                  fact: "On part avec quelques cartes simples et on en gagne de meilleures après chaque combat, en grimpant une tour étage par étage.",
                  teaser: "Une nuit très longue à tenir."),
        AdventDay(id: 23, title: "La Survie", origin: "Vampire Survivors", year: 2022, genre: "Survie", symbol: "moon.stars.fill",
                  bridge: "Tu connais déjà : c'est tenir un siège le plus longtemps possible.",
                  fact: "Créé par un développeur italien seul et vendu quelques euros, ce jeu a reçu le prix du meilleur jeu aux BAFTA en 2023.",
                  teaser: "Le grand final : une aventure pour sauver Noël !"),
        AdventDay(id: 24, title: "La Quête de l'Étoile", origin: "Dragon Quest", year: 1986, genre: "Jeu de rôle", symbol: "star.fill",
                  bridge: "Tu connais déjà : c'est un livre dont tu es le héros.",
                  fact: "Dragon Quest a rendu le jeu de rôle populaire au Japon. On incarne un héros qui explore, parle aux habitants et devient plus fort combat après combat.",
                  teaser: "Joyeux Noël !", game: .rpg)
    ]
}
