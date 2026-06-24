extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    PlayerData.apply_damage(50)
    _assert(bool(PlayerData.add_item("training_sword", 1).get("success", false)), "Test should add weapon")
    _assert(bool(PlayerData.add_item("beginner_shield", 1).get("success", false)), "Test should add offhand")
    _assert(bool(PlayerData.add_item("minor_healing_potion", 2).get("success", false)), "Test should add potion stack")

    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var character_panel = village.get_node("CharacterPanel")
    var inventory_panel = village.get_node("InventoryPanel")
    _assert(not character_panel.visible, "Character panel should start hidden in village")
    _assert(not inventory_panel.visible, "Inventory panel should start hidden in village")

    village._unhandled_input(_action("toggle_player_panels"))
    await get_tree().process_frame
    _assert(inventory_panel.visible, "Unified panel action should open inventory panel")
    _assert(character_panel.visible, "Unified panel action should open character panel")

    village._unhandled_input(_action("toggle_player_panels"))
    await get_tree().process_frame
    _assert(not inventory_panel.visible, "Unified panel action should close inventory panel")
    _assert(not character_panel.visible, "Unified panel action should close character panel")

    village._unhandled_input(_action("toggle_player_panels"))
    await get_tree().process_frame
    _assert(inventory_panel.visible, "Unified panel action should reopen inventory panel")
    _assert(character_panel.visible, "Unified panel action should reopen character panel")

    _assert(_drag_panel_by(character_panel.get_node("Panel"), Vector2(72, 28), Vector2(44, 30)), "Character panel should be draggable from its title area")
    _assert(_drag_panel_by(inventory_panel.get_node("Panel"), Vector2(72, 28), Vector2(-38, 26)), "Inventory panel should be draggable from its title area")

    var inventory_weapon_slot = inventory_panel.get_node("Panel/Slot0")
    var inventory_potion_slot = inventory_panel.get_node("Panel/Slot2")
    var character_weapon_slot = character_panel.get_node("Panel/SlotWeapon")
    _assert(inventory_weapon_slot.item_id == "training_sword", "Inventory should render starter weapon")
    _assert(inventory_potion_slot.item_id == "minor_healing_potion", "Inventory should render potion stack")

    _right_click(inventory_weapon_slot)
    await get_tree().process_frame
    _assert(PlayerData.equipment.has(ItemDatabase.SLOT_WEAPON), "Right-clicking bag equipment should equip it")
    _assert(character_weapon_slot.item_id == "training_sword", "Character panel should sync equipped weapon")
    _assert(inventory_weapon_slot.item_id.is_empty(), "Equipping should clear the source bag slot")

    _right_click(character_weapon_slot)
    await get_tree().process_frame
    _assert(not PlayerData.equipment.has(ItemDatabase.SLOT_WEAPON), "Right-clicking character slot should unequip")
    _assert(character_weapon_slot.item_id.is_empty(), "Character weapon slot should clear after unequip")
    _assert(_inventory_quantity("training_sword") == 1, "Unequipped weapon should return to the bag")

    var hp_before := PlayerData.hp
    _right_click(inventory_potion_slot)
    await get_tree().process_frame
    _assert(PlayerData.hp > hp_before, "Right-clicking consumable should heal the player")
    _assert(_inventory_quantity("minor_healing_potion") == 1, "Potion stack should decrement after use")

    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    print("Inventory equipment UI integration test PASSED")
    get_tree().quit()

func _action(action_name: String) -> InputEventAction:
    var event := InputEventAction.new()
    event.action = action_name
    event.pressed = true
    return event

func _right_click(slot_node: Control) -> void:
    var event := InputEventMouseButton.new()
    event.button_index = MOUSE_BUTTON_RIGHT
    event.pressed = true
    slot_node._gui_input(event)

func _drag_panel_by(panel: Control, local_start: Vector2, relative: Vector2) -> bool:
    var start_position := panel.position
    var press := InputEventMouseButton.new()
    press.button_index = MOUSE_BUTTON_LEFT
    press.pressed = true
    press.position = local_start
    press.global_position = panel.global_position + local_start
    panel.gui_input.emit(press)

    var move := InputEventMouseMotion.new()
    move.position = local_start + relative
    move.global_position = panel.global_position + local_start + relative
    move.relative = relative
    panel.gui_input.emit(move)

    var release := InputEventMouseButton.new()
    release.button_index = MOUSE_BUTTON_LEFT
    release.pressed = false
    release.position = local_start + relative
    release.global_position = panel.global_position + local_start + relative
    panel.gui_input.emit(release)
    return panel.position != start_position

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
