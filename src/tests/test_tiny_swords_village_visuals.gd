extends Node

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var visuals: Node2D = village.get_node("Visuals")
    if not _require(visuals.has_method("is_using_tiny_swords_assets"), "Village visuals should report Tiny Swords usage"):
        return
    if not _require(visuals.is_using_tiny_swords_assets(), "Village visuals should use Tiny Swords licensed assets"):
        return
    if not _require(_node_contains_licensed_texture(village.get_node("Visuals/Ground")), "Ground should use Tiny Swords terrain"):
        return
    if not _require(_node_contains_licensed_texture(village.get_node("Visuals/Houses")), "Houses should use Tiny Swords buildings"):
        return
    if not _require(_node_contains_licensed_texture(village.get_node("Visuals/Trees")), "Trees should use Tiny Swords tree assets"):
        return

    print("Tiny Swords village visual regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _node_contains_licensed_texture(root: Node) -> bool:
    for child in root.get_children():
        if child is Sprite2D and child.texture != null and child.get_meta("asset_source", "") == "tiny_swords":
            return true
        if _node_contains_licensed_texture(child):
            return true
    return false

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
