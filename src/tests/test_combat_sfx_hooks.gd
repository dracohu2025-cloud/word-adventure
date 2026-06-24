extends Node

const BLADE_SFX: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/blade_01.ogg"
const ENEMY_DEFEATED_SFX: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/creature_die_01.ogg"

func _ready() -> void:
    PlayerData.reset_runtime_state()
    QuestManager.reset_chapter()

    CombatManager.start_battle({
        "enemy_name": "SFX Probe",
        "max_hp": 200,
        "attack_power": 1,
        "defense": 0,
        "attack_speed": 0.1,
        "player_stats": {
            "level": 1,
            "max_hp": 120,
            "hp": 120,
            "max_mp": 40,
            "mp": 40,
            "attack_power": 20,
            "defense": 6,
            "attack_speed": 1.0,
            "crit_chance": 0.0,
            "crit_multiplier": 1.5,
        },
    })
    CombatManager.advance_battle(1.05)
    if AudioManager.get_last_sfx_stream_path() != BLADE_SFX:
        _fail("Player damage should trigger blade SFX")
        return

    CombatManager.end_battle()

    CombatManager.start_battle({
        "enemy_name": "Weak SFX Probe",
        "max_hp": 1,
        "attack_power": 1,
        "defense": 0,
        "attack_speed": 0.1,
        "player_stats": {
            "level": 1,
            "max_hp": 120,
            "hp": 120,
            "max_mp": 40,
            "mp": 40,
            "attack_power": 20,
            "defense": 6,
            "attack_speed": 1.0,
            "crit_chance": 0.0,
            "crit_multiplier": 1.5,
        },
    })
    CombatManager.advance_battle(1.05)
    if AudioManager.get_last_sfx_stream_path() != ENEMY_DEFEATED_SFX:
        _fail("Defeating an enemy should trigger enemy defeated SFX")
        return

    print("Combat SFX hook regression test PASSED")
    get_tree().quit()

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
