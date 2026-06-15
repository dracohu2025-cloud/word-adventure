extends Node
## Regression test for player navigation around the village NPC.

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var player: CharacterBody2D = village.get_node("Player")
    var npc: Area2D = village.get_node("GardenNPC")
    player.global_position = npc.global_position + Vector2(-80, 100)

    Input.action_press("move_up")
    for i in range(60):
        await get_tree().physics_frame
    Input.action_release("move_up")

    print("Player final y: ", player.global_position.y, ", NPC y: ", npc.global_position.y)
    assert(player.global_position.y <= npc.global_position.y, "Player should be able to move up beside the NPC's row")

    print("✅ Player navigation regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
