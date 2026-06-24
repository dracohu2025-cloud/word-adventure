extends Node
## Utility scene for capturing the combat settlement overlay.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping combat settlement screenshot capture in headless mode")
        get_tree().quit()
        return

    QuestManager.reset_chapter()
    PlayerData.reset_runtime_state()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    CombatManager.start_battle({
        "enemy_id": "reward_imp",
        "enemy_name": "Reward Imp",
        "max_hp": 8,
        "attack_power": 1,
        "defense": 0,
        "attack_speed": 0.1,
        "crit_chance": 0.0,
        "gold_reward": 7,
        "experience_reward": 11,
        "loot_table": [
            {"item_id": "apprentice_guard_charm", "quantity": 1, "chance": 1.0},
            {"item_id": "minor_healing_potion", "quantity": 2, "chance": 1.0},
        ],
        "player_stats": {
            "level": 1,
            "max_hp": 100,
            "hp": 100,
            "max_mp": 40,
            "mp": 40,
            "attack_power": 40,
            "defense": 10,
            "attack_speed": 3.0,
            "crit_chance": 0.0,
            "crit_multiplier": 1.5,
        },
    })
    await get_tree().process_frame

    while CombatManager.is_battle_active():
        CombatManager.advance_battle(0.4)
        await get_tree().process_frame

    await get_tree().process_frame
    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/combat_settlement_visual_pass.png")
    print("Saved combat settlement visual screenshot")

    var overlay = village.get_node("CombatFocusOverlay")
    overlay.confirm_settlement()
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
