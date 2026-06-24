extends Node

var _damage_events: Array[Dictionary] = []
var _battle_finished_count: int = 0

func _ready() -> void:
    if not CombatManager.has_signal("damage_dealt"):
        _fail("CombatManager should expose damage_dealt signal")
        return
    if not CombatManager.has_method("advance_battle"):
        _fail("CombatManager should expose advance_battle(delta)")
        return
    if not CombatManager.has_method("calculate_damage"):
        _fail("CombatManager should expose calculate_damage()")
        return

    CombatManager.damage_dealt.connect(_on_damage_dealt)
    CombatManager.battle_finished.connect(_on_battle_finished)
    QuestManager.reset_chapter()
    PlayerData.reset_runtime_state()

    CombatManager.start_battle({
        "enemy_id": "training_imp",
        "enemy_name": "Training Imp",
        "enemy_hp": 60,
        "attack_power": 12,
        "defense": 4,
        "attack_speed": 1.0,
        "crit_chance": 0.0,
        "crit_multiplier": 1.5,
        "player_stats": {
            "level": 1,
            "max_hp": 100,
            "hp": 100,
            "max_mp": 30,
            "mp": 30,
            "attack_power": 20,
            "defense": 5,
            "attack_speed": 2.0,
            "crit_chance": 0.0,
            "crit_multiplier": 1.5,
        },
    })

    assert(CombatManager.is_battle_active(), "Real-time battle should start")
    assert(CombatManager.get_turn_phase() == CombatManager.PHASE_REAL_TIME, "Battle should use real-time phase")

    var enemy_hp_before := CombatManager.get_enemy_hp()
    CombatManager.advance_battle(0.49)
    assert(CombatManager.get_enemy_hp() == enemy_hp_before, "Enemy should not take damage before player attack interval")

    CombatManager.advance_battle(0.02)
    assert(CombatManager.get_enemy_hp() < enemy_hp_before, "Player should damage enemy after attack interval")
    assert(not _damage_events.is_empty(), "Damage event should be emitted after player attack")
    assert(_damage_events[-1].get("source", "") == CombatManager.COMBATANT_PLAYER, "Damage source should be player")
    assert(_damage_events[-1].get("target", "") == CombatManager.COMBATANT_ENEMY, "Damage target should be enemy")

    var player_hp_before := CombatManager.get_player_hp()
    CombatManager.advance_battle(0.5)
    assert(CombatManager.get_player_hp() < player_hp_before, "Enemy should damage player after enemy attack interval")

    var low_defense_damage: Dictionary = CombatManager.calculate_damage(
        {"level": 1, "attack_power": 20, "crit_chance": 0.0, "crit_multiplier": 1.5},
        {"level": 1, "defense": 0}
    )
    var high_defense_damage: Dictionary = CombatManager.calculate_damage(
        {"level": 1, "attack_power": 20, "crit_chance": 0.0, "crit_multiplier": 1.5},
        {"level": 1, "defense": 60}
    )
    assert(high_defense_damage.get("amount", 0) < low_defense_damage.get("amount", 0), "Defense should reduce incoming damage")

    while CombatManager.is_battle_active():
        CombatManager.advance_battle(0.5)

    assert(_battle_finished_count >= 1, "Battle should emit finished signal")

    print("Real-time combat regression test PASSED")
    get_tree().quit()

func _on_damage_dealt(event: Dictionary) -> void:
    _damage_events.append(event)

func _on_battle_finished(_victory: bool) -> void:
    _battle_finished_count += 1

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
