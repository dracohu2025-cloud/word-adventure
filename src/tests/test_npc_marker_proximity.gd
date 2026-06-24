extends Node
## Regression test for proximity-gated NPC interaction markers.

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame

    var player: CharacterBody2D = village.get_node("Player")
    var npc: Area2D = village.get_node("LibraryNPC")
    var interaction_marker: CanvasItem = npc.get_node("InteractionMarker")
    var hint_panel: Control = ControlHints.get_node("Panel")

    player.global_position = npc.global_position + Vector2(260, 0)
    await get_tree().physics_frame
    await get_tree().physics_frame
    assert(not interaction_marker.visible, "NPC marker should be hidden while player is far away")
    assert(not hint_panel.visible, "Contextual prompt should be hidden while player is far away")

    player.global_position = npc.global_position + Vector2(0, 64)
    await get_tree().physics_frame
    await get_tree().physics_frame
    assert(not interaction_marker.visible, "NPC exclamation marker should stay hidden when player enters interaction range")
    assert(hint_panel.visible, "Contextual prompt should appear when player enters interaction range")

    player.global_position = npc.global_position + Vector2(260, 0)
    await get_tree().physics_frame
    await get_tree().physics_frame
    assert(not interaction_marker.visible, "NPC marker should hide again after player leaves interaction range")
    assert(not hint_panel.visible, "Contextual prompt should hide again after player leaves interaction range")

    print("NPC contextual prompt proximity regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
