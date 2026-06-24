extends Node
## Regression test for home-door routes and NPC placement.

const HOME_DOOR_POINTS: Dictionary = {
    "BlacksmithNPC": Vector2(-504, 78),
    "LibraryNPC": Vector2(-264, 78),
    "GardenNPC": Vector2(240, 78),
}

const NPC_DOOR_STANCE_POINTS: Dictionary = {
    "BlacksmithNPC": Vector2(-504, 52),
    "LibraryNPC": Vector2(-264, 52),
    "GardenNPC": Vector2(240, 52),
}

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame

    if not _require(village.has_node("Visuals/HouseRoads"), "Village should expose a dedicated house-road visual layer"):
        return

    var house_roads: Node2D = village.get_node("Visuals/HouseRoads")
    for npc_path in HOME_DOOR_POINTS.keys():
        var npc: Node2D = village.get_node(npc_path)
        var stance: Vector2 = NPC_DOOR_STANCE_POINTS[npc_path]
        var approach: Vector2 = HOME_DOOR_POINTS[npc_path]

        if not _require(npc.global_position.distance_to(stance) <= 1.0, npc_path + " should stand at its home doorway"):
            return
        if not _require(village.can_player_stand_at_position(approach), npc_path + " doorway should be reachable"):
            return
        if not _require(_has_road_sprite_near(house_roads, approach), npc_path + " should have a visible route to the door"):
            return

    if not _require(not village.can_player_stand_at_position(Vector2(-504, 40)), "House walls should still block walking into the doorway"):
        return
    if not _require(not village.can_player_stand_at_position(Vector2(0, 72)), "Narrow road should not allow the player to stand above the path"):
        return
    if not _require(not village.can_player_stand_at_position(Vector2(0, 120)), "Narrow road should not allow the player to stand below the path"):
        return

    print("Village routes to home doors regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _has_road_sprite_near(road_layer: Node2D, position: Vector2) -> bool:
    for child in road_layer.get_children():
        if child is Sprite2D and child.position.distance_to(position) <= 24.0:
            return true
    return false

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
