extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    PlayerData.apply_damage(40)
    PlayerData.add_gold(12)
    _assert(bool(PlayerData.add_item("training_sword", 1).get("success", false)), "Test should add sword")
    _assert(bool(PlayerData.add_item("minor_healing_potion", 3).get("success", false)), "Test should add potion stack")

    var panel = load("res://scenes/ui/inventory_panel.tscn").instantiate()
    add_child(panel)
    await get_tree().process_frame
    _assert(not panel.visible, "Inventory panel should start hidden")
    panel.show_panel()
    await get_tree().process_frame
    _assert(panel.visible, "Inventory panel should open through public API")
    _require_node(panel, "Panel/Slot0")
    _require_node(panel, "Panel/Slot19")
    _require_node(panel, "Panel/GoldLabel")
    _require_node(panel, "ItemTooltip")

    var slot0 = panel.get_node("Panel/Slot0")
    var slot1 = panel.get_node("Panel/Slot1")
    _assert(slot0.item_id == "training_sword", "First slot should show sword")
    _assert(slot1.item_id == "minor_healing_potion", "Second slot should show potion")
    _assert(slot1.quantity == 3, "Potion should show stacked quantity")
    _assert(panel.get_node("Panel/GoldLabel").text.contains("12"), "Inventory should show gold")
    _assert_filter_state(panel, "FilterAllButton")

    panel.get_node("Panel/FilterEquipmentButton").pressed.emit()
    await get_tree().process_frame
    _assert_filter_state(panel, "FilterEquipmentButton")
    _assert(slot0.item_id == "training_sword", "Equipment filter should show equipment")
    _assert(slot1.item_id.is_empty(), "Equipment filter should hide consumables")

    panel.get_node("Panel/FilterConsumableButton").pressed.emit()
    await get_tree().process_frame
    _assert_filter_state(panel, "FilterConsumableButton")
    _assert(slot0.item_id == "minor_healing_potion", "Consumable filter should show consumables")
    _assert(slot1.item_id.is_empty(), "Consumable filter should hide equipment")

    panel.get_node("Panel/FilterAllButton").pressed.emit()
    await get_tree().process_frame
    _assert_filter_state(panel, "FilterAllButton")
    _assert(slot0.item_id == "training_sword", "All filter should restore the original bag order")
    _assert(slot1.item_id == "minor_healing_potion", "All filter should show consumables in their bag slot")

    slot0.left_clicked.emit(slot0.slot_index)
    await get_tree().process_frame
    _assert(panel.get_node("ItemTooltip").visible, "Clicking a bag item should show tooltip")

    var right_click := InputEventMouseButton.new()
    right_click.button_index = MOUSE_BUTTON_RIGHT
    right_click.pressed = true
    slot0._gui_input(right_click)
    await get_tree().process_frame
    _assert(PlayerData.equipment.has(ItemDatabase.SLOT_WEAPON), "Right clicking equipment should equip it")
    _assert(slot0.item_id.is_empty(), "Equipped item should leave the bag slot")

    var hp_before := PlayerData.hp
    slot1._gui_input(right_click)
    await get_tree().process_frame
    _assert(PlayerData.hp > hp_before, "Right clicking consumable should use it")
    _assert(slot1.quantity == 2, "Potion stack should decrement after use")

    panel.get_node("Panel/FilterConsumableButton").pressed.emit()
    await get_tree().process_frame
    _assert_filter_state(panel, "FilterConsumableButton")
    var filtered_slot0 = panel.get_node("Panel/Slot0")
    _assert(filtered_slot0.item_id == "minor_healing_potion", "Consumable filter should show potion first")

    panel.queue_free()
    await get_tree().process_frame

    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    _require_node(village, "InventoryPanel")
    var village_panel = village.get_node("InventoryPanel")
    _assert(not village_panel.visible, "Village inventory panel should start hidden")

    var toggle := InputEventAction.new()
    toggle.action = "toggle_player_panels"
    toggle.pressed = true
    village._unhandled_input(toggle)
    await get_tree().process_frame
    _assert(village_panel.visible, "Village should toggle inventory panel with unified panel action")

    print("Inventory panel regression test PASSED")
    get_tree().quit()

func _require_node(root: Node, node_path: String) -> void:
    if not root.has_node(node_path):
        _fail("Missing inventory panel node: " + node_path)

func _assert_filter_state(panel: Node, active_button_name: String) -> void:
    for button_name in ["FilterAllButton", "FilterEquipmentButton", "FilterConsumableButton"]:
        var button: Button = panel.get_node("Panel/%s" % button_name)
        _assert(not button.disabled, "Filter buttons should stay clickable: " + button_name)
        _assert(button.button_pressed == (button_name == active_button_name), "Filter button pressed state mismatch: " + button_name)
        _assert_filter_style(button, button_name)

func _assert_filter_style(button: Button, button_name: String) -> void:
    var normal_style := button.get_theme_stylebox("normal") as StyleBoxFlat
    var pressed_style := button.get_theme_stylebox("pressed") as StyleBoxFlat
    _assert(normal_style != null, "Filter button should have a normal pixel style: " + button_name)
    _assert(pressed_style != null, "Filter button should have a pressed pixel style: " + button_name)
    _assert(_color_score(pressed_style.border_color) > _color_score(normal_style.border_color), "Selected filter should use a brighter border: " + button_name)
    _assert(pressed_style.border_width_left > normal_style.border_width_left, "Selected filter should use a stronger border: " + button_name)

func _color_score(color: Color) -> float:
    return color.r + color.g + color.b

func _assert(condition: bool, message: String) -> void:
    if condition:
        return

    _fail(message)

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
