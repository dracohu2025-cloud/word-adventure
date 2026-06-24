extends Node
## Utility scene for capturing contextual interaction hints.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping contextual hint screenshot capture in headless mode")
        get_tree().quit()
        return

    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().physics_frame

    var player: CharacterBody2D = village.get_node("Player")
    var npc: Area2D = village.get_node("BlacksmithNPC")
    player.global_position = npc.global_position + Vector2(0, 48)
    await get_tree().physics_frame
    await get_tree().physics_frame
    await get_tree().physics_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/contextual_hint_visual_pass.png")
    print("Saved contextual hint visual screenshot")
    image = null
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
