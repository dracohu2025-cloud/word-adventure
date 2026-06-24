extends Node
## Utility scene for capturing an NPC-localized dialogue bubble.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping dialogue bubble screenshot capture in headless mode")
        get_tree().quit()
        return

    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    var npc = village.get_node("BlacksmithNPC")
    npc.start_interaction()
    await get_tree().process_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/dialogue_bubble_visual_pass.png")
    print("Saved dialogue bubble visual screenshot")
    image = null
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
