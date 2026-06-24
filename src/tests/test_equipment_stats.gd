extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    PlayerData.restore_full_resources()

    var base_stats := PlayerData.get_combat_stats()
    _assert(int(base_stats.get("attack_power", 0)) == PlayerData.DEFAULT_ATTACK_POWER, "Base attack should remain unchanged without equipment")
    _assert(int(base_stats.get("max_hp", 0)) == PlayerData.DEFAULT_MAX_HP, "Base HP should remain unchanged without equipment")

    PlayerData.add_item("training_sword", 1)
    var equip_sword := PlayerData.equip_item(0)
    _assert(bool(equip_sword.get("success", false)), "Equipping sword from bag should succeed")
    _assert(String(PlayerData.equipment.get(ItemDatabase.SLOT_WEAPON, "")) == "training_sword", "Weapon slot should contain sword")

    var sword_stats := PlayerData.get_combat_stats()
    _assert(int(sword_stats.get("attack_power", 0)) > int(base_stats.get("attack_power", 0)), "Sword should increase attack power")
    _assert(int(sword_stats.get("max_hp", 0)) > int(base_stats.get("max_hp", 0)), "Sword stamina should increase max HP")

    PlayerData.add_item("beginner_shield", 1)
    var equip_shield := PlayerData.equip_item(0)
    _assert(bool(equip_shield.get("success", false)), "Equipping shield from bag should succeed")
    var shield_stats := PlayerData.get_combat_stats()
    _assert(int(shield_stats.get("defense", 0)) > int(sword_stats.get("defense", 0)), "Shield armor should increase defense")

    var unequip_weapon := PlayerData.unequip_slot(ItemDatabase.SLOT_WEAPON)
    _assert(bool(unequip_weapon.get("success", false)), "Unequipping weapon should succeed when bag has space")
    _assert(not PlayerData.equipment.has(ItemDatabase.SLOT_WEAPON), "Weapon slot should be empty after unequip")

    PlayerData.apply_damage(50)
    PlayerData.add_item("minor_healing_potion", 1)
    var potion_index := _find_item_slot("minor_healing_potion")
    _assert(potion_index != -1, "Potion should be in the bag")
    var hp_before := PlayerData.hp
    var use_potion := PlayerData.use_item(potion_index)
    _assert(bool(use_potion.get("success", false)), "Using potion should succeed")
    _assert(PlayerData.hp > hp_before, "Potion should restore HP")
    _assert(_find_item_slot("minor_healing_potion") == -1, "Consumed potion should leave the bag")

    print("Equipment stats regression test PASSED")
    get_tree().quit()

func _find_item_slot(item_id: String) -> int:
    var slots := PlayerData.get_inventory_slots()
    for index in range(slots.size()):
        if String(slots[index].get("item_id", "")) == item_id:
            return index

    return -1

func _assert(condition: bool, message: String) -> void:
    if condition:
        return

    push_error(message)
    get_tree().quit(1)

