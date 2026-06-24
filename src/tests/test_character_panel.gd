extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    var add_result := PlayerData.add_item("training_sword", 1)
    _assert(bool(add_result.get("success", false)), "Test should add starter weapon")
    var equip_result := PlayerData.equip_item(0)
    _assert(bool(equip_result.get("success", false)), "Test should equip starter weapon")

    var panel = load("res://scenes/ui/character_panel.tscn").instantiate()
    add_child(panel)
    await get_tree().process_frame

    _assert(not panel.visible, "Character panel should start hidden")
    panel.show_panel()
    await get_tree().process_frame
    _assert(panel.visible, "Character panel should open through public API")
    _require_node(panel, "Panel/SlotWeapon")
    _require_node(panel, "Panel/SlotRing")
    _require_node(panel, "Panel/AttackStatsLabel")
    _require_node(panel, "ItemTooltip")

    var weapon_slot = panel.get_node("Panel/SlotWeapon")
    var ring_slot = panel.get_node("Panel/SlotRing")
    var attack_stats_label: Label = panel.get_node("Panel/AttackStatsLabel")
    _assert(weapon_slot.item_id == "training_sword", "Weapon slot should render equipped sword")
    _assert(not weapon_slot.locked, "Weapon slot should be open")
    _assert(ring_slot.locked, "Ring slot should be visibly locked for future progression")
    _assert(attack_stats_label.text.contains("攻击力"), "Character panel should show attack stats")

    weapon_slot.left_clicked.emit(weapon_slot.slot_index)
    await get_tree().process_frame
    _assert(panel.get_node("ItemTooltip").visible, "Clicking an equipped slot should show tooltip")

    var right_click := InputEventMouseButton.new()
    right_click.button_index = MOUSE_BUTTON_RIGHT
    right_click.pressed = true
    weapon_slot._gui_input(right_click)
    await get_tree().process_frame
    _assert(not PlayerData.equipment.has(ItemDatabase.SLOT_WEAPON), "Right click should unequip weapon")
    _assert(weapon_slot.item_id.is_empty(), "Weapon slot should refresh after unequip")

    panel.queue_free()
    await get_tree().process_frame

    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    _require_node(village, "CharacterPanel")
    var village_panel = village.get_node("CharacterPanel")
    _assert(not village_panel.visible, "Village character panel should start hidden")

    var toggle := InputEventAction.new()
    toggle.action = "toggle_player_panels"
    toggle.pressed = true
    village._unhandled_input(toggle)
    await get_tree().process_frame
    _assert(village_panel.visible, "Village should toggle character panel with unified panel action")

    print("Character panel regression test PASSED")
    get_tree().quit()

func _require_node(root: Node, node_path: String) -> void:
    if not root.has_node(node_path):
        _fail("Missing character panel node: " + node_path)

func _assert(condition: bool, message: String) -> void:
    if condition:
        return

    _fail(message)

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
