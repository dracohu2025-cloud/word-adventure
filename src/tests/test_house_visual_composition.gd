extends Node

const TILE_PATH_TEMPLATE: String = "res://assets/third_party/kenney_tiny_town/Tiles/tile_%04d.png"

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var houses: Node2D = village.get_node("Visuals/Houses")
    var branch_anchors: Node2D = village.get_node("Visuals/BranchAnchors")
    var visuals: Node2D = village.get_node("Visuals")
    var using_tiny_swords: bool = visuals.has_method("is_using_tiny_swords_assets") and visuals.is_using_tiny_swords_assets()
    var world_tile := 48
    var house_specs := [
        {
            "name": "west blue-roof house",
            "origin": Vector2(-552, -72),
            "tiles": [
                [48, 49, 50],
                [60, 63, 62],
                [72, 74, 75],
            ],
        },
        {
            "name": "north red-roof house",
            "origin": Vector2(-312, -96),
            "tiles": [
                [52, 53, 54],
                [64, 67, 66],
                [76, 78, 79],
            ],
        },
    ]

    if using_tiny_swords:
        if not _tiny_swords_houses_are_present(houses):
            return
    else:
        for spec in house_specs:
            if not _house_matches_grid(houses, spec, world_tile):
                return

    if not _branch_anchors_do_not_cover_houses(houses, branch_anchors):
        return

    print("House visual composition regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _house_matches_grid(houses: Node2D, spec: Dictionary, world_tile: int) -> bool:
    var origin: Vector2 = spec["origin"]
    var tiles: Array = spec["tiles"]
    for row in range(tiles.size()):
        for col in range(tiles[row].size()):
            var tile_id := int(tiles[row][col])
            var position := origin + Vector2(col * world_tile, row * world_tile)
            var sprite := _find_sprite_at(houses, position)
            if sprite == null:
                return _require(false, "%s missing tile at %s" % [spec["name"], position])

            var expected_path := TILE_PATH_TEMPLATE % tile_id
            if sprite.texture == null or sprite.texture.resource_path != expected_path:
                return _require(false, "%s expected %s at %s" % [spec["name"], expected_path, position])
    return true

func _find_sprite_at(parent: Node2D, position: Vector2) -> Sprite2D:
    for child in parent.get_children():
        if child is Sprite2D and child.position == position:
            return child
    return null

func _tiny_swords_houses_are_present(houses: Node2D) -> bool:
    if not _require(houses.get_child_count() == 3, "Tiny Swords village should use one house sprite per village NPC"):
        return false
    for child in houses.get_children():
        if not _require(child is Sprite2D, "Tiny Swords house child should be a Sprite2D"):
            return false
        if not _require(child.get_meta("asset_source", "") == "tiny_swords", "Tiny Swords house should be marked as licensed asset"):
            return false
    return true

func _branch_anchors_do_not_cover_houses(houses: Node2D, branch_anchors: Node2D) -> bool:
    for anchor_sprite in _find_sprites(branch_anchors):
        for house_sprite in _find_sprites(houses):
            if _sprite_rect(anchor_sprite).intersects(_sprite_rect(house_sprite)):
                return _require(false, "Branch anchor overlaps house at: " + str(anchor_sprite.position))
    return true

func _find_sprites(root: Node) -> Array[Sprite2D]:
    var sprites: Array[Sprite2D] = []
    for child in root.get_children():
        if child is Sprite2D:
            sprites.append(child)
        sprites.append_array(_find_sprites(child))
    return sprites

func _sprite_rect(sprite: Sprite2D) -> Rect2:
    var visual_size := Vector2(48, 48)
    return Rect2(sprite.position - visual_size / 2.0, visual_size)

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
