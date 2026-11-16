# AiFirstArcade

Avent Arcade : un calendrier de l'avent iPhone pour faire découvrir le jeu vidéo aux grands-parents.

- 24 cases, une par jour de décembre, ouvertes à la vraie date.
- 4 jeux jouables, un par semaine : Pong (1er), blocs qui tombent (8), plateforme (15), jeu de rôle (24).
- 20 cartes d'histoire du jeu vidéo, lues à voix haute.
- Splash animé, retours haptiques, gros textes et gros boutons.

Swift, SwiftUI + SpriteKit, iOS 17, aucune dépendance.

## Lancer

```bash
brew install xcodegen
xcodegen generate
open AiFirstArcade.xcodeproj
```

Tests : `xcodebuild test -scheme AiFirstArcade -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`

Mode dev : toucher 5 fois le titre « Avent Arcade », puis entrer le code pour ouvrir n'importe quelle case.
