extends Node
## Regression test for leaving a narrow home doorway after touching an NPC.

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame

    var player: CharacterBody2D = village.get_node("Player")
    player.global_position = Vector2(-264, 88)
    await get_tree().physics_frame
    await _press_for("move_right", 40)

    if not _require(player.global_position.x >= -220.0, "Player should be able to leave the library doorway onto the main road"):
        return

    print("Player can leave NPC doorway regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _press_for(action: StringName, frames: int) -> void:
    Input.action_press(action)
    for i in range(frames):
        await get_tree().physics_frame
    Input.action_release(action)

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
