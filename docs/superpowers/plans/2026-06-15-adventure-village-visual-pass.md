# Adventure Village Visual Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the current village POC into a visually stronger adventure entrance village using real low-risk licensed pixel-art assets while preserving the existing gameplay loop.

**Architecture:** Keep the scene simple and Godot-native. Use Kenney Tiny Town CC0 assets as the first concrete village asset source, document licensing in `docs/asset-credits.md`, then update `scenes/world/village.tscn` with asset-backed visual nodes while preserving existing collisions and scripts. Add a small scene-structure regression test so the visual pass does not silently collapse back to color-block placeholders.

**Tech Stack:** Godot 4.6.3, GDScript, `.tscn` scenes, Kenney Tiny Town CC0 pixel assets, existing Godot headless test scenes.

---

## Constraints

- Respond to the project direction: visual first.
- Do not introduce combat, inventory, equipment, next maps, or vocabulary refactors.
- Do not introduce GPL, LGPL, AGPL, CC-BY-SA, NonCommercial, or unclear-license assets.
- Do not run or plan `git commit`; this project is not currently a Git repository and project instructions forbid proactive git operations.
- Prefer KISS: do not import a full external RPG template unless a specific asset is needed and license-safe.

## External References

- Kenney Tiny Town: `https://kenney.nl/assets/tiny-town`
  - Relevant facts from official page: RPG/town/overworld/map/pixel tags, 16x16 tile size, Creative Commons CC0 license.
- Kenney support/license FAQ: `https://kenney.nl/support`
  - Relevant fact: Kenney game assets on asset pages are public domain licensed CC0 and usable in commercial projects.
- Godot Asset Library Topdown Pixelart Starter Project: `https://godotengine.org/asset-library/asset/2397`
  - Use only as reference. Do not import whole project in this pass.
- Godot Asset Library Top-down Action RPG Template: `https://godotengine.org/asset-library/asset/487`
  - Use only as reference. Do not import whole project in this pass.

## File Structure

Create:

- `docs/asset-credits.md`
  - Single source of truth for third-party asset source, license, author, URL, local paths, and modification notes.
- `scenes/tests/test_village_visual_pass.tscn`
  - Test scene entry point for validating visual structure.
- `src/tests/test_village_visual_pass.gd`
  - Asserts that the village scene contains the expected visual landmarks.
- `assets/third_party/kenney_tiny_town/`
  - Local source and selected extracted asset files from Kenney Tiny Town.

Modify:

- `scenes/world/village.tscn`
  - Replace or layer over color-block visuals with asset-backed grass, road/path, houses, trees, gate, stones, and signpost.
- `src/world/village.gd`
  - Only if needed to update named gate visuals after puzzle success. Prefer reusing current `open_exit()` behavior if it remains clear.

Do not modify:

- `src/autoload/*` unless a test proves it is required.
- `src/puzzle/*` unless the puzzle UI is accidentally broken.
- Vocabulary data.

## Task 1: Asset Intake And Credits

**Files:**

- Create: `docs/asset-credits.md`
- Create: `assets/third_party/kenney_tiny_town/`

- [ ] **Step 1: Re-confirm asset license from official source**

Open:

```text
https://kenney.nl/assets/tiny-town
https://kenney.nl/support
```

Expected:

- Tiny Town page states `License Creative Commons CC0`.
- Kenney support page states game assets on asset pages are CC0 and usable commercially.

- [ ] **Step 2: Download Kenney Tiny Town**

Download Tiny Town from the official Kenney page.

Expected local target:

```text
assets/third_party/kenney_tiny_town/
```

Keep the upstream license file if the archive includes one. Keep only the selected files needed for this pass if the archive is large.

- [ ] **Step 3: Create asset credits document**

Create `docs/asset-credits.md` with this structure:

```markdown
# Asset Credits

## Kenney Tiny Town

- Source: https://kenney.nl/assets/tiny-town
- Author: Kenney
- License: Creative Commons CC0
- Local paths:
  - `assets/third_party/kenney_tiny_town/...`
- Usage:
  - Village grass, roads, houses, trees, gate, stones, and signpost visuals.
- Modifications:
  - None, unless files are cropped or reorganized for Godot import.
```

- [ ] **Step 4: Verify license documentation exists**

Run:

```bash
test -f "/Users/dracohu/REPO/word-adventures/docs/asset-credits.md" && rg -n "Kenney Tiny Town|Creative Commons CC0|https://kenney.nl/assets/tiny-town" "/Users/dracohu/REPO/word-adventures/docs/asset-credits.md"
```

Expected:

- Command exits `0`.
- Output includes Kenney Tiny Town, Creative Commons CC0, and the source URL.

## Task 2: Visual Scene Regression Test

**Files:**

- Create: `src/tests/test_village_visual_pass.gd`
- Create: `scenes/tests/test_village_visual_pass.tscn`
- Modify later: `scenes/world/village.tscn`

- [ ] **Step 1: Write failing test for visual landmarks**

Create `src/tests/test_village_visual_pass.gd`:

```gdscript
extends Node
## Regression test for adventure village visual structure.

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var expected_nodes := [
        "Visuals",
        "Visuals/Ground",
        "Visuals/MainRoad",
        "Visuals/ExitRoad",
        "Visuals/Houses",
        "Visuals/Trees",
        "Visuals/Signpost",
        "ExitGate/GateVisual",
    ]

    for node_path in expected_nodes:
        assert(village.has_node(node_path), "Missing village visual node: " + node_path)

    assert(village.get_node("Player") != null, "Player must remain in village")
    assert(village.get_node("NPC") != null, "NPC must remain in village")
    assert(village.get_node("ExitGate/CollisionShape2D") != null, "Exit gate collision must remain")

    print("✅ Village visual pass regression test PASSED")
    get_tree().quit()
```

Create `scenes/tests/test_village_visual_pass.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://src/tests/test_village_visual_pass.gd" id="1_test"]

[node name="TestVillageVisualPass" type="Node"]
script = ExtResource("1_test")
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_village_visual_pass.tscn"
```

Expected:

- Fails with `Missing village visual node: Visuals` or another first missing visual node.

## Task 3: Rebuild Village Visual Composition

**Files:**

- Modify: `scenes/world/village.tscn`
- Optional modify: `src/world/village.gd`

- [ ] **Step 1: Inspect selected Kenney asset files**

Run:

```bash
find "/Users/dracohu/REPO/word-adventures/assets/third_party/kenney_tiny_town" -maxdepth 3 -type f | sort
```

Expected:

- Output includes selected image files for terrain, houses, trees, road/path, gate/door or equivalent props.

- [ ] **Step 2: Add a `Visuals` root node**

In `scenes/world/village.tscn`, create a visual-only node near the top of the scene:

```ini
[node name="Visuals" type="Node2D" parent="."]
```

Keep existing `Walls`, `ExitGate`, `Player`, and `NPC` nodes.

- [ ] **Step 3: Add asset-backed ground and roads**

Under `Visuals`, create:

```text
Visuals/Ground
Visuals/MainRoad
Visuals/ExitRoad
```

Use selected Kenney Tiny Town textures. Prefer repeated `Sprite2D` or `TextureRect` nodes if no TileMap is needed. Keep the visual footprint aligned with the 1280x720 play area.

Expected composition:

- Ground fills the playable area.
- Main road points horizontally toward the right-side exit.
- Exit road or branch visually connects the village interior to the gate.

- [ ] **Step 4: Replace prototype houses and decorations**

Under `Visuals`, create:

```text
Visuals/Houses
Visuals/Trees
Visuals/Stones
Visuals/Signpost
```

Expected:

- Houses frame the top-left/top-right area.
- Trees and stones add village depth without blocking critical paths.
- Signpost points toward the right-side gate/forest route.

Remove or hide the old rectangle-only `Decorations/House1` and `Decorations/House2` visuals after replacement. Do not delete gameplay collisions.

- [ ] **Step 5: Replace gate color block with asset-backed `GateVisual`**

Under `ExitGate`, create:

```text
ExitGate/GateVisual
```

Use a gate/door/fence-like asset or a simple composition of licensed sprites.

Expected:

- Before puzzle success, the gate reads as closed.
- After puzzle success, the gate becomes visibly passable using the existing `open_exit()` alpha change or a minimal sprite visibility change.

- [ ] **Step 6: Preserve collision and navigation**

Verify:

- `Walls/LeftWall` and `Walls/RightWall` still use the vertical side-wall shape.
- Player can move around the village center.
- NPC interaction area remains reachable.
- Exit gate collision remains disabled only after correct puzzle answer.

## Task 4: Optional Minimal Gate Visual State

**Files:**

- Modify only if needed: `src/world/village.gd`
- Modify only if needed: `scenes/world/village.tscn`

- [ ] **Step 1: Decide whether alpha-only feedback is enough**

Run the scene visually after Task 3.

If the gate clearly appears passable when `exit_gate.modulate = Color(1, 1, 1, 0.3)`, do not change code.

If not clear, update `open_exit()` minimally:

```gdscript
func open_exit() -> void:
    exit_collision.set_deferred("disabled", true)
    exit_gate.modulate = Color(1, 1, 1, 0.35)
    if exit_gate.has_node("GateVisual/OpenState"):
        exit_gate.get_node("GateVisual/OpenState").visible = true
    if exit_gate.has_node("GateVisual/ClosedState"):
        exit_gate.get_node("GateVisual/ClosedState").visible = false
    print("Exit gate opened!")
```

- [ ] **Step 2: Keep this optional**

Do not add gate state code unless visual inspection proves alpha-only feedback is weak.

## Task 5: Verification

**Files:**

- Read: `scenes/world/village.tscn`
- Read: `docs/asset-credits.md`

- [ ] **Step 1: Run visual structure test**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_village_visual_pass.tscn"
```

Expected:

- Exit code `0`.
- Output includes `✅ Village visual pass regression test PASSED`.

- [ ] **Step 2: Run navigation regression test**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_player_can_reach_npc_side.tscn"
```

Expected:

- Exit code `0`.
- Output includes `✅ Player navigation regression test PASSED`.

- [ ] **Step 3: Run phase 1 regression test**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_phase1.tscn"
```

Expected:

- Exit code `0`.
- Output includes `✅ Phase 1 regression test PASSED`.

- [ ] **Step 4: Run interactive visual check**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --path "/Users/dracohu/REPO/word-adventures"
```

Manual checks:

- Main menu still starts the game.
- Village uses visible licensed pixel-art assets.
- Path and signpost imply an adventure route to the right.
- Player can walk to the elder.
- Pressing `E` or `Space` starts dialogue.
- Puzzle appears and can be solved with `shield`.
- Gate opens and reads as passable.

- [ ] **Step 5: Check asset credits**

Run:

```bash
rg -n "Kenney Tiny Town|Creative Commons CC0|https://kenney.nl/assets/tiny-town" "/Users/dracohu/REPO/word-adventures/docs/asset-credits.md"
```

Expected:

- Output contains source, license, and local usage details.

## Done Criteria

- Real licensed pixel-art assets are visible in the village.
- `docs/asset-credits.md` records the asset source and license.
- The scene reads as an adventure entrance village.
- Existing player/NPC/puzzle/gate loop still works.
- `test_village_visual_pass`, `test_player_can_reach_npc_side`, and `test_phase1` all pass.
- No Git commits are made unless explicitly requested by the user.
