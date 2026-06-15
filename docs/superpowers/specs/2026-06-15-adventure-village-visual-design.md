# Adventure Village Visual Design

Date: 2026-06-15

## Goal

Replace the current prototype village made from flat color blocks with a visually stronger "adventure entrance village" scene using real pixel-art assets with low commercialization risk.

The scene should immediately communicate:

- This is a beginner village.
- The player can talk to the elder NPC.
- The right side is an exit toward the next adventure area.
- Solving the vocabulary puzzle opens the exit.

## Product Direction

The project will follow a visual-first development bias. For screens, maps, UI, and gameplay feedback, real visual assets should be selected and integrated early instead of leaving long-lived color-block placeholders.

Short-lived color blocks are acceptable only for layout sketches. Implementation should replace them with licensed assets or project-owned art as soon as possible.

## Scope

This iteration focuses only on the current village scene.

In scope:

- Select and import real pixel-art assets for the village.
- Rebuild the village background with grass, road/path, houses, trees, village gate, stones, and a signpost.
- Preserve the current player, NPC, puzzle, and gate-opening gameplay loop.
- Make the right-side exit visually read as a route to the next area.
- Improve interaction readability enough for the player to understand where to go and who to talk to.
- Track third-party asset licenses and credits.

Out of scope:

- Combat.
- Inventory.
- Equipment.
- Next map implementation.
- Vocabulary system refactor.
- Full TileMap or LDtk/Tiled pipeline unless it is clearly simpler for the selected assets.

## Visual Style

Chosen direction: adventure entrance village.

The village should feel like a starting point for a larger journey:

- Warm natural grass tones.
- A readable dirt road leading toward the right-side gate.
- A signpost pointing to a future forest/adventure area.
- Houses and trees arranged to frame the path.
- A visible gate or exit structure that changes state after the puzzle is solved.

The current positions may be adjusted slightly for composition, but the gameplay relationship should remain:

- Player starts in the village interior.
- Elder NPC is reachable near the center-left.
- Exit remains on the right.
- The player can approach the NPC without hidden collision blockers.

## Asset Licensing Policy

Allowed by default:

- CC0.
- MIT.
- CC-BY, if attribution is recorded.

Excluded by default:

- GPL.
- LGPL.
- AGPL.
- CC-BY-SA.
- NonCommercial licenses.
- Assets with unclear or missing license information.

Every third-party asset must have a traceable source and license record.

Required records:

- Source name.
- Source URL.
- Author or copyright holder.
- License.
- Local asset path.
- Notes on modifications, if any.

Recommended documentation file:

- `docs/asset-credits.md`

Recommended storage pattern:

- `assets/third_party/<source>/...`

## Asset Search Priority

1. Godot Asset Library assets or demos compatible with Godot 4.x.
2. LPC Revised / Liberated Pixel Cup assets for top-down RPG map pieces.
3. Kenney assets for UI, signs, icons, and general-purpose visual polish.
4. Dungeon Crawl assets for later monsters, items, combat, or dungeon content.

Godot Asset Library entries must still be individually checked for license compatibility.

## Implementation Shape

Prefer the simplest implementation that produces a strong visual result.

Initial preference:

- Use Godot scene nodes, `Sprite2D`, `TextureRect`, `ColorRect` only where appropriate, and existing collision bodies.
- Avoid introducing a full TileMap pipeline unless the chosen asset sheet makes it clearly beneficial.
- Keep collision shapes simple and explicit.

Expected scene updates:

- Replace or cover the flat `Background` with asset-based grass/terrain.
- Replace simple `House1` and `House2` rectangles with real house sprites or composed pixel elements.
- Replace `ExitGate` visual rectangle with a real gate/door sprite or asset-composed structure.
- Add road/path visuals that guide the player toward the exit.
- Add visual decorations such as trees, stones, grass clumps, and a signpost.
- Preserve wall and gate collisions.
- Ensure the puzzle success still opens the exit.

## Interaction Readability

This is not the primary focus, but the visual pass should not leave the player confused.

Minimum readability requirements:

- The NPC should remain visually distinct from the player.
- The path to the NPC should be open.
- The right-side exit should look blocked before the puzzle and passable after success.
- The scene should not contain invisible blockers in ordinary walking paths.

Optional if cheap:

- A subtle signpost or label indicating the exit direction.
- A small nearby-interaction hint for the elder.

## Testing

Existing tests should continue to pass:

- `scenes/tests/test_phase1.tscn`
- `scenes/tests/test_player_can_reach_npc_side.tscn`

Additional verification:

- Run the project in Godot and visually inspect the village.
- Confirm the player can move freely around the center of the village.
- Confirm the elder interaction still starts dialogue.
- Confirm the choice puzzle still appears.
- Confirm the exit opens after the correct answer.

## Acceptance Criteria

The iteration is complete when:

- The village no longer reads as a flat color-block prototype.
- Real licensed pixel-art assets are visible in the scene.
- The scene composition clearly suggests an adventure route toward the right-side exit.
- Asset license information is documented.
- Existing gameplay loop still works.
- Navigation and Phase 1 regression tests pass.
