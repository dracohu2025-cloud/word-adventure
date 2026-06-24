extends Node

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var trees: Node2D = village.get_node("Visuals/Trees")
    var stones: Node2D = village.get_node("Visuals/Stones")
    var visuals: Node2D = village.get_node("Visuals")
    var using_tiny_swords: bool = visuals.has_method("is_using_tiny_swords_assets") and visuals.is_using_tiny_swords_assets()
    var expected_bottoms := [
        Vector2(-520, 184),
        Vector2(-472, 184),
        Vector2(-96, -24),
        Vector2(-112, 208),
        Vector2(288, -184),
        Vector2(432, 176),
        Vector2(520, -232),
        Vector2(552, 224),
    ]
    var world_tile := 48

    if using_tiny_swords:
        if not _require(trees.get_child_count() == expected_bottoms.size(), "Tiny Swords trees should use one sprite per tree"):
            return
        for child in trees.get_children():
            if not _require(child is Sprite2D and child.get_meta("asset_source", "") == "tiny_swords", "Tiny Swords tree should be marked as licensed asset"):
                return
    else:
        if not _require(trees.get_child_count() == expected_bottoms.size() * 2, "Each tree should be composed from top and bottom tiles"):
            return
        for bottom in expected_bottoms:
            if not _require(_has_tree_tile_at(trees, bottom - Vector2(0, world_tile)), "Tree top tile missing above: " + str(bottom)):
                return
            if not _require(_has_tree_tile_at(trees, bottom), "Tree bottom tile missing at: " + str(bottom)):
                return

    for stone in stones.get_children():
        for tree_tile in trees.get_children():
            if not _require(not _sprite_rect(stone).intersects(_sprite_rect(tree_tile)), "Non-tree decoration overlaps tree at: " + str(stone.position)):
                return

    if not _banned_partial_tiles_are_unused(village):
        return

    print("Tree visual composition regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _has_tree_tile_at(trees: Node2D, position: Vector2) -> bool:
    for child in trees.get_children():
        if child is Sprite2D and child.position == position:
            return true
    return false

func _sprite_rect(sprite: Sprite2D) -> Rect2:
    var visual_size := Vector2(48, 48)
    return Rect2(sprite.position - visual_size / 2.0, visual_size)

func _banned_partial_tiles_are_unused(root: Node) -> bool:
    var banned_tile_paths := [
        "res://assets/third_party/kenney_tiny_town/Tiles/tile_0092.png",
    ]
    for sprite in _find_sprites(root):
        var texture: Texture2D = sprite.texture
        if texture != null and banned_tile_paths.has(texture.resource_path):
            return _require(false, "Partial object tile should not be used standalone: " + texture.resource_path)
    return true

func _find_sprites(root: Node) -> Array[Sprite2D]:
    var sprites: Array[Sprite2D] = []
    for child in root.get_children():
        if child is Sprite2D:
            sprites.append(child)
        sprites.append_array(_find_sprites(child))
    return sprites

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
