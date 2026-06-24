extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    PlayerData.reset_runtime_state()
    CombatManager.start_boss_battle("word_imp")

    assert(CombatManager.is_battle_active(), "Battle should start")
    assert(CombatManager.get_turn_phase() == CombatManager.PHASE_REAL_TIME, "Battle should no longer use answer turns")
    assert(CombatManager.get_turn_count() == 0, "Real-time combat should not expose turn count")
    assert(CombatManager.get_enemy_intent().is_empty(), "Real-time combat should not expose answer-turn intent")

    var enemy_hp_before := CombatManager.get_enemy_hp()
    CombatManager.apply_answer_result(true, "attack")
    assert(CombatManager.get_enemy_hp() == enemy_hp_before, "Legacy answer actions should not drive combat")

    CombatManager.advance_battle(1.0)
    assert(CombatManager.get_enemy_hp() < enemy_hp_before, "Real-time tick should drive player damage")

    CombatManager.end_battle()

    print("Turn-based combat retirement regression test PASSED")
    get_tree().quit()
