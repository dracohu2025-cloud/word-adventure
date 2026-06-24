extends Node
## Regression test for keeping NPCs visually separated from nearby props.

const NPC_VISUAL_SIZE: Vector2 = Vector2(44, 44)
const PROP_VISUAL_SIZE: Vector2 = Vector2(44, 44)

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var branch_anchors: Node2D = village.get_node("Visuals/BranchAnchors")
    for npc_path in ["LibraryNPC", "BlacksmithNPC", "GardenNPC"]:
        var npc: Node2D = village.get_node(npc_path)
        var npc_rect := Rect2(npc.global_position - NPC_VISUAL_SIZE / 2.0, NPC_VISUAL_SIZE)
        for prop in _find_sprites(branch_anchors):
            var prop_rect := Rect2(prop.global_position - PROP_VISUAL_SIZE / 2.0, PROP_VISUAL_SIZE)
            if not _require(not npc_rect.intersects(prop_rect), npc_path + " overlaps branch decoration at " + str(prop.position)):
                return

    print("Village NPC decoration spacing regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

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
