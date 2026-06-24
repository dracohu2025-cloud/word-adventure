extends Node

func _ready() -> void:
    var player = load("res://scenes/world/player.tscn").instantiate()
    add_child(player)
    await get_tree().process_frame

    var animation_sprite: Node = player.get_node_or_null("TinySwordsSprite")
    if not _require(animation_sprite is AnimatedSprite2D, "Player should expose a TinySwordsSprite AnimatedSprite2D"):
        return
    if not _require(animation_sprite.visible, "Tiny Swords player animation should be visible when licensed assets are installed"):
        return
    if not _require(animation_sprite.sprite_frames != null, "Tiny Swords player should have generated SpriteFrames"):
        return
    if not _require(animation_sprite.sprite_frames.has_animation("idle"), "Tiny Swords player should have idle animation"):
        return
    if not _require(animation_sprite.sprite_frames.has_animation("run"), "Tiny Swords player should have run animation"):
        return
    if not _require(animation_sprite.sprite_frames.get_frame_count("idle") == 8, "Warrior idle should use 8 frames"):
        return
    if not _require(animation_sprite.sprite_frames.get_frame_count("run") == 6, "Warrior run should use 6 frames"):
        return

    print("Tiny Swords player animation regression test PASSED")
    player.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
