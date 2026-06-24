extends Node

func _ready() -> void:
    var battle_panel = load("res://scenes/ui/battle_panel.tscn").instantiate()
    add_child(battle_panel)
    await get_tree().process_frame

    CombatManager.start_boss_battle("word_imp")
    await get_tree().process_frame

    assert(not battle_panel.panel.visible, "Legacy answer battle panel should stay hidden during real-time combat")
    assert(battle_panel._current_answer == "", "Real-time combat should not build word-answer challenges")

    CombatManager.end_battle()
    battle_panel.queue_free()
    await get_tree().process_frame

    print("Battle panel real-time retirement regression test PASSED")
    get_tree().quit()
