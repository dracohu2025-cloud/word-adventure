extends Node

const TILE_PATH_TEMPLATE: String = "res://assets/third_party/kenney_tiny_town/Tiles/tile_%04d.png"
const DUNGEON_TILE_PATH_TEMPLATE: String = "res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_%04d.png"
const BANNED_DIRT_ROAD_TILE_IDS: Array[int] = [12, 13, 14, 24, 25, 26, 36, 37, 38, 39, 40, 41, 42]
const STONE_ROAD_TILE_IDS: Array[int] = [40]

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var visuals: Node2D = village.get_node("Visuals")
    var main_road: Node2D = village.get_node("Visuals/MainRoad")
    var house_roads: Node2D = village.get_node("Visuals/HouseRoads")
    var exit_road: Node2D = village.get_node("Visuals/ExitRoad")
    var using_tiny_swords: bool = visuals.has_method("is_using_tiny_swords_assets") and visuals.is_using_tiny_swords_assets()

    if not _road_has_expected_tiles(main_road, "main road", [
        Vector2(-576, 96),
        Vector2(0, 96),
        Vector2(576, 96),
    ], using_tiny_swords):
        return

    if not _road_has_no_tiles_at(main_road, "main road", [
        Vector2(-576, 48),
        Vector2(-576, 144),
        Vector2(0, 48),
        Vector2(0, 144),
        Vector2(576, 48),
        Vector2(576, 144),
    ]):
        return

    if not _road_has_expected_tiles(house_roads, "house road", [
        Vector2(-504, 72),
        Vector2(-264, 72),
        Vector2(240, 72),
    ], using_tiny_swords):
        return

    if not _road_has_expected_tiles(exit_road, "forest road", [
        Vector2(480, 48),
        Vector2(480, 0),
        Vector2(480, -48),
    ], using_tiny_swords):
        return

    if not _road_has_no_tiles_at(house_roads, "house road", [
        Vector2(-504, 24),
        Vector2(-264, 24),
        Vector2(240, 24),
        Vector2(336, 48),
    ]):
        return

    if not _road_has_no_tiles_at(exit_road, "forest road", [
        Vector2(-240, 48),
        Vector2(144, 48),
        Vector2(528, 96),
    ]):
        return

    if not _require(main_road.get_child_count() == 25, "Main road should stay a single path strip"):
        return
    if not _require(house_roads.get_child_count() == 3, "Each active home should have one narrow doorway spur"):
        return
    if not _require(exit_road.get_child_count() <= 4, "Forest road should stay narrow and intentional"):
        return

    if not _road_avoids_dirt_tiles(main_road, "main road"):
        return
    if not _road_avoids_dirt_tiles(house_roads, "house road"):
        return
    if not _road_avoids_dirt_tiles(exit_road, "forest road"):
        return

    print("Road visual composition regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _road_has_expected_tiles(road: Node2D, label: String, positions: Array, using_tiny_swords: bool) -> bool:
    var allowed_paths := _stone_road_paths()
    for position in positions:
        var sprite := _find_sprite_at(road, position)
        if sprite == null:
            return _require(false, "%s missing road tile at %s" % [label, position])

        if using_tiny_swords:
            if sprite.get_meta("asset_source", "") != "tiny_swords":
                return _require(false, "%s should use Tiny Swords road tile at %s" % [label, position])
            continue

        if sprite.texture == null or not allowed_paths.has(sprite.texture.resource_path):
            return _require(false, "%s should use stone road tile at %s" % [label, position])
    return true

func _road_avoids_dirt_tiles(road: Node2D, label: String) -> bool:
    var banned_paths := []
    for tile_id in BANNED_DIRT_ROAD_TILE_IDS:
        banned_paths.append(TILE_PATH_TEMPLATE % tile_id)

    for child in road.get_children():
        if child is Sprite2D and child.texture != null and banned_paths.has(child.texture.resource_path):
            return _require(false, "%s should not use dirt road tile: %s" % [label, child.texture.resource_path])
    return true

func _road_has_no_tiles_at(road: Node2D, label: String, positions: Array) -> bool:
    for position in positions:
        if _find_sprite_at(road, position) != null:
            return _require(false, "%s should not place a road tile at %s" % [label, position])
    return true

func _stone_road_paths() -> Array[String]:
    var paths: Array[String] = []
    for tile_id in STONE_ROAD_TILE_IDS:
        paths.append(DUNGEON_TILE_PATH_TEMPLATE % tile_id)
    return paths

func _find_sprite_at(parent: Node2D, position: Vector2) -> Sprite2D:
    for child in parent.get_children():
        if child is Sprite2D and child.position == position:
            return child
    return null

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
