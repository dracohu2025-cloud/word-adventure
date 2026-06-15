# Newbie Village Gameplay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Subagents may be used only after explicit user approval. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the current village proof of concept into a 20-30 minute first chapter with three vocabulary side quests, visible book-page progression, rewards, a fast combat loop, and a Word Imp boss gate.

**Architecture:** Keep the current Godot scene structure and small GDScript scripts. Add focused managers for quest state, word data, and combat state, while leaving player movement, collision, BGM, and existing visual composition intact. Use data-driven vocabulary challenges so new content can be added without rewriting scene logic.

**Tech Stack:** Godot 4.6.3, GDScript, `.tscn` scenes, JSON vocabulary data, existing Kenney CC0 visual assets, optional generated pixel assets only when open-source assets cannot cover a key concept.

---

## Constraints

- Respond to the project direction: visual first.
- Use open-source assets first: CC0, MIT, or attribution-recorded CC-BY.
- Record every new third-party or generated asset in `docs/asset-credits.md`.
- Do not introduce professions, shops, equipment rarity, save files, multiple maps, or a skill tree in this chapter.
- Do not rewrite player movement, existing collision work, menu boot, BGM, or visual scaling.
- Do not plan or run `git commit` / `git push` unless the user explicitly asks.
- Keep the first implementation data small: enough words and quests to prove the chapter loop.

## Source Spec

- `docs/superpowers/specs/2026-06-15-newbie-village-gameplay-design.md`

## Current Useful Files

- `project.godot`
  - Autoload registration and input actions.
- `data/vocabulary/village_a1.json`
  - Existing A1 vocabulary pack.
- `src/autoload/game_manager.gd`
  - Global game state enum.
- `src/autoload/player_data.gd`
  - Existing player stats, inventory, and vocabulary progress.
- `src/autoload/dialogue_manager.gd`
  - Dialogue and puzzle signal bridge.
- `src/puzzle/choice_puzzle.gd`
  - Current vocabulary question UI.
- `scenes/puzzle/choice_puzzle.tscn`
  - Current puzzle panel scene.
- `src/world/npc.gd`
  - Current NPC proximity marker, dialogue, and puzzle trigger.
- `scenes/world/npc.tscn`
  - Reusable NPC scene.
- `src/world/village.gd`
  - Village state and forest gate behavior.
- `scenes/world/village.tscn`
  - Village composition, NPC placement, gate, player, collisions.
- `src/world/village_visuals.gd`
  - Asset-backed village visual layout.
- `docs/asset-credits.md`
  - License and asset source tracking.

## New File Structure

Create:

- `src/autoload/quest_manager.gd`
  - Owns first-chapter quest state, book-page count, rewards, and forest gate unlock state.
- `src/autoload/word_bank.gd`
  - Loads vocabulary JSON and returns challenge dictionaries by word id or tag.
- `src/autoload/combat_manager.gd`
  - Owns current combat state, answer outcomes, HP changes, capture availability, and battle completion.
- `src/ui/village_hud.gd`
  - Displays book pages, lightweight guidance, and reward text while in the village.
- `scenes/ui/village_hud.tscn`
  - Village HUD CanvasLayer.
- `scenes/ui/battle_panel.tscn`
  - First combat panel.
- `src/ui/battle_panel.gd`
  - Renders player/enemy HP, skill buttons, question prompt, and feedback.
- `scenes/world/forest_gate.tscn`
  - Optional focused gate scene if the existing inline `ExitGate` becomes too crowded.
- `src/tests/test_quest_manager.gd`
- `scenes/tests/test_quest_manager.tscn`
- `src/tests/test_vocabulary_challenge_types.gd`
- `scenes/tests/test_vocabulary_challenge_types.tscn`
- `src/tests/test_village_three_branches.gd`
- `scenes/tests/test_village_three_branches.tscn`
- `src/tests/test_forest_gate_unlock.gd`
- `scenes/tests/test_forest_gate_unlock.tscn`
- `src/tests/test_combat_outcome.gd`
- `scenes/tests/test_combat_outcome.tscn`
- `src/tests/test_word_imp_boss.gd`
- `scenes/tests/test_word_imp_boss.tscn`

Modify:

- `project.godot`
  - Register new autoloads and optional UI scenes.
- `data/vocabulary/village_a1.json`
  - Add challenge metadata for meaning, spelling, and context prompts.
- `src/autoload/player_data.gd`
  - Add minimal helpers for inventory/rewards only if `QuestManager` should persist them there.
- `src/autoload/dialogue_manager.gd`
  - Keep existing signals, but support generic challenge payloads.
- `src/puzzle/choice_puzzle.gd`
  - Expand the current panel into a minimal vocabulary challenge panel without renaming the autoload.
- `scenes/puzzle/choice_puzzle.tscn`
  - Add a spelling input row and reuse existing choice buttons.
- `src/world/npc.gd`
  - Add quest id, completion checks, and challenge payload support.
- `scenes/world/npc.tscn`
  - Add exported defaults that support branch NPC instances.
- `src/world/village.gd`
  - Replace single-puzzle gate opening with book-page and boss completion checks.
- `scenes/world/village.tscn`
  - Add three branch NPCs/interactables, HUD, and combat panel reference.
- `src/world/village_visuals.gd`
  - Add branch-readable visual anchors only if needed.
- `docs/asset-credits.md`
  - Add any new icons, monster sprites, magic book/page art, or generated assets.

Do not modify:

- `src/actors/player.gd` unless a test proves state changes block movement.
- Existing collision body sizes except for new branch anchors.
- Existing BGM files.

## Standard Test Commands

Use these exact commands from the repository root:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_quest_manager.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_vocabulary_challenge_types.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_village_three_branches.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_forest_gate_unlock.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_combat_outcome.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_word_imp_boss.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_phase1.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_village_visual_pass.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_npc_marker_proximity.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_player_collision_blocking.tscn"
```

Manual visual verification:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --path "/Users/dracohu/REPO/word-adventures"
```

Expected manual check:

- The game starts from the main menu.
- The village fills the game view.
- Three branch anchors are visible and readable.
- Interaction markers appear only when the player is near incomplete branch NPCs.
- Book page progress is visible.
- The forest gate explains missing pages before `3/3`.
- Combat and boss panels do not obscure the core scene awkwardly.

## Task 1: Quest State And Book Pages

**Files:**

- Create: `src/autoload/quest_manager.gd`
- Create: `src/tests/test_quest_manager.gd`
- Create: `scenes/tests/test_quest_manager.tscn`
- Modify: `project.godot`

- [x] **Step 1: Write the failing quest manager test**

Create `src/tests/test_quest_manager.gd`:

```gdscript
extends Node

func _ready() -> void:
    QuestManager.reset_chapter()

    assert(QuestManager.get_book_page_count() == 0, "Chapter should start with zero pages")
    assert(not QuestManager.is_branch_completed("library"), "Library branch should start incomplete")
    assert(not QuestManager.is_forest_gate_ready(), "Forest gate should start locked")

    QuestManager.complete_branch("library")
    assert(QuestManager.is_branch_completed("library"), "Library branch should be completed")
    assert(QuestManager.get_book_page_count() == 1, "One branch should grant one page")

    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")
    assert(QuestManager.get_book_page_count() == 3, "Three branches should grant three pages")
    assert(QuestManager.is_forest_gate_ready(), "Forest gate should unlock at three pages")

    QuestManager.complete_branch("garden")
    assert(QuestManager.get_book_page_count() == 3, "Completing the same branch twice should be idempotent")

    print("Quest manager regression test PASSED")
    get_tree().quit()
```

Create `scenes/tests/test_quest_manager.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://src/tests/test_quest_manager.gd" id="1_test"]

[node name="TestQuestManager" type="Node"]
script = ExtResource("1_test")
```

- [x] **Step 2: Run the failing test**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_quest_manager.tscn"
```

Expected:

- FAIL because `QuestManager` is not registered yet.

- [x] **Step 3: Implement minimal quest manager**

Create `src/autoload/quest_manager.gd`:

```gdscript
extends Node

signal branch_completed(branch_id: String)
signal book_pages_changed(count: int, total: int)
signal forest_gate_ready

const REQUIRED_BOOK_PAGES: int = 3
const BRANCH_IDS: Array[String] = ["library", "blacksmith", "garden"]

var _completed_branches: Dictionary = {}
var _book_pages: int = 0
var _boss_defeated: bool = false

func reset_chapter() -> void:
    _completed_branches.clear()
    _book_pages = 0
    _boss_defeated = false
    book_pages_changed.emit(_book_pages, REQUIRED_BOOK_PAGES)

func complete_branch(branch_id: String) -> void:
    if not BRANCH_IDS.has(branch_id):
        push_warning("Unknown branch id: " + branch_id)
        return
    if _completed_branches.has(branch_id):
        return

    _completed_branches[branch_id] = true
    _book_pages = min(_book_pages + 1, REQUIRED_BOOK_PAGES)
    branch_completed.emit(branch_id)
    book_pages_changed.emit(_book_pages, REQUIRED_BOOK_PAGES)

    if is_forest_gate_ready():
        forest_gate_ready.emit()

func is_branch_completed(branch_id: String) -> bool:
    return _completed_branches.has(branch_id)

func get_book_page_count() -> int:
    return _book_pages

func is_forest_gate_ready() -> bool:
    return _book_pages >= REQUIRED_BOOK_PAGES

func mark_boss_defeated() -> void:
    _boss_defeated = true

func is_boss_defeated() -> bool:
    return _boss_defeated
```

Modify `project.godot`:

```ini
QuestManager="*res://src/autoload/quest_manager.gd"
```

- [x] **Step 4: Run the quest manager test**

Expected:

- PASS.

## Task 2: Word Bank And Challenge Payloads

**Files:**

- Create: `src/autoload/word_bank.gd`
- Create: `src/tests/test_vocabulary_challenge_types.gd`
- Create: `scenes/tests/test_vocabulary_challenge_types.tscn`
- Modify: `project.godot`
- Modify: `data/vocabulary/village_a1.json`

- [x] **Step 1: Write the failing vocabulary challenge test**

Create `src/tests/test_vocabulary_challenge_types.gd`:

```gdscript
extends Node

func _ready() -> void:
    WordBank.load_pack("res://data/vocabulary/village_a1.json")

    var meaning := WordBank.build_challenge("forest", "meaning")
    assert(meaning.get("challenge_type") == "meaning", "Meaning challenge type should be set")
    assert(meaning.get("answer") == "forest", "Meaning answer should be the English word")
    assert(meaning.get("options", []).size() >= 3, "Meaning challenge should provide options")

    var spelling := WordBank.build_challenge("sword", "spelling")
    assert(spelling.get("challenge_type") == "spelling", "Spelling challenge type should be set")
    assert(spelling.get("answer") == "sword", "Spelling answer should be the English word")

    var context := WordBank.build_challenge("water", "context")
    assert(context.get("challenge_type") == "context", "Context challenge type should be set")
    assert(context.get("question", "").contains("____"), "Context challenge should include a blank")

    print("Vocabulary challenge type regression test PASSED")
    get_tree().quit()
```

Create `scenes/tests/test_vocabulary_challenge_types.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://src/tests/test_vocabulary_challenge_types.gd" id="1_test"]

[node name="TestVocabularyChallengeTypes" type="Node"]
script = ExtResource("1_test")
```

- [x] **Step 2: Run the failing test**

Expected:

- FAIL because `WordBank` does not exist or the data does not include `forest` / `water`.

- [x] **Step 3: Extend vocabulary data minimally**

Modify `data/vocabulary/village_a1.json` so it includes at least:

```json
{
  "word": "forest",
  "meaning": "森林",
  "example": "We walk in the forest.",
  "context_prompt": "We walk in the ____.",
  "context_options": ["forest", "sword", "book", "water"],
  "meaning_options": ["forest", "river", "shield", "apple"],
  "tags": ["place", "chapter_1"]
}
```

Also ensure these words exist for first-chapter content:

- `apple`
- `book`
- `fire`
- `friend`
- `home`
- `light`
- `river`
- `stone`
- `sun`
- `tree`
- `water`

- [x] **Step 4: Implement minimal `WordBank`**

Create `src/autoload/word_bank.gd`:

```gdscript
extends Node

var _words_by_id: Dictionary = {}

func load_pack(path: String) -> void:
    _words_by_id.clear()
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Unable to open word pack: " + path)
        return

    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("Invalid word pack: " + path)
        return

    for word_data in parsed.get("words", []):
        var word := String(word_data.get("word", ""))
        if not word.is_empty():
            _words_by_id[word] = word_data

func build_challenge(word: String, challenge_type: String) -> Dictionary:
    var data: Dictionary = _words_by_id.get(word, {})
    if data.is_empty():
        return {}

    match challenge_type:
        "meaning":
            return {
                "challenge_type": "meaning",
                "word": word,
                "question": data.get("meaning", ""),
                "options": data.get("meaning_options", _fallback_options(word)),
                "answer": word,
            }
        "spelling":
            return {
                "challenge_type": "spelling",
                "word": word,
                "question": data.get("meaning", ""),
                "answer": word,
            }
        "context":
            return {
                "challenge_type": "context",
                "word": word,
                "question": data.get("context_prompt", data.get("example", "")),
                "options": data.get("context_options", _fallback_options(word)),
                "answer": word,
            }
    return {}

func _fallback_options(answer: String) -> Array[String]:
    var options: Array[String] = [answer]
    for word in _words_by_id.keys():
        if word != answer:
            options.append(word)
        if options.size() >= 4:
            break
    return options
```

Modify `project.godot`:

```ini
WordBank="*res://src/autoload/word_bank.gd"
```

- [x] **Step 5: Run vocabulary test**

Expected:

- PASS.

## Task 3: Three Branch NPCs And Forest Gate State

**Files:**

- Create: `src/tests/test_village_three_branches.gd`
- Create: `scenes/tests/test_village_three_branches.tscn`
- Create: `src/tests/test_forest_gate_unlock.gd`
- Create: `scenes/tests/test_forest_gate_unlock.tscn`
- Modify: `src/world/npc.gd`
- Modify: `src/world/village.gd`
- Modify: `scenes/world/village.tscn`
- Optional modify: `src/world/village_visuals.gd`

- [x] **Step 1: Write failing three-branch scene test**

Create `src/tests/test_village_three_branches.gd`:

```gdscript
extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var expected_npcs := [
        "LibraryNPC",
        "BlacksmithNPC",
        "GardenNPC",
    ]

    for npc_name in expected_npcs:
        assert(village.has_node(npc_name), "Village should include branch NPC: " + npc_name)
        var npc: Node = village.get_node(npc_name)
        assert(npc.get("quest_id") != "", npc_name + " should have a quest id")

    assert(QuestManager.get_book_page_count() == 0, "Village should start with zero book pages")

    print("Village three-branch regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
```

- [x] **Step 2: Write failing forest gate test**

Create `src/tests/test_forest_gate_unlock.gd`:

```gdscript
extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var gate_collision: CollisionShape2D = village.get_node("ExitGate/CollisionShape2D")
    assert(not gate_collision.disabled, "Forest gate should start locked")

    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    await get_tree().process_frame
    assert(not gate_collision.disabled, "Forest gate should remain locked before three pages")

    QuestManager.complete_branch("garden")
    await get_tree().process_frame
    assert(not gate_collision.disabled, "Forest gate should stay physically closed until boss victory")
    assert(QuestManager.is_forest_gate_ready(), "Forest gate should be ready after three pages")

    print("Forest gate unlock regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
```

Create matching `.tscn` files using the same pattern as previous test scenes.

- [x] **Step 3: Run failing scene tests**

Expected:

- `test_village_three_branches` fails because only the current `NPC` exists.
- `test_forest_gate_unlock` may fail because current gate opens after any solved puzzle.

- [x] **Step 4: Extend NPC quest metadata**

Modify `src/world/npc.gd`:

```gdscript
@export var quest_id: String = ""
@export var challenge_type: String = "meaning"

func is_available() -> bool:
    return quest_id.is_empty() or not QuestManager.is_branch_completed(quest_id)
```

When building puzzle data, include:

```gdscript
"quest_id": quest_id,
"challenge_type": challenge_type,
```

When a correct puzzle is solved for this NPC:

```gdscript
if correct:
    if not quest_id.is_empty():
        QuestManager.complete_branch(quest_id)
    _mark_dialogue_completed()
```

Keep `_sync_interaction_marker()` proximity-gated and completion-gated.

- [x] **Step 5: Replace one generic NPC with three branch NPC instances**

Modify `scenes/world/village.tscn`:

- Rename current `NPC` instance to `LibraryNPC`.
- Add two more instances of `scenes/world/npc.tscn`:
  - `BlacksmithNPC`
  - `GardenNPC`
- Assign:
  - `LibraryNPC.quest_id = "library"`
  - `BlacksmithNPC.quest_id = "blacksmith"`
  - `GardenNPC.quest_id = "garden"`
  - `LibraryNPC.challenge_type = "meaning"`
  - `BlacksmithNPC.challenge_type = "spelling"`
  - `GardenNPC.challenge_type = "context"`
- Place NPCs in visually readable open areas, not against house edges.

- [x] **Step 6: Change gate behavior**

Modify `src/world/village.gd`:

- Remove direct gate opening from any solved puzzle.
- Connect to `QuestManager.forest_gate_ready`.
- Keep the gate collision enabled after `3/3`; this state starts boss eligibility, not physical exit.
- Add `open_exit()` only after `QuestManager.mark_boss_defeated()`.

- [x] **Step 7: Run branch and gate tests**

Expected:

- Both new tests pass.
- Existing `test_phase1` will need updating in Task 4 because the old single-NPC behavior is intentionally replaced.

## Task 4: Challenge Panel, HUD, And Rewards

**Files:**

- Modify: `src/puzzle/choice_puzzle.gd`
- Modify: `scenes/puzzle/choice_puzzle.tscn`
- Create: `src/ui/village_hud.gd`
- Create: `scenes/ui/village_hud.tscn`
- Modify: `scenes/world/village.tscn`
- Modify: `src/tests/test_phase1.gd`
- Modify: `src/tests/test_village_visual_pass.gd`

- [x] **Step 1: Write or update tests for challenge completion**

Update `src/tests/test_phase1.gd` to follow one branch NPC:

```gdscript
var npc = village.get_node("LibraryNPC")
```

Expected after solving:

```gdscript
assert(QuestManager.is_branch_completed("library"), "Library branch should complete after correct answer")
assert(QuestManager.get_book_page_count() == 1, "Completing one branch should grant one page")
```

Do not assert that the gate physically opens after one correct answer.

- [x] **Step 2: Add spelling support to current puzzle panel**

Modify `scenes/puzzle/choice_puzzle.tscn`:

- Add a `LineEdit` under the question label.
- Add a submit `Button`.
- Keep the existing option buttons for meaning/context.

Modify `src/puzzle/choice_puzzle.gd`:

- For `challenge_type == "spelling"`:
  - Hide option buttons.
  - Show `LineEdit` and submit button.
  - Compare normalized lowercase text with `answer`.
- For `challenge_type == "meaning"` and `context"`:
  - Use existing option buttons.

- [x] **Step 3: Add a lightweight village HUD**

Create `src/ui/village_hud.gd`:

```gdscript
extends CanvasLayer

@onready var page_label: Label = $Panel/PageLabel
@onready var reward_label: Label = $Panel/RewardLabel

func _ready() -> void:
    QuestManager.book_pages_changed.connect(_on_book_pages_changed)
    QuestManager.branch_completed.connect(_on_branch_completed)
    _on_book_pages_changed(QuestManager.get_book_page_count(), QuestManager.REQUIRED_BOOK_PAGES)

func _on_book_pages_changed(count: int, total: int) -> void:
    page_label.text = "Book Pages: %d/%d" % [count, total]

func _on_branch_completed(branch_id: String) -> void:
    reward_label.text = _reward_text(branch_id)

func _reward_text(branch_id: String) -> String:
    match branch_id:
        "library":
            return "Book Page restored"
        "blacksmith":
            return "Beginner Charm obtained"
        "garden":
            return "Potion obtained"
    return ""
```

Create `scenes/ui/village_hud.tscn` with a compact `CanvasLayer -> Panel -> PageLabel / RewardLabel`.

- [x] **Step 4: Attach HUD to village**

Modify `scenes/world/village.tscn`:

- Add `VillageHUD` as an instance of `scenes/ui/village_hud.tscn`.
- Keep it above the world but away from bottom control hints.

- [x] **Step 5: Run verification tests**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_phase1.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_village_visual_pass.tscn"
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" "res://scenes/tests/test_vocabulary_challenge_types.tscn"
```

Expected:

- PASS.

## Task 5: Visual Asset Pass For Book Pages And Branches

**Files:**

- Modify: `docs/asset-credits.md`
- Modify: `scenes/world/village.tscn`
- Modify: `src/world/village_visuals.gd`
- Optional create: `assets/ui/book_page.png`
- Optional create: `assets/ui/magic_book.png`

- [x] **Step 1: Audit existing open-source asset coverage**

Run:

```bash
find "/Users/dracohu/REPO/word-adventures/assets/third_party/kenney_tiny_town" "/Users/dracohu/REPO/word-adventures/assets/third_party/kenney_tiny_dungeon" "/Users/dracohu/REPO/word-adventures/assets/third_party/kenney_game_icons" -type f | rg "book|page|scroll|paper|star|trophy|shield|sword|potion|warning|question|exclamation"
```

Expected:

- Prefer an existing scroll/book/page-like CC0 asset if found.
- If no adequate book/page asset exists, prepare one generated pixel asset and record it.

- [x] **Step 2: Add visible branch anchors**

Use existing Kenney assets where possible:

- Library: book/page/scroll marker near the librarian.
- Blacksmith: sword/shield/fire/forge-like item near the blacksmith.
- Garden: water/sun/plant-like props near the gardener.
- Forest gate: locked/open visual state, still using current gate art if readable.

- [x] **Step 3: Update asset credits**

Add any new asset entry to `docs/asset-credits.md` with:

- Source or generation note.
- License.
- Local path.
- Usage.
- Modification notes.

- [x] **Step 4: Manual visual review**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --path "/Users/dracohu/REPO/word-adventures"
```

Expected:

- The three branch locations are visually distinct without relying only on text.
- NPC markers remain readable.
- HUD does not cover the interaction area.

## Task 6: Normal Combat Stub

**Files:**

- Create: `src/autoload/combat_manager.gd`
- Create: `src/tests/test_combat_outcome.gd`
- Create: `scenes/tests/test_combat_outcome.tscn`
- Create: `src/ui/battle_panel.gd`
- Create: `scenes/ui/battle_panel.tscn`
- Modify: `project.godot`
- Modify: `scenes/world/village.tscn`

- [x] **Step 1: Write failing combat outcome test**

Create `src/tests/test_combat_outcome.gd`:

```gdscript
extends Node

func _ready() -> void:
    CombatManager.start_battle({
        "enemy_id": "word_sprite",
        "enemy_name": "Word Sprite",
        "enemy_hp": 12,
        "player_hp": 20,
    })

    CombatManager.apply_answer_result(true, "attack")
    assert(CombatManager.get_enemy_hp() < 12, "Correct attack should damage enemy")

    var player_hp_before := CombatManager.get_player_hp()
    CombatManager.apply_answer_result(false, "attack")
    assert(CombatManager.get_player_hp() < player_hp_before, "Incorrect answer should trigger counterattack")

    CombatManager.end_battle()
    assert(not CombatManager.is_battle_active(), "Battle should end cleanly")

    print("Combat outcome regression test PASSED")
    get_tree().quit()
```

- [x] **Step 2: Run failing test**

Expected:

- FAIL because `CombatManager` does not exist.

- [x] **Step 3: Implement minimal combat manager**

Create `src/autoload/combat_manager.gd`:

```gdscript
extends Node

signal battle_started(enemy_data: Dictionary)
signal battle_changed
signal battle_finished(victory: bool)

var _active: bool = false
var _enemy: Dictionary = {}
var _enemy_hp: int = 0
var _player_hp: int = 0

func start_battle(enemy_data: Dictionary) -> void:
    _active = true
    _enemy = enemy_data.duplicate(true)
    _enemy_hp = int(enemy_data.get("enemy_hp", 10))
    _player_hp = int(enemy_data.get("player_hp", 20))
    GameManager.change_state(GameManager.GameState.COMBAT)
    battle_started.emit(_enemy)
    battle_changed.emit()

func apply_answer_result(correct: bool, skill_id: String) -> void:
    if not _active:
        return
    if correct:
        if skill_id == "shield":
            _player_hp = min(_player_hp + 1, int(_enemy.get("player_hp", 20)))
        else:
            _enemy_hp = max(_enemy_hp - 4, 0)
    else:
        _player_hp = max(_player_hp - 3, 0)

    battle_changed.emit()

    if _enemy_hp <= 0:
        _finish(true)
    elif _player_hp <= 0:
        _finish(false)

func end_battle() -> void:
    _finish(false)

func is_battle_active() -> bool:
    return _active

func get_enemy_hp() -> int:
    return _enemy_hp

func get_player_hp() -> int:
    return _player_hp

func _finish(victory: bool) -> void:
    if not _active:
        return
    _active = false
    GameManager.change_state(GameManager.GameState.WORLD)
    battle_finished.emit(victory)
```

Modify `project.godot`:

```ini
CombatManager="*res://src/autoload/combat_manager.gd"
```

- [x] **Step 4: Add minimal battle panel**

Create `scenes/ui/battle_panel.tscn` with:

- `CanvasLayer`
- `Panel`
- `EnemyNameLabel`
- `EnemyHPLabel`
- `PlayerHPLabel`
- `QuestionLabel`
- `AttackButton`
- `ShieldButton`
- `CaptureButton`
- `FeedbackLabel`

Create `src/ui/battle_panel.gd`:

- Show only while `GameManager.GameState.COMBAT`.
- Use `WordBank.build_challenge()` for the current enemy question.
- Feed answer correctness into `CombatManager.apply_answer_result()`.
- Keep capture disabled in normal battles.

- [x] **Step 5: Run combat test**

Expected:

- PASS.

## Task 7: Forest Gate Word Imp Boss

**Files:**

- Create: `src/tests/test_word_imp_boss.gd`
- Create: `scenes/tests/test_word_imp_boss.tscn`
- Modify: `src/autoload/combat_manager.gd`
- Modify: `src/world/village.gd`
- Modify: `src/ui/battle_panel.gd`
- Modify: `scenes/ui/battle_panel.tscn`
- Modify: `docs/asset-credits.md`
- Optional create: `assets/enemies/word_imp.png`

- [x] **Step 1: Write failing Word Imp boss test**

Create `src/tests/test_word_imp_boss.gd`:

```gdscript
extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")

    CombatManager.start_boss_battle("word_imp")
    assert(CombatManager.is_battle_active(), "Word Imp boss battle should start")
    assert(not CombatManager.is_capture_available(), "Capture should not be available at full HP")

    while CombatManager.get_enemy_hp() > 2:
        CombatManager.apply_answer_result(true, "attack")

    assert(CombatManager.is_capture_available(), "Capture should become available when boss is weakened")
    CombatManager.apply_answer_result(true, "capture")

    assert(QuestManager.is_boss_defeated(), "Correct capture should defeat the boss")
    assert(not CombatManager.is_battle_active(), "Boss battle should end after capture")

    print("Word Imp boss regression test PASSED")
    get_tree().quit()
```

- [x] **Step 2: Run failing boss test**

Expected:

- FAIL because boss battle and capture are not implemented.

- [x] **Step 3: Extend combat manager for boss capture**

Add:

```gdscript
var _boss_id: String = ""

func start_boss_battle(boss_id: String) -> void:
    _boss_id = boss_id
    start_battle({
        "enemy_id": boss_id,
        "enemy_name": "Word Imp",
        "enemy_hp": 24,
        "player_hp": 24,
        "is_boss": true,
    })

func is_capture_available() -> bool:
    return _active and bool(_enemy.get("is_boss", false)) and _enemy_hp <= 4
```

In `apply_answer_result()`:

- If `skill_id == "capture"` and capture is available:
  - Correct answer marks boss defeated.
  - Calls `QuestManager.mark_boss_defeated()`.
  - Finishes battle with victory.
- If capture fails:
  - Restore a small amount of boss HP.
  - Keep the battle active.

- [x] **Step 4: Trigger boss from forest gate**

Modify `src/world/village.gd`:

- Interacting with forest gate before `3/3` pages shows missing-page feedback.
- Interacting with forest gate after `3/3` starts `CombatManager.start_boss_battle("word_imp")`.
- When `CombatManager.battle_finished(true)` and `QuestManager.is_boss_defeated()` are both true, call `open_exit()`.

- [x] **Step 5: Add or source Word Imp visual**

Asset priority:

1. Search Kenney Tiny Dungeon for a small enemy sprite that can stand in for Word Imp.
2. If inadequate, generate a 32x32 pixel Word Imp sprite.
3. Record source or generation note in `docs/asset-credits.md`.

- [x] **Step 6: Run boss test**

Expected:

- PASS.

## Task 8: Regression And Visual Review

**Files:**

- Modify tests only if names changed intentionally.
- Modify `docs/asset-credits.md` if visual review discovers undocumented assets.

- [x] **Step 1: Run the full headless regression set**

Run all commands listed in Standard Test Commands.

Expected:

- All tests pass.

- [x] **Step 2: Run manual visual pass**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --path "/Users/dracohu/REPO/word-adventures"
```

Check:

- Three branch locations feel visually distinct.
- NPC markers appear only near incomplete branch NPCs.
- The book-page HUD is readable at normal and fullscreen sizes.
- The puzzle UI works for meaning, spelling, and context.
- Combat UI does not feel like a debug panel.
- The Word Imp boss has a distinct sprite or documented generated asset.
- The forest gate opens only after successful capture.

- [x] **Step 3: Run asset documentation check**

Run:

```bash
rg -n "Kenney|CC0|generated|Word Imp|book|page|magic" "/Users/dracohu/REPO/word-adventures/docs/asset-credits.md"
```

Expected:

- Every newly used source or generated asset appears in the credits document.

## Recommended Execution Order

1. Implement Tasks 1-4 first.
2. Stop for a playable review of the three village side quests.
3. Implement Task 5 visual polish.
4. Implement Tasks 6-7 combat and boss.
5. Run Task 8 and do a final visual pass.

This order keeps the first playable slice small: three branch NPCs, three vocabulary challenge types, visible rewards, and a locked forest gate. Combat and boss work then lands on top of a proven chapter loop instead of carrying unfinished quest state.

## Acceptance Criteria

- The player can complete library, blacksmith, and garden branches in any order.
- Each branch uses a distinct challenge type: meaning, spelling, context.
- Each branch grants one visible book page and a small reward.
- The forest gate remains locked before `3/3` pages.
- The forest gate starts the Word Imp boss after `3/3` pages.
- The player can defeat and capture the Word Imp.
- The forest gate opens only after the boss is captured.
- Existing movement, collision, menu, BGM, and NPC marker behavior remain intact.
- All tests listed in Standard Test Commands pass.
- The scene passes a manual visual review in the Godot editor and from direct launch.
