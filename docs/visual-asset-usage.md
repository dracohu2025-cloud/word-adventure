# Visual Asset Usage

## Primary Style: Tiny Swords

Tiny Swords is the current primary art family for the beginner village and core UI.

Use it first for:

- Village terrain and roads.
- Buildings and home anchors.
- Player, NPCs, enemies, and combat avatars.
- Props and decorative objects.
- HUD, panels, buttons, bars, prompts, item slots, and icons.

Rules:

- Do not use raw paid source folders from `external_assets` directly in committed scenes.
- Import only selected runtime assets under `assets/licensed/tiny_swords/`.
- Do not mix Tiny Swords with Kenney inside a single focal composition unless the mismatch is explicitly accepted.
- Prefer complete sprites or documented frame regions; avoid accidentally using half of an object.

## Kenney Tiny Town

Kenney is now an approved fallback source, not the primary village style.

Use these tiles by visual unit, not by isolated tile id.

### Safe Single-Tile Props

- `tile_0029`: mushrooms
- `tile_0083`: sign
- `tile_0104`: well
- `tile_0105`: bomb
- `tile_0106`: log
- `tile_0107`: barrel
- `tile_0115`: blacksmith anvil
- `tile_0130`: empty pot
- `tile_0131`: water pot

### Multi-Tile Objects

- Green tree: top `tile_0004`, bottom `tile_0016`
- Yellow tree: top `tile_0003`, bottom `tile_0015`
- Blue-roof house:
  - Row 1: `tile_0048`, `tile_0049`, `tile_0050`
  - Row 2: `tile_0060`, `tile_0063`, `tile_0062`
  - Row 3: `tile_0072`, `tile_0074`, `tile_0075`
- Red-roof house:
  - Row 1: `tile_0052`, `tile_0053`, `tile_0054`
  - Row 2: `tile_0064`, `tile_0067`, `tile_0066`
  - Row 3: `tile_0076`, `tile_0078`, `tile_0079`
- Village stone road:
  - Source: Kenney Tiny Dungeon, `tile_0040`
  - Use this grey stone tile for the beginner village walkable road.
  - Keep village roads one tile wide by default; add short spur tiles only for explicit NPC, gate, or boss approaches.
  - Do not use Tiny Town dirt-road tiles as the village main road.
- Fences, gates, and roads must be placed through tile groups.
- Player walkable areas must match visible road strips or explicit road pads.
- Branch anchor props should sit near buildings, but must not overlap house tile rectangles.

### Banned As Standalone Props

- `tile_0092`: partial object top. It reads as half an object when used alone, so do not place it in the village unless a complete multi-tile composition is designed around it.
