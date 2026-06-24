extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()

    _assert(PlayerData.get_inventory_slots().size() == PlayerData.INVENTORY_SLOT_COUNT, "Inventory should always expose twenty slots")

    var potion_result := PlayerData.add_item("minor_healing_potion", 13)
    _assert(bool(potion_result.get("success", false)), "Adding stackable potions should succeed")
    var slots := PlayerData.get_inventory_slots()
    _assert(String(slots[0].get("item_id", "")) == "minor_healing_potion", "First slot should contain potions")
    _assert(int(slots[0].get("quantity", 0)) == 10, "First potion stack should fill to ten")
    _assert(int(slots[1].get("quantity", 0)) == 3, "Second potion stack should contain the remainder")

    PlayerData.reset_runtime_state()
    var sword_result := PlayerData.add_item("training_sword", PlayerData.INVENTORY_SLOT_COUNT)
    _assert(bool(sword_result.get("success", false)), "Adding twenty equipment items should fill the bag")
    var overflow_result := PlayerData.add_item("beginner_shield", 1)
    _assert(not bool(overflow_result.get("success", true)), "Adding equipment to a full bag should fail")
    _assert(String(overflow_result.get("reason", "")) == "inventory_full", "Full bag failure should be explicit")
    _assert(int(overflow_result.get("added", -1)) == 0, "Full bag should not add the overflow item")

    print("Inventory stack and capacity regression test PASSED")
    get_tree().quit()

func _assert(condition: bool, message: String) -> void:
    if condition:
        return

    push_error(message)
    get_tree().quit(1)

