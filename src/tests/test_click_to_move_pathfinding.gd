extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame

    var player: CharacterBody2D = village.get_node("Player")
    player.global_position = Vector2(-120, 96)
    await get_tree().physics_frame

    if not _require(village.has_method("request_player_move_to"), "Village should expose click-to-move requests"):
        return
    if not _require(_click_world_position(village, Vector2(96, 96)), "Main road mouse click should start auto movement"):
        return
    if not _require(player.has_method("is_following_auto_path") and player.is_following_auto_path(), "Player should follow an auto path after a valid click"):
        return
    if not await _wait_until_near(player, Vector2(96, 96), 140):
        return

    if not _require(village.can_player_stand_at_position(player.global_position), "Player should stop on a valid road position"):
        return

    player.global_position = Vector2(464, 96)
    await get_tree().physics_frame
    if not _require(village.request_player_move_to(Vector2(480, -48)), "Forest spur click should start auto movement"):
        return
    if not await _wait_until_near(player, Vector2(480, -48), 140):
        return

    player.global_position = Vector2(-80, 96)
    await get_tree().physics_frame
    if not _require(village.request_player_move_to(Vector2(0, 120)), "Near-road click should snap to a valid road position"):
        return
    if not await _wait_until_near(player, Vector2(0, 96), 120):
        return

    player.global_position = Vector2(-120, 96)
    await get_tree().physics_frame
    if not _require(_click_world_position(village, Vector2(96, 40)), "Grass mouse click should snap to the nearest reachable road"):
        return
    if not await _wait_until_near(player, Vector2(96, 96), 140):
        return

    print("Click-to-move pathfinding regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _wait_until_near(player: CharacterBody2D, target: Vector2, frames: int) -> bool:
    for i in range(frames):
        await get_tree().physics_frame
        if player.global_position.distance_to(target) <= 8.0:
            return true

    return _require(
        false,
        "Player should reach click target. Current=%s Target=%s" % [player.global_position, target]
    )

func _click_world_position(village: Node2D, world_position: Vector2) -> bool:
    var viewport_position: Vector2 = village.get_viewport().get_canvas_transform() * world_position
    var click := InputEventMouseButton.new()
    click.button_index = MOUSE_BUTTON_LEFT
    click.pressed = true
    click.position = viewport_position
    click.global_position = viewport_position
    return village._handle_world_click(click)

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
