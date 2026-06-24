extends Node
## Utility scene for capturing the localized puzzle dialogue panel.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping dialogue puzzle screenshot capture in headless mode")
        get_tree().quit()
        return

    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    var npc = village.get_node("LibraryNPC")
    npc.start_interaction()
    DialogueManager.advance()
    DialogueManager.advance()
    DialogueManager.advance()
    await get_tree().process_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/dialogue_puzzle_visual_pass.png")
    print("Saved dialogue puzzle visual screenshot")
    image = null
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
