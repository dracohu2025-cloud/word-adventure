extends Node
## Regression test for solid NPCs and village obstacles.

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame

    var player: CharacterBody2D = village.get_node("Player")
    var npc: Area2D = village.get_node("GardenNPC")

    player.global_position = npc.global_position + Vector2(-80, 0)
    await get_tree().physics_frame
    await _press_for("move_right", 90)
    assert(
        player.global_position.x <= npc.global_position.x - 20,
        "Player should be blocked by the NPC body"
    )

    var house_center := Vector2(-264, -48)
    player.global_position = house_center + Vector2(-180, 0)
    await get_tree().physics_frame
    await _press_for("move_right", 120)
    assert(
        player.global_position.x <= house_center.x - 70,
        "Player should be blocked by the house collision"
    )

    print("✅ Player collision blocking regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _press_for(action: StringName, frames: int) -> void:
    Input.action_press(action)
    for i in range(frames):
        await get_tree().physics_frame
    Input.action_release(action)
