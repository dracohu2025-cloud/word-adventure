# Turn-Based Combat Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Do not create git commits unless the user explicitly requests them.

**Goal:** Turn the Word Imp battle into a clear player-turn/enemy-turn loop with enemy intent, meaningful `sword / shield / book` skills, and a battlefield-overlay UI.

**Architecture:** `CombatManager` remains the single source of truth for combat state, turn phase, enemy intent, HP, capture availability, and combat logs. `BattlePanel` becomes a renderer/controller that displays the current combat state, builds word challenges for selected skills, and submits answer results back to `CombatManager`.

**Tech Stack:** Godot 4.6 GDScript, existing autoloads (`CombatManager`, `GameManager`, `QuestManager`, `WordBank`), existing `BattlePanel` scene, Godot headless scene tests.

---

## File Structure

- Modify: `src/autoload/combat_manager.gd`
  - Add turn phases, turn count, enemy intent, combat log, and skill availability.
  - Keep combat rules simple and deterministic for the POC.
- Modify: `src/ui/battle_panel.gd`
  - Display turn phase, enemy intent, Chinese combat logs, and localized skill labels.
  - Prevent skill selection outside the player turn.
- Modify: `scenes/ui/battle_panel.tscn`
  - Add `TurnLabel`, `IntentLabel`, and a clearer battlefield-overlay layout.
- Create: `src/tests/test_turn_based_combat.gd`
  - Cover core turn state, enemy intent, shield, capture, and battle logs.
- Create: `scenes/tests/test_turn_based_combat.tscn`
  - Test scene wrapper.
- Modify: `src/tests/test_combat_outcome.gd`
  - Update old instant-counterattack assumptions to explicit turn-loop expectations.
- Modify: `src/tests/test_word_imp_boss.gd`
  - Keep capture behavior while checking turn state.
- Modify: `src/tests/test_battle_panel_skill_words.gd`
  - Keep learned-word mapping and add UI labels/intent checks.
- Modify: `src/tests/capture_battle_visual.gd`
  - Capture the new battlefield-overlay UI.

## Task 1: Add Failing Turn-Based Combat Tests

**Files:**
- Create: `src/tests/test_turn_based_combat.gd`
- Create: `scenes/tests/test_turn_based_combat.tscn`

- [ ] **Step 1: Write the failing test scene**

Create `scenes/tests/test_turn_based_combat.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://src/tests/test_turn_based_combat.gd" id="1_test"]

[node name="TestTurnBasedCombat" type="Node"]
script = ExtResource("1_test")
```

- [ ] **Step 2: Write failing combat behavior tests**

Create `src/tests/test_turn_based_combat.gd` with checks for:

```gdscript
extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    CombatManager.start_boss_battle("word_imp")

    assert(CombatManager.is_battle_active(), "Battle should start")
    assert(CombatManager.get_turn_phase() == "player_turn", "Battle should start on the player turn")
    assert(CombatManager.get_turn_count() == 1, "First turn should be turn 1")
    assert(CombatManager.get_enemy_intent().get("type", "") == "attack", "Enemy should show an opening intent")
    assert(CombatManager.get_last_combat_log().contains("Word Imp"), "Battle should start with a readable log")

    var player_hp_before := CombatManager.get_player_hp()
    CombatManager.apply_answer_result(true, "shield")
    assert(CombatManager.get_turn_phase() == "player_turn", "Enemy turn should resolve back to player turn")
    assert(CombatManager.get_turn_count() == 2, "Enemy action should advance the turn")
    assert(CombatManager.get_player_hp() == player_hp_before, "Correct shield should block normal attack")

    var enemy_hp_before := CombatManager.get_enemy_hp()
    CombatManager.apply_answer_result(true, "attack")
    assert(CombatManager.get_enemy_hp() < enemy_hp_before, "Correct sword attack should damage the enemy")
    assert(CombatManager.get_last_combat_log().contains("sword"), "Combat log should mention the learned attack word")

    while CombatManager.get_enemy_hp() > 4:
        CombatManager.apply_answer_result(true, "attack")

    assert(CombatManager.is_capture_available(), "Capture should unlock at low boss HP")
    CombatManager.apply_answer_result(false, "capture")
    assert(CombatManager.is_battle_active(), "Wrong book answer should not end battle")
    assert(CombatManager.get_enemy_hp() > 4, "Wrong capture should let the boss recover some HP")

    while CombatManager.get_enemy_hp() > 4:
        CombatManager.apply_answer_result(true, "attack")
    CombatManager.apply_answer_result(true, "capture")
    assert(QuestManager.is_boss_defeated(), "Correct book answer should capture the boss")
    assert(not CombatManager.is_battle_active(), "Battle should end after capture")

    print("Turn-based combat regression test PASSED")
    get_tree().quit()
```

- [ ] **Step 3: Run the test and verify it fails**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" --scene "res://scenes/tests/test_turn_based_combat.tscn"
```

Expected: FAIL because `get_turn_phase()`, `get_turn_count()`, `get_enemy_intent()`, and `get_last_combat_log()` do not exist yet.

## Task 2: Implement CombatManager Turn State

**Files:**
- Modify: `src/autoload/combat_manager.gd`
- Test: `scenes/tests/test_turn_based_combat.tscn`

- [ ] **Step 1: Add turn state fields**

Add:

```gdscript
const PHASE_PLAYER_TURN: String = "player_turn"
const PHASE_ENEMY_TURN: String = "enemy_turn"
const PHASE_VICTORY: String = "victory"
const PHASE_DEFEAT: String = "defeat"
const INTENT_ATTACK: String = "attack"
const INTENT_HEAVY_ATTACK: String = "heavy_attack"
const DEFAULT_HEAVY_ATTACK_DAMAGE: int = 5

var _turn_phase: String = PHASE_PLAYER_TURN
var _turn_count: int = 1
var _enemy_intent: Dictionary = {}
var _last_combat_log: String = ""
```

- [ ] **Step 2: Initialize battle state**

In `start_battle()`:

```gdscript
_turn_phase = PHASE_PLAYER_TURN
_turn_count = 1
_enemy_intent = _build_enemy_intent(_turn_count)
_last_combat_log = "%s 准备战斗。" % get_enemy_name()
```

- [ ] **Step 3: Add getters and skill gating**

Add:

```gdscript
func get_turn_phase() -> String:
    return _turn_phase

func get_turn_count() -> int:
    return _turn_count

func get_enemy_intent() -> Dictionary:
    return _enemy_intent.duplicate(true)

func get_last_combat_log() -> String:
    return _last_combat_log

func can_select_skill(skill_id: String) -> bool:
    if not _active or _turn_phase != PHASE_PLAYER_TURN:
        return false
    if skill_id == "capture":
        return is_capture_available()
    return true
```

- [ ] **Step 4: Add deterministic enemy intents**

Use the approved simple loop:

```gdscript
func _build_enemy_intent(turn_count: int) -> Dictionary:
    if turn_count % 3 == 0:
        return {
            "type": INTENT_HEAVY_ATTACK,
            "damage": DEFAULT_HEAVY_ATTACK_DAMAGE,
            "label": "重击 %d" % DEFAULT_HEAVY_ATTACK_DAMAGE,
        }
    return {
        "type": INTENT_ATTACK,
        "damage": _enemy_attack_damage,
        "label": "攻击 %d" % _enemy_attack_damage,
    }
```

- [ ] **Step 5: Refactor answer resolution into player action + enemy action**

Keep `apply_answer_result(correct, skill_id)` as public API, but make it:

1. Ignore input if not active or not player turn.
2. Resolve player action.
3. If battle still active, resolve enemy intent.
4. Generate next enemy intent and return to player turn.

Expected behavior:

- Correct `attack`: enemy loses `DEFAULT_PLAYER_ATTACK_DAMAGE`.
- Correct `shield`: sets block amount for enemy action.
- Correct `capture` while available: ends battle as victory.
- Wrong `capture`: boss recovers `DEFAULT_PLAYER_ATTACK_DAMAGE`, then enemy acts.
- Wrong non-capture: player action fails, enemy acts.

- [ ] **Step 6: Run focused tests**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" --scene "res://scenes/tests/test_turn_based_combat.tscn"
```

Expected: PASS.

## Task 3: Update BattlePanel UI and Interaction

**Files:**
- Modify: `scenes/ui/battle_panel.tscn`
- Modify: `src/ui/battle_panel.gd`
- Test: `src/tests/test_battle_panel_skill_words.gd`

- [ ] **Step 1: Add UI nodes to the scene**

In `scenes/ui/battle_panel.tscn`, add:

- `TurnLabel` near the top of `Panel`.
- `IntentLabel` near the enemy sprite or top-right area.

Keep existing node names stable where possible: `EnemyNameLabel`, `EnemyHPLabel`, `PlayerHPLabel`, `QuestionLabel`, `SkillRow`, `OptionsContainer`, `FeedbackLabel`.

- [ ] **Step 2: Wire new nodes in script**

In `src/ui/battle_panel.gd`, add:

```gdscript
@onready var turn_label: Label = $Panel/TurnLabel
@onready var intent_label: Label = $Panel/IntentLabel
```

- [ ] **Step 3: Localize skill labels and starting log**

On battle start:

```gdscript
attack_button.text = "sword 攻击"
shield_button.text = "shield 防御"
capture_button.text = "book 收服"
feedback_label.text = CombatManager.get_last_combat_log()
```

- [ ] **Step 4: Gate skill selection by turn state**

In `_select_skill(skill_id)`:

```gdscript
if not CombatManager.can_select_skill(skill_id):
    return
```

- [ ] **Step 5: Render turn and intent**

In `_sync_status()`:

```gdscript
var phase := CombatManager.get_turn_phase()
turn_label.text = "玩家回合 %d" % CombatManager.get_turn_count() if phase == "player_turn" else "敌人回合"
var intent := CombatManager.get_enemy_intent()
intent_label.text = "意图：" + String(intent.get("label", "未知"))
feedback_label.text = CombatManager.get_last_combat_log()
```

- [ ] **Step 6: Keep question generation tied to selected skill**

Do not change the current `skill_words` mapping behavior. `attack` still asks `sword`, `shield` asks `shield`, `capture` asks `book`.

- [ ] **Step 7: Run panel-focused tests**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" --scene "res://scenes/tests/test_battle_panel_skill_words.tscn"
```

Expected: PASS after updating assertions.

## Task 4: Update Existing Combat Tests

**Files:**
- Modify: `src/tests/test_combat_outcome.gd`
- Modify: `src/tests/test_word_imp_boss.gd`
- Modify: `src/tests/test_battle_panel_skill_words.gd`

- [ ] **Step 1: Update `test_combat_outcome.gd`**

Replace “counterattack immediately after a correct attack” wording with explicit turn-loop wording:

- Correct attack damages enemy.
- Enemy intent resolves after player action.
- Turn count advances.
- Correct shield blocks normal attack.
- Wrong shield allows damage.

- [ ] **Step 2: Update `test_word_imp_boss.gd`**

Keep current BOSS capture assertions and add:

```gdscript
assert(CombatManager.get_turn_phase() == "player_turn", "Boss battle should expose a player turn")
assert(not CombatManager.get_enemy_intent().is_empty(), "Boss battle should expose enemy intent")
```

- [ ] **Step 3: Update `test_battle_panel_skill_words.gd`**

Keep existing word mapping checks and add:

```gdscript
assert(battle_panel.turn_label.text.contains("玩家回合"), "Battle panel should show the player turn")
assert(battle_panel.intent_label.text.contains("意图"), "Battle panel should show enemy intent")
assert(battle_panel.attack_button.text.contains("sword"), "Attack button should show learned word")
```

- [ ] **Step 4: Run updated combat tests**

Run:

```bash
for test_scene in \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_turn_based_combat.tscn" \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_combat_outcome.tscn" \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_word_imp_boss.tscn" \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_battle_panel_skill_words.tscn"; do
  "/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" --scene "res://${test_scene#/Users/dracohu/REPO/word-adventures/}" || exit 1
done
```

Expected: all four tests PASS.

## Task 5: Visual Capture and Full Regression

**Files:**
- Modify: `src/tests/capture_battle_visual.gd`
- Verify: `.tmp_assets/battle_panel_visual_pass.png`

- [ ] **Step 1: Update battle visual capture setup**

In `capture_battle_visual.gd`, start a BOSS battle so the panel includes the Word Imp skill words and enemy intent:

```gdscript
QuestManager.reset_chapter()
CombatManager.start_boss_battle("word_imp")
```

- [ ] **Step 2: Capture battle UI**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --path "/Users/dracohu/REPO/word-adventures" --scene "res://scenes/tests/capture_battle_visual.tscn"
```

Expected: `.tmp_assets/battle_panel_visual_pass.png` shows the battlefield-overlay UI, Chinese turn label, enemy intent, and skill words.

- [ ] **Step 3: Run full regression**

Run:

```bash
for test_scene in $(find "/Users/dracohu/REPO/word-adventures/scenes/tests" -name "test_*.tscn" | sort); do
  echo "== $(basename "$test_scene") =="
  "/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" --scene "res://${test_scene#/Users/dracohu/REPO/word-adventures/}"
  test_exit=$?
  if [ "$test_exit" -ne 0 ]; then
    exit "$test_exit"
  fi
done
```

Expected: every test exits with code 0.

- [ ] **Step 4: Manual smoke check**

Open the project in Godot, start from the village, complete the three NPC branches, trigger Word Imp, and verify:

- Enemy intent appears before player choice.
- `shield` visibly/logically protects against an incoming attack.
- `capture` only unlocks when BOSS is weakened.
- Correct `book` captures the BOSS and exits combat.

## Implementation Notes

- Keep first implementation deterministic. Random enemy intents can come later.
- Keep `CombatManager.apply_answer_result(correct, skill_id)` as the public entry point to reduce blast radius.
- Avoid adding new autoloads. `CombatManager` already owns combat state.
- Do not introduce new paid or generated visual assets for this task.
- Do not commit changes unless the user explicitly requests a commit.
