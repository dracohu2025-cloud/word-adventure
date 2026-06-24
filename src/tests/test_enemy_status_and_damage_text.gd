extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    QuestManager.reset_chapter()

    var boss = load("res://scenes/world/boss_encounter.tscn").instantiate()
    add_child(boss)
    await get_tree().process_frame

    _require_node(boss, "EnemyStatusBar")
    _require_node(boss, "DamageTextLayer")

    var status_bar = boss.get_node("EnemyStatusBar")
    var damage_layer: Node2D = boss.get_node("DamageTextLayer")
    assert(not status_bar.visible, "Enemy status bar should start hidden")

    CombatManager.start_boss_battle("word_imp")
    await get_tree().process_frame

    assert(not status_bar.visible, "Enemy status bar should stay hidden on the world map during battle")

    var damage_text_count := damage_layer.get_child_count()
    CombatManager.advance_battle(1.0)
    await get_tree().process_frame
    assert(damage_layer.get_child_count() > damage_text_count, "Damage event should spawn floating damage text")

    CombatManager.end_battle()
    await get_tree().process_frame
    assert(not status_bar.visible, "Enemy status bar should hide after battle")

    boss.queue_free()
    await get_tree().process_frame

    QuestManager.reset_chapter()
    PlayerData.reset_runtime_state()
    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    var village_boss = village.get_node("WordImpBoss")
    var village_status_bar = village_boss.get_node("EnemyStatusBar")
    CombatManager.start_boss_battle("word_imp")
    await get_tree().process_frame
    assert(not village_status_bar.visible, "Village boss status bar should stay hidden during combat")

    village.queue_free()
    CombatManager.end_battle()
    await get_tree().process_frame
    print("Enemy status and damage text regression test PASSED")
    get_tree().quit()

func _require_node(root: Node, node_path: String) -> void:
    if not root.has_node(node_path):
        push_error("Missing boss combat UI node: " + node_path)
        get_tree().quit(1)
