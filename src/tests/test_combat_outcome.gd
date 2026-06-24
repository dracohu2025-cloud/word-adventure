extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    CombatManager.start_battle({
        "enemy_id": "word_sprite",
        "enemy_name": "Word Sprite",
        "enemy_hp": 50,
        "attack_power": 10,
        "defense": 4,
        "attack_speed": 1.0,
        "crit_chance": 0.0,
        "player_stats": {
            "level": 1,
            "max_hp": 100,
            "hp": 100,
            "max_mp": 40,
            "mp": 40,
            "attack_power": 20,
            "defense": 8,
            "attack_speed": 2.0,
            "crit_chance": 0.0,
            "crit_multiplier": 1.5,
        },
    })

    var enemy_hp_before := CombatManager.get_enemy_hp()
    CombatManager.advance_battle(0.5)
    assert(CombatManager.get_enemy_hp() < enemy_hp_before, "Player auto attack should damage enemy")
    assert(CombatManager.get_turn_phase() == CombatManager.PHASE_REAL_TIME, "Combat should stay in real-time phase while active")

    var player_hp_before := CombatManager.get_player_hp()
    CombatManager.advance_battle(0.5)
    assert(CombatManager.get_player_hp() < player_hp_before, "Enemy auto attack should damage player")

    var low_defense_damage: Dictionary = CombatManager.calculate_damage(
        {"level": 1, "attack_power": 20, "crit_chance": 0.0, "crit_multiplier": 1.5},
        {"level": 1, "defense": 0}
    )
    var high_defense_damage: Dictionary = CombatManager.calculate_damage(
        {"level": 1, "attack_power": 20, "crit_chance": 0.0, "crit_multiplier": 1.5},
        {"level": 1, "defense": 40}
    )
    assert(high_defense_damage.get("amount", 0) < low_defense_damage.get("amount", 0), "Defense should reduce damage")

    CombatManager.end_battle()
    assert(not CombatManager.is_battle_active(), "Battle should end cleanly")

    print("Combat outcome regression test PASSED")
    get_tree().quit()
