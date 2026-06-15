# Asset Credits

## Kenney Tiny Town

- Source: https://kenney.nl/assets/tiny-town
- Author: Kenney
- License: Creative Commons Zero, CC0 (Creative Commons CC0)
- License URL: https://creativecommons.org/publicdomain/zero/1.0/
- Local paths:
  - `assets/third_party/kenney_tiny_town/`
  - `assets/third_party/kenney_tiny_town/License.txt`
  - `assets/third_party/kenney_tiny_town/Tilemap/tilemap_packed.png`
  - `assets/third_party/kenney_tiny_town/Tiles/`
- Usage:
  - Village grass, roads, houses, trees, gate, stones, signpost visuals, and garden branch anchor props.
- Modifications:
  - Files extracted from the official archive and referenced from Godot scenes.
  - No artwork modifications in this pass.

## Kenney Tiny Dungeon

- Source: https://kenney.nl/assets/tiny-dungeon
- Author: Kenney
- License: Creative Commons Zero, CC0 (Creative Commons CC0)
- License URL: https://creativecommons.org/publicdomain/zero/1.0/
- Local paths:
  - `assets/third_party/kenney_tiny_dungeon/`
  - `assets/third_party/kenney_tiny_dungeon/License.txt`
  - `assets/third_party/kenney_tiny_dungeon/Tilemap/tilemap_packed.png`
  - `assets/third_party/kenney_tiny_dungeon/Tiles/`
- Usage:
  - Player and elder NPC base sprites.
  - Library branch anchor props: shelves and table.
  - Blacksmith branch anchor props: sword and shield.
  - Garden branch anchor prop: potion bottle.
  - Word Imp boss placeholder sprite: `Tiles/tile_0110.png`.
- Modifications:
  - `Tiles/tile_0085.png` was scaled with nearest-neighbor sampling into `assets/characters/player.png`.
  - `Tiles/tile_0087.png` was scaled with nearest-neighbor sampling into `assets/characters/npc_villager.png`.
  - Source artwork content was otherwise unchanged.

## Kenney Game Icons

- Source: https://kenney.nl/assets/game-icons
- Author: Kenney
- License: Creative Commons Zero, CC0 (Creative Commons CC0)
- License URL: https://creativecommons.org/publicdomain/zero/1.0/
- Local paths:
  - `assets/third_party/kenney_game_icons/`
  - `assets/third_party/kenney_game_icons/license.txt`
  - `assets/third_party/kenney_game_icons/PNG/Black/2x/exclamation.png`
  - `assets/third_party/kenney_game_icons/PNG/White/2x/exclamation.png`
- Usage:
  - NPC interaction exclamation marker.
- Modifications:
  - The active marker directly references Kenney's official 2x PNG files.
  - The white icon is tinted gold in the Godot scene and layered over the black icon for contrast.

## MiniMax Generated Audio Drafts

- Source: MiniMax Music API via `mmx-cli`
- Local paths:
  - `assets/audio/bgm/village_theme_draft_01.mp3`
- Usage:
  - Draft beginner village background music for local review.
- Generation notes:
  - Instrumental cozy pixel RPG starter village theme.
  - Prompt emphasized warm, peaceful, hopeful, loopable background music with light flute, lute, soft bells, gentle hand percussion, and warm strings.
- Commercial release note:
  - Confirm MiniMax platform terms for generated audio before shipping this asset in a commercial build.
