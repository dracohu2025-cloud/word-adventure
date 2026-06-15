extends Node

func _ready() -> void:
    CombatManager.start_battle({
        "enemy_id": "word_sprite",
        "enemy_name": "Word Sprite",
        "enemy_hp": 12,
        "player_hp": 20,
    })

    var player_hp_before_attack := CombatManager.get_player_hp()
    CombatManager.apply_answer_result(true, "attack")
    assert(CombatManager.get_enemy_hp() < 12, "Correct attack should damage enemy")
    assert(CombatManager.get_player_hp() < player_hp_before_attack, "Enemy should counterattack after a correct attack")

    var player_hp_before := CombatManager.get_player_hp()
    CombatManager.apply_answer_result(false, "attack")
    assert(CombatManager.get_player_hp() < player_hp_before, "Incorrect answer should trigger counterattack")

    CombatManager.end_battle()

    CombatManager.start_battle({
        "enemy_id": "word_sprite",
        "enemy_name": "Word Sprite",
        "enemy_hp": 12,
        "player_hp": 20,
    })

    var player_hp_before_shield := CombatManager.get_player_hp()
    CombatManager.apply_answer_result(true, "shield")
    assert(CombatManager.get_player_hp() == player_hp_before_shield, "Correct shield should block the enemy turn")

    CombatManager.apply_answer_result(false, "shield")
    assert(CombatManager.get_player_hp() < player_hp_before_shield, "Incorrect shield should let the enemy hit")

    CombatManager.end_battle()
    assert(not CombatManager.is_battle_active(), "Battle should end cleanly")

    print("Combat outcome regression test PASSED")
    get_tree().quit()
