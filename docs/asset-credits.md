# Asset Credits

## Tiny Swords

- Source: https://pixelfrog-assets.itch.io/tiny-swords
- Author: Pixel Frog
- License / usage status:
  - Paid or downloaded asset pack supplied by the project owner.
  - Treat as commercial-use licensed for this local project, but keep purchase / download records before any public commercial release.
  - Raw source folders under `external_assets/Tiny Swords/` are intentionally not committed.
- Selected project paths:
  - `assets/licensed/tiny_swords/terrain/`
  - `assets/licensed/tiny_swords/buildings/`
  - `assets/licensed/tiny_swords/units/`
  - `assets/licensed/tiny_swords/enemies/`
  - `assets/licensed/tiny_swords/deco/`
  - `assets/licensed/tiny_swords/ui/`
- Usage:
  - Current primary visual family for village terrain, buildings, player, NPCs, enemies, props, HUD, contextual prompts, inventory / character panels, and combat UI.
- Modifications:
  - Selected runtime PNG files were copied from the local asset pack into `assets/licensed/tiny_swords/`.
  - Some item icons are project-specific selected or composed runtime assets.
  - Source pack contents are otherwise not modified in-place.

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
  - Historical first village visual pass.
  - Approved fallback for simple CC0 props or missing objects when Tiny Swords cannot cover the need.
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
  - Historical player, elder NPC, props, and Word Imp placeholder sprites.
  - Approved fallback only when Tiny Swords or another coherent asset family cannot cover a specific need.
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
  - `assets/audio/bgm/prologue_magic_book_draft_01.mp3`
  - `assets/audio/bgm/prologue_magic_book_draft_01.ogg`
- Usage:
  - Draft beginner village background music for local review.
  - Draft prologue background music for the talking magic book scene.
- Generation notes:
  - Instrumental cozy pixel RPG starter village theme.
  - Prompt emphasized warm, peaceful, hopeful, loopable background music with light flute, lute, soft bells, gentle hand percussion, and warm strings.
  - Prologue prompt emphasized a gentle, mysterious, children-friendly pixel fantasy cue with music box, celesta, soft harp, warm strings, tiny bells, and no vocals.
  - `prologue_magic_book_draft_01.ogg` is the runtime Vorbis conversion of the MiniMax MP3 draft for Godot playback.
- Commercial release note:
  - Confirm MiniMax platform terms for generated audio before shipping this asset in a commercial build.

## Project-Generated Prologue Pixel Assets

- Source: Generated locally for this project with a small Pillow script.
- Local paths:
  - `assets/story/prologue_open_magic_book.png`
  - `assets/story/prologue_floating_page.png`
  - `assets/story/prologue_magic_spark.png`
- Usage:
  - Prologue magic book, floating page, and glow accents.
- License:
  - Project-owned generated assets.

## Project-Generated Tiny Swords Compatible Props

- Source: Project-generated pixel-art companion assets.
- Local paths:
  - `assets/generated/tiny_swords_compatible/props/supply_chest_closed.png`
- Usage:
  - Closed supply chest for collectable map rewards.
- Generation notes:
  - Created after the local Tiny Swords pack was confirmed to have no suitable chest asset.
  - Visual target is Tiny Swords-compatible: chunky dark outline, warm wood palette, gold latch, compact RPG prop silhouette.
  - The asset is not an official Tiny Swords file and is intentionally stored outside `assets/licensed/tiny_swords/`.
- License:
  - Project-owned generated asset.

## OpenGameArt 80 CC0 RPG SFX

- Source: https://opengameart.org/content/80-cc0-rpg-sfx
- Author: Rubberduck
- License: Creative Commons Zero, CC0 (Creative Commons CC0)
- License URL: https://creativecommons.org/publicdomain/zero/1.0/
- Raw local download:
  - `external_assets/audio/open_game_art_80_cc0_rpg_sfx/`
  - This raw folder is intentionally ignored by Git.
- Selected project paths:
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/misc_01.ogg`
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/book_01.ogg`
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/blade_01.ogg`
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/creature_hurt_01.ogg`
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/creature_die_01.ogg`
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/item_coins_01.ogg`
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/item_misc_01.ogg`
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/spell_01.ogg`
  - `assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/lock_01.ogg`
- Usage:
  - First-pass SFX pool for UI confirmation, book/page interactions, blade attacks, enemy hurt/defeat, coin rewards, quest rewards, spells, and unlock feedback.
- Modifications:
  - Selected `.ogg` files were copied from the original archive without audio edits.
