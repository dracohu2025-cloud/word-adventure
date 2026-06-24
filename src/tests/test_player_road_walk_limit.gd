extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame

    if not _require(village.has_method("is_walkable_position"), "Village should expose walkable-position checks"):
        return
    if not _require(village.has_method("can_player_stand_at_position"), "Village should validate the player's ground footprint"):
        return
    if not _require(village.is_walkable_position(Vector2(0, 96)), "Main road center should be walkable"):
        return
    if not _require(village.can_player_stand_at_position(Vector2(0, 96)), "Player should fit on the one-tile main road"):
        return
    if not _require(not village.can_player_stand_at_position(Vector2(0, 72)), "Player should not drift north off a one-tile main road"):
        return
    if not _require(not village.can_player_stand_at_position(Vector2(0, 120)), "Player should not drift south off a one-tile main road"):
        return
    if not _require(village.can_player_stand_at_position(Vector2(240, 78)), "Garden spur should connect to the main road"):
        return
    if not _require(village.can_player_stand_at_position(Vector2(240, 66)), "Garden spur should provide a narrow approach tile"):
        return
    if not _require(village.is_walkable_position(Vector2(240, 66)), "Garden NPC approach should stay walkable"):
        return
    if not _require(village.can_player_stand_at_position(Vector2(480, -48)), "Boss spur should provide a narrow approach tile"):
        return
    if not _require(village.is_walkable_position(Vector2(464, -72)), "Boss interaction area should stay reachable from the spur"):
        return
    if not _require(not village.is_walkable_position(Vector2(0, -260)), "Open grass should not be walkable"):
        return

    var player: CharacterBody2D = village.get_node("Player")
    player.global_position = Vector2(0, 96)
    await get_tree().physics_frame
    await _press_for("move_up", 120)

    if not _require(player.global_position.y >= 87.0, "Player should stay inside the one-tile main road when moving north"):
        return

    player.global_position = Vector2(0, 96)
    await get_tree().physics_frame
    await _press_for("move_down", 120)

    if not _require(player.global_position.y <= 105.0, "Player should stay inside the one-tile main road when moving south"):
        return

    print("Player road walk limit regression test PASSED")
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
