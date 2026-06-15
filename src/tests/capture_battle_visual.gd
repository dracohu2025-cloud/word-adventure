extends Node
## Utility scene for capturing the normal battle panel.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping battle visual screenshot capture in headless mode")
        get_tree().quit()
        return

    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    CombatManager.start_battle({
        "enemy_id": "word_sprite",
        "enemy_name": "Word Sprite",
        "enemy_hp": 12,
        "player_hp": 20,
        "question_word": "monster",
        "challenge_type": "meaning",
    })
    await get_tree().process_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/battle_panel_visual_pass.png")
    print("Saved battle visual screenshot")
    image = null
    CombatManager.end_battle()
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
