extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    QuestManager.reset_chapter()

    QuestManager.complete_branch("blacksmith")
    var blacksmith_rewards := QuestManager.get_branch_reward_results("blacksmith")
    _assert(blacksmith_rewards.size() == 1, "Blacksmith branch should record one item reward")
    _assert(_inventory_quantity("training_sword") == 1, "Blacksmith reward should enter the bag")
    _assert(String(blacksmith_rewards[0].get("item_name", "")) == "训练木剑", "Branch reward should include Chinese item name")

    var deterministic_drops := CombatManager.roll_loot_table([
        {"item_id": "worn_leather_gloves", "quantity": 1, "chance": 0.5},
        {"item_id": "minor_healing_potion", "quantity": 2, "chance": 0.5},
    ], [0.2, 0.8])
    _assert(deterministic_drops.size() == 1, "Forced rolls should make loot table deterministic")
    _assert(String(deterministic_drops[0].get("item_id", "")) == "worn_leather_gloves", "Only successful forced roll should drop")

    PlayerData.reset_runtime_state()
    var overlay = load("res://scenes/ui/combat_focus_overlay.tscn").instantiate()
    add_child(overlay)
    await get_tree().process_frame

    await _win_test_battle({
        "enemy_id": "loot_imp",
        "enemy_name": "Loot Imp",
        "max_hp": 8,
        "gold_reward": 3,
        "experience_reward": 4,
        "loot_table": [
            {"item_id": "worn_leather_gloves", "quantity": 1, "chance": 1.0},
        ],
    })
    var reward_label: Label = overlay.get_node("SettlementPanel/RewardLabel")
    _assert(reward_label.text.contains("金币 +3"), "Settlement should keep gold reward line")
    _assert(reward_label.text.contains("经验 +4"), "Settlement should keep experience reward line")
    _assert(reward_label.text.contains("旧皮手套"), "Settlement should list item drops")
    _assert(_inventory_quantity("worn_leather_gloves") == 1, "Dropped equipment should enter the bag")
    overlay.confirm_settlement()
    await get_tree().process_frame

    PlayerData.reset_runtime_state()
    var fill_result := PlayerData.add_item("training_sword", PlayerData.INVENTORY_SLOT_COUNT)
    _assert(bool(fill_result.get("success", false)), "Test setup should fill the bag")
    await _win_test_battle({
        "enemy_id": "full_bag_imp",
        "enemy_name": "Full Bag Imp",
        "max_hp": 8,
        "gold_reward": 0,
        "experience_reward": 0,
        "loot_table": [
            {"item_id": "minor_healing_potion", "quantity": 1, "chance": 1.0},
        ],
    })
    _assert(reward_label.text.contains("背包已满"), "Settlement should show bag-full item failure")
    _assert(_inventory_quantity("minor_healing_potion") == 0, "Full bag should not receive non-stackable overflow space")

    overlay.queue_free()
    await get_tree().process_frame
    print("Loot rewards regression test PASSED")
    get_tree().quit()

func _win_test_battle(enemy_overrides: Dictionary) -> void:
    var enemy_data := {
        "attack_power": 1,
        "defense": 0,
        "attack_speed": 0.1,
        "crit_chance": 0.0,
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
    }
    for key in enemy_overrides.keys():
        enemy_data[key] = enemy_overrides[key]

    CombatManager.start_battle(enemy_data)
    await get_tree().process_frame
    while CombatManager.is_battle_active():
        CombatManager.advance_battle(0.4)
        await get_tree().process_frame

func _inventory_quantity(item_id: String) -> int:
    var total := 0
    for entry in PlayerData.get_inventory_slots():
        if String(entry.get("item_id", "")) == item_id:
            total += int(entry.get("quantity", 0))

    return total

func _assert(condition: bool, message: String) -> void:
    if condition:
        return

    push_error(message)
    get_tree().quit(1)
