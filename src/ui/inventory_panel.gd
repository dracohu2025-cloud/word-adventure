extends CanvasLayer

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")
const DraggablePanelControllerScript := preload("res://src/ui/draggable_panel_controller.gd")

const UI_FRAME_PATH: String = "res://assets/licensed/tiny_swords/ui/panels/Button_Disable_9Slides.png"
const GOLD_ICON_PATH: String = "res://assets/licensed/tiny_swords/ui/icons/Icon_03.png"
const FILTER_ALL: String = "all"
const FILTER_EQUIPMENT: String = "equipment"
const FILTER_CONSUMABLE: String = "consumable"
const SLOT_COUNT: int = 20

@onready var panel: Panel = $Panel
@onready var frame_texture: NinePatchRect = $Panel/FrameTexture
@onready var close_button: Button = $Panel/CloseButton
@onready var title_label: Label = $Panel/TitleLabel
@onready var filter_all_button: Button = $Panel/FilterAllButton
@onready var filter_equipment_button: Button = $Panel/FilterEquipmentButton
@onready var filter_consumable_button: Button = $Panel/FilterConsumableButton
@onready var gold_icon: TextureRect = $Panel/GoldIcon
@onready var gold_label: Label = $Panel/GoldLabel
@onready var tooltip = $ItemTooltip

var _filter: String = FILTER_ALL
var _display_to_inventory_index: Dictionary = {}
var _drag_controller = null

func _ready() -> void:
    visible = false
    _drag_controller = DraggablePanelControllerScript.new()
    _drag_controller.attach(panel)
    _load_pixel_assets()
    _apply_style()
    _configure_filter_buttons()
    _bind_slots()
    close_button.pressed.connect(hide_panel)
    filter_all_button.pressed.connect(_set_filter.bind(FILTER_ALL))
    filter_equipment_button.pressed.connect(_set_filter.bind(FILTER_EQUIPMENT))
    filter_consumable_button.pressed.connect(_set_filter.bind(FILTER_CONSUMABLE))
    PlayerData.inventory_changed.connect(_refresh)
    PlayerData.equipment_changed.connect(_refresh)
    PlayerData.stats_changed.connect(_refresh)
    GameManager.state_changed.connect(_on_game_state_changed)
    _refresh()

func toggle_panel() -> void:
    if visible:
        hide_panel()
    else:
        show_panel()

func show_panel() -> void:
    visible = true
    _refresh()

func hide_panel() -> void:
    visible = false
    tooltip.hide_tooltip()

func _load_pixel_assets() -> void:
    frame_texture.texture = _load_runtime_texture(UI_FRAME_PATH)
    frame_texture.modulate = Color(0.34, 0.40, 0.27, 0.98)
    gold_icon.texture = _load_runtime_texture(GOLD_ICON_PATH)

func _apply_style() -> void:
    PixelUIStyle.apply_asset_panel_shell(panel)
    PixelUIStyle.apply_button(close_button)
    PixelUIStyle.apply_filter_button(filter_all_button)
    PixelUIStyle.apply_filter_button(filter_equipment_button)
    PixelUIStyle.apply_filter_button(filter_consumable_button)
    PixelUIStyle.apply_label(title_label, 22, Color(0.96, 0.82, 0.36, 1.0))
    PixelUIStyle.apply_label(gold_label, 18, Color(0.96, 0.82, 0.36, 1.0))

func _configure_filter_buttons() -> void:
    for button in [filter_all_button, filter_equipment_button, filter_consumable_button]:
        button.toggle_mode = true
        button.disabled = false

func _bind_slots() -> void:
    for display_index in range(SLOT_COUNT):
        var slot_node = panel.get_node("Slot%d" % display_index)
        slot_node.configure(display_index, {}, "", false)
        slot_node.left_clicked.connect(_on_slot_left_clicked)
        slot_node.right_clicked.connect(_on_slot_right_clicked)
        slot_node.hovered.connect(_on_slot_hovered)
        slot_node.unhovered.connect(_on_slot_unhovered)

func _set_filter(next_filter: String) -> void:
    _filter = next_filter
    tooltip.hide_tooltip()
    _refresh()

func _refresh() -> void:
    var inventory_slots := PlayerData.get_inventory_slots()
    var display_entries := _build_display_entries(inventory_slots)
    _display_to_inventory_index.clear()
    for display_index in range(SLOT_COUNT):
        var slot_node = panel.get_node("Slot%d" % display_index)
        var display_entry := Dictionary(display_entries[display_index])
        var inventory_index := int(display_entry.get("inventory_index", -1))
        var entry := Dictionary(display_entry.get("entry", {}))
        _display_to_inventory_index[display_index] = inventory_index
        slot_node.configure(display_index, entry, "", false)

    gold_label.text = "金币：%d" % PlayerData.gold
    _sync_filter_buttons()

func _build_display_entries(inventory_slots: Array[Dictionary]) -> Array[Dictionary]:
    var display_entries: Array[Dictionary] = []
    if _filter == FILTER_ALL:
        for inventory_index in range(SLOT_COUNT):
            display_entries.append({
                "inventory_index": inventory_index,
                "entry": inventory_slots[inventory_index],
            })
        return display_entries

    for inventory_index in range(inventory_slots.size()):
        var entry := Dictionary(inventory_slots[inventory_index])
        var item_id := String(entry.get("item_id", ""))
        if item_id.is_empty() or not _entry_matches_filter(item_id):
            continue
        display_entries.append({
            "inventory_index": inventory_index,
            "entry": entry,
        })

    while display_entries.size() < SLOT_COUNT:
        display_entries.append({
            "inventory_index": -1,
            "entry": {},
        })

    return display_entries

func _entry_matches_filter(item_id: String) -> bool:
    if _filter == FILTER_EQUIPMENT:
        return ItemDatabase.is_equipment(item_id)
    if _filter == FILTER_CONSUMABLE:
        return ItemDatabase.is_consumable(item_id)

    return true

func _sync_filter_buttons() -> void:
    filter_all_button.disabled = false
    filter_equipment_button.disabled = false
    filter_consumable_button.disabled = false
    filter_all_button.button_pressed = _filter == FILTER_ALL
    filter_equipment_button.button_pressed = _filter == FILTER_EQUIPMENT
    filter_consumable_button.button_pressed = _filter == FILTER_CONSUMABLE

func _on_slot_left_clicked(display_index: int) -> void:
    _show_tooltip_for_slot(display_index)

func _on_slot_right_clicked(display_index: int) -> void:
    var inventory_index := int(_display_to_inventory_index.get(display_index, -1))
    if inventory_index < 0:
        return
    var entry := PlayerData.get_inventory_slots()[inventory_index]
    var item_id := String(entry.get("item_id", ""))
    if item_id.is_empty():
        return

    var result := {}
    if ItemDatabase.is_equipment(item_id):
        result = PlayerData.equip_item(inventory_index)
    elif ItemDatabase.is_consumable(item_id):
        result = PlayerData.use_item(inventory_index)

    if bool(result.get("success", false)):
        tooltip.hide_tooltip()
        _refresh()

func _on_slot_hovered(display_index: int) -> void:
    _show_tooltip_for_slot(display_index)

func _on_slot_unhovered(_display_index: int) -> void:
    tooltip.hide_tooltip()

func _show_tooltip_for_slot(display_index: int) -> void:
    var inventory_index := int(_display_to_inventory_index.get(display_index, -1))
    if inventory_index < 0:
        tooltip.hide_tooltip()
        return
    var entry := PlayerData.get_inventory_slots()[inventory_index]
    var item_id := String(entry.get("item_id", ""))
    if item_id.is_empty():
        tooltip.hide_tooltip()
        return

    var slot_node = panel.get_node("Slot%d" % display_index)
    tooltip.show_item(item_id, slot_node.global_position + Vector2(slot_node.size.x, 0), _action_hint(item_id))

func _action_hint(item_id: String) -> String:
    if ItemDatabase.is_equipment(item_id):
        return "右键装备"
    if ItemDatabase.is_consumable(item_id):
        return "右键使用"

    return ""

func _on_game_state_changed(_state) -> void:
    if not GameManager.is_world_active():
        hide_panel()

func _load_runtime_texture(path: String) -> Texture2D:
    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    if error != OK:
        return null

    return ImageTexture.create_from_image(image)
