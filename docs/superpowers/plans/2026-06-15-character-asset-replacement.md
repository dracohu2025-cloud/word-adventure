# Character Asset Replacement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace prototype player and elder NPC sprites with license-safe pixel-art assets that match the Kenney Tiny village style.

**Architecture:** Keep the current Godot scene structure, collision shapes, player controller, NPC interaction, and puzzle flow unchanged. Add Kenney Tiny Dungeon as a third-party CC0 source, document the license, and replace only the static character PNGs for this pass.

**Tech Stack:** Godot 4.6.3, GDScript, PNG sprites, Kenney Tiny Dungeon CC0 assets.

---

## Constraints

- Keep this pass visual-only.
- Do not add animation, equipment, inventory, combat, or class systems.
- Do not change movement, collision, dialogue, puzzle, or gate logic.
- Use only low-risk licenses: CC0, MIT, or attribution-recorded CC-BY.
- Do not commit or push unless the user explicitly asks.

## Task 1: Asset Intake

**Files:**

- Create: `assets/third_party/kenney_tiny_dungeon/`
- Modify: `docs/asset-credits.md`

- [x] Download Kenney Tiny Dungeon from the official Kenney page.
- [x] Keep the upstream `License.txt`.
- [x] Inspect character sprites and choose one player adventurer and one elder/NPC-like sprite.
- [x] Record source, author, license, local path, and usage in `docs/asset-credits.md`.

## Task 2: Character Replacement

**Files:**

- Modify: `assets/characters/player.png`
- Modify: `assets/characters/npc_villager.png`

- [x] Replace the prototype blue player sprite with a Tiny Dungeon character sprite.
- [x] Replace the prototype purple NPC sprite with a visually distinct Tiny Dungeon character sprite.
- [x] Preserve filenames so existing scene references keep working.
- [x] Preserve current collision and interaction behavior.

## Task 3: Godot Import And Verification

**Files:**

- Modify: generated Godot `.import` / `.uid` metadata as needed.

- [x] Run Godot headless import.
- [x] Run `scenes/tests/test_village_visual_pass.tscn`.
- [x] Run `scenes/tests/test_player_can_reach_npc_side.tscn`.
- [x] Run `scenes/tests/test_phase1.tscn`.
- [x] Capture or inspect a rendered village image if needed.
