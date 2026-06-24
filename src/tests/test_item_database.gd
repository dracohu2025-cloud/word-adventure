extends Node

func _ready() -> void:
    _assert(ItemDatabase.has_item("training_sword"), "Training sword should exist")
    _assert(ItemDatabase.has_item("minor_healing_potion"), "Healing potion should exist")
    _assert(ItemDatabase.get_open_equipment_slots().size() == 8, "Starter equipment should expose eight open slots")
    _assert(ItemDatabase.get_locked_equipment_slots().has(ItemDatabase.SLOT_RING), "Ring slot should be locked for the starter village")

    for quality_id in range(0, 9):
        var quality := ItemDatabase.get_quality(quality_id)
        _assert(not String(quality.get("name", "")).is_empty(), "Quality should have a Chinese name")
        _assert(quality.has("color"), "Quality should define a color")
        _assert(ItemDatabase.get_quality_color(quality_id) is Color, "Quality color should be readable")

    var sword := ItemDatabase.get_item("training_sword")
    _assert(String(sword.get("name", "")) == "训练木剑", "Item should expose Chinese name")
    _assert(String(sword.get("slot", "")) == ItemDatabase.SLOT_WEAPON, "Training sword should be a weapon")
    _assert(ItemDatabase.is_equipment("training_sword"), "Training sword should be equipment")
    _assert(not ItemDatabase.is_stackable("training_sword"), "Equipment should not stack")

    var potion := ItemDatabase.get_item("minor_healing_potion")
    _assert(ItemDatabase.is_consumable("minor_healing_potion"), "Potion should be consumable")
    _assert(ItemDatabase.get_stack_limit("minor_healing_potion") == 10, "Potion should stack to ten")
    _assert(String(potion.get("icon_path", "")).begins_with("res://"), "Item should use a project asset path")

    print("Item database regression test PASSED")
    get_tree().quit()

func _assert(condition: bool, message: String) -> void:
    if condition:
        return

    push_error(message)
    get_tree().quit(1)
