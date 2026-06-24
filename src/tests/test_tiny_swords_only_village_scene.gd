extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame
    await get_tree().physics_frame

    var visuals: Node2D = village.get_node("Visuals")
    if not _require(visuals.has_method("is_using_tiny_swords_assets") and visuals.is_using_tiny_swords_assets(), "Village visuals should be in Tiny Swords mode"):
        return
    if not _require(_all_visual_sprites_are_tiny_swords(visuals), "All village visual sprites should come from Tiny Swords"):
        return

    for npc_path in ["LibraryNPC", "BlacksmithNPC", "GardenNPC"]:
        var npc: Node = village.get_node(npc_path)
        var tiny_sprite := npc.get_node_or_null("TinySwordsSprite")
        if not _require(tiny_sprite is AnimatedSprite2D and tiny_sprite.visible, npc_path + " should use a Tiny Swords animated sprite"):
            return

    var boss: Node = village.get_node("WordImpBoss")
    var boss_sprite := boss.get_node_or_null("TinySwordsSprite")
    if not _require(boss_sprite is AnimatedSprite2D and boss_sprite.visible, "Boss should use a Tiny Swords animated sprite"):
        return

    if not _require(_has_no_visible_kenney_sprite(village), "Visible village scene should not display Kenney textures"):
        return

    print("Tiny Swords only village scene regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _all_visual_sprites_are_tiny_swords(root: Node) -> bool:
    for child in root.get_children():
        if child is Sprite2D and child.texture != null and child.get_meta("asset_source", "") != "tiny_swords":
            return false
        if not _all_visual_sprites_are_tiny_swords(child):
            return false
    return true

func _has_no_visible_kenney_sprite(root: Node) -> bool:
    for child in root.get_children():
        if child is Sprite2D and child.is_visible_in_tree() and _sprite_uses_kenney_texture(child):
            return false
        if not _has_no_visible_kenney_sprite(child):
            return false
    return true

func _sprite_uses_kenney_texture(sprite: Sprite2D) -> bool:
    var texture := sprite.texture
    if texture == null:
        return false
    if texture is AtlasTexture:
        texture = texture.atlas
    return texture != null and texture.resource_path.begins_with("res://assets/third_party/kenney")

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
