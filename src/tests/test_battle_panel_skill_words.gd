extends Node

func _ready() -> void:
    var battle_panel = load("res://scenes/ui/battle_panel.tscn").instantiate()
    add_child(battle_panel)
    await get_tree().process_frame

    CombatManager.start_boss_battle("word_imp")
    await get_tree().process_frame

    assert(battle_panel._current_answer == "sword", "Attack button should ask for sword")
    assert(battle_panel.question_label.text == "剑", "Attack challenge should show sword meaning")

    battle_panel._select_skill("shield")
    assert(battle_panel._current_answer == "shield", "Shield button should ask for shield")
    assert(battle_panel.question_label.text == "盾", "Shield challenge should show shield meaning")

    while CombatManager.get_enemy_hp() > 4:
        CombatManager.apply_answer_result(true, "attack")
        await get_tree().process_frame

    battle_panel._select_skill("capture")
    assert(battle_panel._current_answer == "book", "Capture button should ask for book")
    assert(battle_panel.question_label.text == "书", "Capture challenge should show book meaning")

    CombatManager.end_battle()
    battle_panel.queue_free()
    await get_tree().process_frame

    print("Battle panel skill word regression test PASSED")
    get_tree().quit()
