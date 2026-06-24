extends Node

const ItemSlotScene := preload("res://scenes/ui/item_slot.tscn")
const ItemTooltipScene := preload("res://scenes/ui/item_tooltip.tscn")

var _right_click_index: int = -1

func _ready() -> void:
    var slot := ItemSlotScene.instantiate()
    add_child(slot)
    slot.configure(4, {"item_id": "minor_healing_potion", "quantity": 3})
    await get_tree().process_frame

    _assert(slot.item_id == "minor_healing_potion", "Slot should store item id")
    _assert(slot.quantity == 3, "Slot should store quantity")
    _assert(slot.get_node("Icon").visible, "Slot should show item icon")
    _assert(slot.get_node("QuantityLabel").visible, "Stacked consumable should show quantity")

    slot.right_clicked.connect(_on_slot_right_clicked)
    var right_click := InputEventMouseButton.new()
    right_click.button_index = MOUSE_BUTTON_RIGHT
    right_click.pressed = true
    slot._gui_input(right_click)
    _assert(_right_click_index == 4, "Slot should emit right click signal with slot index")

    slot.configure(9, {}, "戒指", true)
    await get_tree().process_frame
    _assert(slot.locked, "Slot should support locked state")
    _assert(slot.get_node("LockLabel").visible, "Locked slot should show lock label")

    var tooltip := ItemTooltipScene.instantiate()
    add_child(tooltip)
    tooltip.set_item("training_sword", "右键装备")
    await get_tree().process_frame
    _assert(tooltip.visible, "Tooltip should show known item")
    _assert(tooltip.get_node("Margin/Content/TitleLabel").text == "训练木剑", "Tooltip should show Chinese item name")
    _assert(tooltip.get_node("Margin/Content/TypeLabel").text.contains("普通"), "Tooltip should show quality name")
    _assert(tooltip.get_node("Margin/Content/StatsLabel").text.contains("力量"), "Tooltip should show attribute text")
    _assert(tooltip.get_node("Margin/Content/ActionLabel").text == "右键装备", "Tooltip should show action hint")

    print("Item UI primitives regression test PASSED")
    get_tree().quit()

func _assert(condition: bool, message: String) -> void:
    if condition:
        return

    push_error(message)
    get_tree().quit(1)

func _on_slot_right_clicked(index: int) -> void:
    _right_click_index = index
