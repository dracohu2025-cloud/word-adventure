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
    var boss = village.get_node("WordImpBoss")
    assert(boss.is_available(), "Forest gate readiness should reveal the Word Imp boss")
    assert(not CombatManager.is_battle_active(), "Forest gate readiness should not auto-start combat")

    boss.start_interaction()
    assert(CombatManager.is_battle_active(), "Interacting with Word Imp should start combat")
    while CombatManager.get_enemy_hp() > 4:
        CombatManager.apply_answer_result(true, "attack")
    CombatManager.apply_answer_result(true, "capture")
    await get_tree().process_frame
    assert(gate_collision.disabled, "Forest gate should open after the Word Imp is captured")

    print("Forest gate unlock regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
