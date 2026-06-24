extends Node

signal battle_started(enemy_data: Dictionary)
signal battle_changed
signal combatant_changed
signal damage_dealt(event: Dictionary)
signal battle_finished(victory: bool)

const PHASE_REAL_TIME: String = "real_time"
const PHASE_VICTORY: String = "victory"
const PHASE_DEFEAT: String = "defeat"
const COMBATANT_PLAYER: String = "player"
const COMBATANT_ENEMY: String = "enemy"

const DEFAULT_ENEMY_HP: int = 60
const DEFAULT_ENEMY_ATTACK_POWER: int = 12
const DEFAULT_ENEMY_DEFENSE: int = 4
const DEFAULT_ENEMY_ATTACK_SPEED: float = 1.0
const DEFAULT_ENEMY_CRIT_CHANCE: float = 0.05
const DEFAULT_CRIT_MULTIPLIER: float = 1.5
const ARMOR_LEVEL_FACTOR: float = 25.0

var _active: bool = false
var _enemy: Dictionary = {}
var _enemy_stats: Dictionary = {}
var _player_stats: Dictionary = {}
var _enemy_hp: int = 0
var _enemy_max_hp: int = 0
var _player_hp: int = 0
var _player_max_hp: int = 0
var _player_mp: int = 0
var _player_max_mp: int = 0
var _boss_id: String = ""
var _turn_phase: String = PHASE_REAL_TIME
var _last_combat_log: String = ""
var _last_battle_result: Dictionary = {}
var _player_attack_timer: float = 0.0
var _enemy_attack_timer: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    _rng.randomize()
    set_process(false)

func _process(delta: float) -> void:
    advance_battle(delta)

func start_battle(enemy_data: Dictionary) -> void:
    _active = true
    _enemy = enemy_data.duplicate(true)
    _boss_id = String(enemy_data.get("enemy_id", "")) if bool(enemy_data.get("is_boss", false)) else ""
    _enemy_max_hp = int(enemy_data.get("max_hp", enemy_data.get("enemy_hp", DEFAULT_ENEMY_HP)))
    _enemy_hp = _enemy_max_hp
    _enemy_stats = _build_enemy_stats(enemy_data)
    _player_stats = _build_player_stats(enemy_data)
    _player_max_hp = int(_player_stats.get("max_hp", PlayerData.max_hp))
    _player_hp = min(int(_player_stats.get("hp", _player_max_hp)), _player_max_hp)
    _player_max_mp = int(_player_stats.get("max_mp", PlayerData.max_mp))
    _player_mp = min(int(_player_stats.get("mp", _player_max_mp)), _player_max_mp)
    _player_attack_timer = 0.0
    _enemy_attack_timer = 0.0
    _turn_phase = PHASE_REAL_TIME
    _last_combat_log = "%s 出现了。" % get_enemy_name()
    _last_battle_result.clear()
    _sync_player_resources()
    GameManager.change_state(GameManager.GameState.COMBAT)
    set_process(true)
    battle_started.emit(get_enemy_data())
    battle_changed.emit()
    combatant_changed.emit()

func start_boss_battle(boss_id: String) -> void:
    if boss_id != "word_imp":
        push_warning("Unknown boss id: " + boss_id)
        return

    start_battle({
        "enemy_id": boss_id,
        "enemy_name": "Word Imp",
        "max_hp": 180,
        "attack_power": 14,
        "defense": 5,
        "attack_speed": 0.9,
        "crit_chance": 0.05,
        "crit_multiplier": 1.5,
        "level": 1,
        "is_boss": true,
        "gold_reward": 12,
        "experience_reward": 25,
        "loot_table": [
            {"item_id": "apprentice_guard_charm", "quantity": 1, "chance": 1.0},
            {"item_id": "minor_healing_potion", "quantity": 2, "chance": 0.6},
        ],
        "sprite_path": "res://assets/licensed/tiny_swords/enemies/skull/Skull_Idle.png",
    })

func advance_battle(delta: float) -> void:
    if not _active:
        return

    _player_attack_timer += max(delta, 0.0)
    _enemy_attack_timer += max(delta, 0.0)
    _resolve_ready_attacks(COMBATANT_PLAYER)
    _resolve_ready_attacks(COMBATANT_ENEMY)

func calculate_damage(attacker_stats: Dictionary, defender_stats: Dictionary) -> Dictionary:
    var attacker_level: int = max(int(attacker_stats.get("level", 1)), 1)
    var attack_power: float = max(float(attacker_stats.get("attack_power", 1.0)), 1.0)
    var defense: float = max(float(defender_stats.get("defense", 0.0)), 0.0)
    var armor_reduction: float = defense / (defense + float(attacker_level) * ARMOR_LEVEL_FACTOR)
    var amount: int = max(int(round(attack_power * (1.0 - armor_reduction))), 1)
    var is_critical := _rng.randf() < float(attacker_stats.get("crit_chance", 0.0))
    if is_critical:
        amount = max(int(round(float(amount) * float(attacker_stats.get("crit_multiplier", DEFAULT_CRIT_MULTIPLIER)))), 1)

    return {
        "amount": amount,
        "is_critical": is_critical,
    }

func end_battle() -> void:
    _finish(false)

func is_battle_active() -> bool:
    return _active

func is_capture_available() -> bool:
    return false

func get_enemy_hp() -> int:
    return _enemy_hp

func get_enemy_max_hp() -> int:
    return _enemy_max_hp

func get_player_hp() -> int:
    return _player_hp

func get_player_max_hp() -> int:
    return _player_max_hp

func get_player_mp() -> int:
    return _player_mp

func get_player_max_mp() -> int:
    return _player_max_mp

func get_enemy_data() -> Dictionary:
    var enemy_data := _enemy.duplicate(true)
    enemy_data["enemy_hp"] = _enemy_hp
    enemy_data["max_hp"] = _enemy_max_hp
    enemy_data["stats"] = _enemy_stats.duplicate(true)
    return enemy_data

func get_enemy_name() -> String:
    return String(_enemy.get("enemy_name", "Enemy"))

func get_turn_phase() -> String:
    return _turn_phase

func get_turn_count() -> int:
    return 0

func get_enemy_intent() -> Dictionary:
    return {}

func get_last_combat_log() -> String:
    return _last_combat_log

func get_last_battle_result() -> Dictionary:
    return _last_battle_result.duplicate(true)

func roll_loot_table(loot_table: Array, forced_rolls: Array = []) -> Array[Dictionary]:
    var drops: Array[Dictionary] = []
    for index in range(loot_table.size()):
        var entry := Dictionary(loot_table[index])
        var item_id := String(entry.get("item_id", ""))
        if item_id.is_empty() or not ItemDatabase.has_item(item_id):
            continue

        var chance: float = clamp(float(entry.get("chance", 1.0)), 0.0, 1.0)
        var roll := float(forced_rolls[index]) if index < forced_rolls.size() else _rng.randf()
        if roll <= chance:
            drops.append({
                "item_id": item_id,
                "quantity": max(int(entry.get("quantity", 1)), 1),
                "chance": chance,
                "roll": roll,
            })

    return drops

func can_select_skill(_skill_id: String) -> bool:
    return false

func apply_answer_result(_correct: bool, _skill_id: String) -> void:
    # Real-time combat no longer uses word-answer actions.
    return

func _resolve_ready_attacks(source: String) -> void:
    if not _active:
        return

    var stats := _player_stats if source == COMBATANT_PLAYER else _enemy_stats
    var interval := _get_attack_interval(stats)
    if source == COMBATANT_PLAYER:
        while _active and _player_attack_timer >= interval:
            _player_attack_timer -= interval
            _resolve_attack(COMBATANT_PLAYER)
    else:
        while _active and _enemy_attack_timer >= interval:
            _enemy_attack_timer -= interval
            _resolve_attack(COMBATANT_ENEMY)

func _resolve_attack(source: String) -> void:
    var target := COMBATANT_ENEMY if source == COMBATANT_PLAYER else COMBATANT_PLAYER
    var attacker_stats := _player_stats if source == COMBATANT_PLAYER else _enemy_stats
    var defender_stats := _enemy_stats if target == COMBATANT_ENEMY else _player_stats
    var damage := calculate_damage(attacker_stats, defender_stats)
    var amount := int(damage.get("amount", 1))

    if target == COMBATANT_ENEMY:
        _enemy_hp = max(_enemy_hp - amount, 0)
        _last_combat_log = "你造成 %d 点伤害。" % amount
        AudioManager.play_sfx_path(AudioManager.SFX_BLADE_ATTACK)
    else:
        _player_hp = max(_player_hp - amount, 0)
        _last_combat_log = "%s 造成 %d 点伤害。" % [get_enemy_name(), amount]
        _sync_player_resources()

    var event := {
        "source": source,
        "target": target,
        "amount": amount,
        "is_critical": bool(damage.get("is_critical", false)),
        "enemy_hp": _enemy_hp,
        "enemy_max_hp": _enemy_max_hp,
        "player_hp": _player_hp,
        "player_max_hp": _player_max_hp,
    }
    damage_dealt.emit(event)
    battle_changed.emit()
    combatant_changed.emit()
    _check_battle_end()

func _check_battle_end() -> void:
    if _enemy_hp <= 0:
        _finish(true)
    elif _player_hp <= 0:
        _finish(false)

func _finish(victory: bool) -> void:
    if not _active:
        return

    _active = false
    set_process(false)
    _turn_phase = PHASE_VICTORY if victory else PHASE_DEFEAT
    var item_rewards: Array[Dictionary] = []
    if victory:
        AudioManager.play_sfx_path(AudioManager.SFX_ENEMY_DEFEATED)
        if _boss_id == "word_imp":
            QuestManager.mark_boss_defeated()
        PlayerData.add_gold(int(_enemy.get("gold_reward", 0)))
        PlayerData.add_experience(int(_enemy.get("experience_reward", 0)))
        item_rewards = _grant_loot_rewards(_enemy)
    _last_battle_result = _build_battle_result(victory, item_rewards)
    _boss_id = ""
    GameManager.change_state(GameManager.GameState.WORLD)
    battle_changed.emit()
    combatant_changed.emit()
    battle_finished.emit(victory)

func _build_battle_result(victory: bool, item_rewards: Array[Dictionary] = []) -> Dictionary:
    return {
        "victory": victory,
        "winner": COMBATANT_PLAYER if victory else COMBATANT_ENEMY,
        "enemy_name": get_enemy_name(),
        "gold_reward": int(_enemy.get("gold_reward", 0)) if victory else 0,
        "experience_reward": int(_enemy.get("experience_reward", 0)) if victory else 0,
        "item_rewards": item_rewards.duplicate(true),
    }

func _grant_loot_rewards(enemy_data: Dictionary) -> Array[Dictionary]:
    var loot_table := Array(enemy_data.get("loot_table", []))
    if loot_table.is_empty():
        return []

    return PlayerData.add_item_rewards(roll_loot_table(loot_table))

func _build_enemy_stats(enemy_data: Dictionary) -> Dictionary:
    return {
        "level": int(enemy_data.get("level", 1)),
        "max_hp": _enemy_max_hp,
        "hp": _enemy_hp,
        "attack_power": int(enemy_data.get("attack_power", DEFAULT_ENEMY_ATTACK_POWER)),
        "defense": int(enemy_data.get("defense", DEFAULT_ENEMY_DEFENSE)),
        "attack_speed": float(enemy_data.get("attack_speed", DEFAULT_ENEMY_ATTACK_SPEED)),
        "crit_chance": float(enemy_data.get("crit_chance", DEFAULT_ENEMY_CRIT_CHANCE)),
        "crit_multiplier": float(enemy_data.get("crit_multiplier", DEFAULT_CRIT_MULTIPLIER)),
    }

func _build_player_stats(enemy_data: Dictionary) -> Dictionary:
    if enemy_data.has("player_stats"):
        return Dictionary(enemy_data.get("player_stats", {})).duplicate(true)

    var stats := PlayerData.get_combat_stats()
    if QuestManager.is_branch_completed("blacksmith"):
        stats["attack_power"] = int(stats.get("attack_power", PlayerData.attack_power)) + 6
    if QuestManager.is_branch_completed("garden"):
        stats["defense"] = int(stats.get("defense", PlayerData.defense)) + 4
    if QuestManager.is_branch_completed("library"):
        stats["max_mp"] = int(stats.get("max_mp", PlayerData.max_mp)) + 10
        stats["mp"] = int(stats.get("max_mp", PlayerData.max_mp))
    return stats

func _sync_player_resources() -> void:
    PlayerData.max_hp = _player_max_hp
    PlayerData.hp = _player_hp
    PlayerData.max_mp = _player_max_mp
    PlayerData.mp = _player_mp
    PlayerData.stats_changed.emit()

func _get_attack_interval(stats: Dictionary) -> float:
    var attack_speed: float = max(float(stats.get("attack_speed", 1.0)), 0.1)
    return 1.0 / attack_speed
