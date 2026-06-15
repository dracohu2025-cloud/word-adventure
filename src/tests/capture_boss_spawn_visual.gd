extends Node
## Utility scene for capturing the Word Imp spawn position on the village map.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping Word Imp spawn screenshot capture in headless mode")
        get_tree().quit()
        return

    QuestManager.reset_chapter()
    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/word_imp_spawn_visual_pass.png")
    print("Saved Word Imp spawn visual screenshot")
    image = null
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
