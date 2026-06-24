# Real-Time Stat Combat Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This repository's AGENTS.md says not to create branches or commits unless explicitly requested, so do not include git commit steps during execution.

**Goal:** Replace the word-answer battle panel with a first-pass real-time stat combat loop using attack speed, defense, damage events, player HUD, enemy overhead status, and floating damage numbers.

**Architecture:** `CombatManager` remains the combat state authority, but changes from turn-based answer resolution to real-time tick resolution. `PlayerData` owns persistent player resources and base stats. UI nodes render state from signals: `VillageHUD` for player status, `EnemyStatusBar` and `FloatingDamageText` near the boss, while `BattlePanel` is hidden during real-time combat.

**Tech Stack:** Godot 4.6 GDScript, existing autoloads (`PlayerData`, `QuestManager`, `CombatManager`, `GameManager`), existing Tiny Swords sprites, Godot headless scene tests.

---

## File Structure

- Modify: `src/autoload/player_data.gd`
  - Add HP, MP, gold, combat attributes, reset/apply damage/reward methods, and `stats_changed` signal.
- Modify: `src/autoload/combat_manager.gd`
  - Replace answer-driven turn loop with real-time combat timers, damage formula, and combat events.
- Modify: `src/ui/village_hud.gd`
  - Render player level, HP, MP, gold, and book pages.
- Modify: `scenes/ui/village_hud.tscn`
  - Add pixel-styled HUD labels/bars.
- Create: `src/ui/enemy_status_bar.gd`
  - Render enemy name and HP above the boss.
- Create: `scenes/ui/enemy_status_bar.tscn`
  - Reusable overhead enemy status UI.
- Create: `src/ui/floating_damage_text.gd`
  - Animate damage numbers upward and fade them out.
- Create: `scenes/ui/floating_damage_text.tscn`
  - Reusable damage text scene.
- Modify: `src/world/boss_encounter.gd`
  - Keep the boss visible during combat, attach overhead status, spawn floating damage, and play simple hit feedback.
- Modify: `scenes/world/boss_encounter.tscn`
  - Add `EnemyStatusBar` child and `DamageTextLayer`.
- Modify: `src/ui/battle_panel.gd`
  - Hide legacy answer panel during real-time combat.
- Modify tests under `src/tests` and `scenes/tests`.

## Task 1: PlayerData Combat Resources

**Files:**
- Modify: `src/autoload/player_data.gd`
- Create: `src/tests/test_player_combat_stats.gd`
- Create: `scenes/tests/test_player_combat_stats.tscn`

- [ ] **Step 1: Write failing PlayerData stats test**

Test:
- `reset_runtime_state()` restores level, HP, MP, gold, attack, defense, attack speed.
- `apply_damage()` clamps HP at 0.
- `restore_full_resources()` restores HP/MP.
- `add_gold()` increments gold and emits usable state.

- [ ] **Step 2: Run test and verify RED**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" --scene "res://scenes/tests/test_player_combat_stats.tscn"
```

Expected: FAIL because the new API does not exist.

- [ ] **Step 3: Implement minimal PlayerData combat API**

Add fields:

```gdscript
signal stats_changed

const DEFAULT_MAX_HP: int = 120
const DEFAULT_MAX_MP: int = 40
const DEFAULT_ATTACK_POWER: int = 18
const DEFAULT_DEFENSE: int = 8
const DEFAULT_ATTACK_SPEED: float = 1.3
const DEFAULT_CRIT_CHANCE: float = 0.1
const DEFAULT_CRIT_MULTIPLIER: float = 1.5

var max_hp: int = DEFAULT_MAX_HP
var hp: int = DEFAULT_MAX_HP
var max_mp: int = DEFAULT_MAX_MP
var mp: int = DEFAULT_MAX_MP
var gold: int = 0
var attack_power: int = DEFAULT_ATTACK_POWER
var defense: int = DEFAULT_DEFENSE
var attack_speed: float = DEFAULT_ATTACK_SPEED
var crit_chance: float = DEFAULT_CRIT_CHANCE
var crit_multiplier: float = DEFAULT_CRIT_MULTIPLIER
```

Add methods:

```gdscript
func reset_runtime_state() -> void
func restore_full_resources() -> void
func apply_damage(amount: int) -> void
func add_gold(amount: int) -> void
func get_combat_stats() -> Dictionary
```

- [ ] **Step 4: Run PlayerData test and verify GREEN**

Expected: PASS.

## Task 2: Real-Time Combat Core

**Files:**
- Modify: `src/autoload/combat_manager.gd`
- Create: `src/tests/test_real_time_combat.gd`
- Create: `scenes/tests/test_real_time_combat.tscn`
- Modify: `src/tests/test_combat_outcome.gd`
- Modify: `src/tests/test_word_imp_boss.gd`
- Modify: `src/tests/test_forest_gate_unlock.gd`
- Modify: `src/tests/test_turn_based_combat.gd`

- [ ] **Step 1: Write failing real-time combat test**

Test:
- `start_battle()` enters combat and exposes phase `real_time`.
- `advance_battle(delta)` before attack interval causes no damage.
- Advancing past player attack interval damages enemy and emits damage data.
- Advancing past enemy attack interval damages player.
- Higher defense lowers damage.
- Dropping enemy HP to 0 triggers victory and boss completion.

- [ ] **Step 2: Run test and verify RED**

Expected: FAIL because `advance_battle`, real-time phase, and damage events do not exist.

- [ ] **Step 3: Implement real-time combat state**

Add:

```gdscript
signal damage_dealt(event: Dictionary)
signal combatant_changed

const PHASE_REAL_TIME: String = "real_time"
const COMBATANT_PLAYER: String = "player"
const COMBATANT_ENEMY: String = "enemy"
```

Use `_process(delta)` to call `advance_battle(delta)` when active.

- [ ] **Step 4: Implement damage formula**

Use:

```gdscript
armor_reduction = defense / (defense + level * 25.0)
damage = max(1, round(attack_power * (1.0 - armor_reduction)))
```

Support deterministic tests by allowing `crit_chance = 0.0` in supplied stats.

- [ ] **Step 5: Update BOSS data**

Word Imp first-pass stats:

```gdscript
max_hp = 180
attack_power = 14
defense = 5
attack_speed = 0.9
crit_chance = 0.05
crit_multiplier = 1.5
gold_reward = 12
experience_reward = 25
```

- [ ] **Step 6: Replace old answer tests with real-time expectations**

Remove assertions that depend on `apply_answer_result()` and capture threshold. Tests should advance combat time until victory.

- [ ] **Step 7: Run combat tests**

Run:

```bash
for test_scene in \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_player_combat_stats.tscn" \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_real_time_combat.tscn" \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_combat_outcome.tscn" \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_word_imp_boss.tscn" \
  "/Users/dracohu/REPO/word-adventures/scenes/tests/test_forest_gate_unlock.tscn"; do
  "/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" --scene "res://${test_scene#/Users/dracohu/REPO/word-adventures/}" || exit 1
done
```

Expected: PASS.

## Task 3: Player HUD

**Files:**
- Modify: `scenes/ui/village_hud.tscn`
- Modify: `src/ui/village_hud.gd`
- Create: `src/tests/test_player_status_hud.gd`
- Create: `scenes/tests/test_player_status_hud.tscn`

- [ ] **Step 1: Write failing HUD test**

Test:
- HUD has HP, MP, gold, level, and book page labels.
- HUD updates when `PlayerData.apply_damage()` and `PlayerData.add_gold()` are called.
- Book page label still updates from `QuestManager`.

- [ ] **Step 2: Run test and verify RED**

Expected: FAIL because HUD nodes do not exist.

- [ ] **Step 3: Update HUD scene and script**

Add top HUD nodes:
- `LevelLabel`
- `HPLabel`
- `HPBar`
- `MPLabel`
- `MPBar`
- `GoldLabel`
- existing `PageLabel`
- existing `RewardLabel`

Connect `PlayerData.stats_changed`.

- [ ] **Step 4: Run HUD test and verify GREEN**

Expected: PASS.

## Task 4: Enemy Status Bar and Floating Damage

**Files:**
- Create: `src/ui/enemy_status_bar.gd`
- Create: `scenes/ui/enemy_status_bar.tscn`
- Create: `src/ui/floating_damage_text.gd`
- Create: `scenes/ui/floating_damage_text.tscn`
- Modify: `src/world/boss_encounter.gd`
- Modify: `scenes/world/boss_encounter.tscn`
- Create: `src/tests/test_enemy_status_and_damage_text.gd`
- Create: `scenes/tests/test_enemy_status_and_damage_text.tscn`

- [ ] **Step 1: Write failing enemy UI test**

Test:
- Boss has `EnemyStatusBar` and `DamageTextLayer`.
- Status bar is hidden before battle.
- Starting BOSS battle shows status bar with name and HP.
- A `damage_dealt` event targeting enemy spawns a floating damage label.
- Ending battle hides status bar.

- [ ] **Step 2: Run test and verify RED**

Expected: FAIL because nodes and scripts do not exist.

- [ ] **Step 3: Implement `EnemyStatusBar`**

Expose:

```gdscript
func show_status(enemy_name: String, hp: int, max_hp: int) -> void
func update_hp(hp: int, max_hp: int) -> void
func hide_status() -> void
```

- [ ] **Step 4: Implement `FloatingDamageText`**

Expose:

```gdscript
func setup(amount: int, is_critical: bool, from_enemy: bool) -> void
```

Animate upward/fade in `_process(delta)`.

- [ ] **Step 5: Wire BossEncounter**

Do not hide the boss when combat starts. Hide only the interaction marker. Listen to `CombatManager` signals.

- [ ] **Step 6: Run enemy UI test and verify GREEN**

Expected: PASS.

## Task 5: Retire Legacy BattlePanel for Real-Time Combat

**Files:**
- Modify: `src/ui/battle_panel.gd`
- Modify: `src/tests/test_battle_panel_skill_words.gd`
- Modify: `src/tests/capture_battle_visual.gd`

- [ ] **Step 1: Write/update failing legacy panel test**

Update `test_battle_panel_skill_words.gd` to assert the old answer panel stays hidden during real-time combat.

- [ ] **Step 2: Run test and verify RED**

Expected: FAIL because `BattlePanel` still opens on battle start.

- [ ] **Step 3: Hide BattlePanel during real-time combat**

In `_on_battle_started()`, if `CombatManager.get_turn_phase() == CombatManager.PHASE_REAL_TIME`, keep the panel hidden and do not build word challenges.

- [ ] **Step 4: Update battle visual capture**

Capture BOSS battle with world HUD, overhead BOSS HP, and floating damage instead of the old answer panel.

- [ ] **Step 5: Run panel/capture tests**

Expected: PASS.

## Task 6: Full Regression

**Files:**
- Verify all `scenes/tests/test_*.tscn`

- [ ] **Step 1: Run full test suite**

Run:

```bash
tmp_log="/tmp/word-adventures-godot-test.log"
for test_scene in $(find "/Users/dracohu/REPO/word-adventures/scenes/tests" -name "test_*.tscn" | sort); do
  "/Applications/Godot.app/Contents/MacOS/Godot" --headless --path "/Users/dracohu/REPO/word-adventures" --scene "res://${test_scene#/Users/dracohu/REPO/word-adventures/}" > "$tmp_log" 2>&1
  test_exit=$?
  if [ "$test_exit" -ne 0 ]; then
    cat "$tmp_log"
    printf 'FAILED %s\n' "$test_scene"
    exit "$test_exit"
  fi
done
printf 'All test scenes passed.\n'
```

Expected: `All test scenes passed.`

- [ ] **Step 2: Visual capture**

Run:

```bash
"/Applications/Godot.app/Contents/MacOS/Godot" --path "/Users/dracohu/REPO/word-adventures" --scene "res://scenes/tests/capture_battle_visual.tscn"
```

Expected: `.tmp_assets/battle_panel_visual_pass.png` shows no answer panel, player HUD at top, BOSS overhead HP, and visible combat feedback.

