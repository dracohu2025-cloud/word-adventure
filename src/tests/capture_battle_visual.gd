extends Node
## Utility scene for capturing the real-time battle HUD.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping battle visual screenshot capture in headless mode")
        get_tree().quit()
        return

    QuestManager.reset_chapter()
    PlayerData.reset_runtime_state()
    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    CombatManager.start_boss_battle("word_imp")
    await get_tree().process_frame
    CombatManager.advance_battle(1.0)
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
