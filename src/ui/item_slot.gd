extends Panel
class_name ItemSlot

signal left_clicked(slot_index: int)
signal right_clicked(slot_index: int)
signal hovered(slot_index: int)
signal unhovered(slot_index: int)

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel
@onready var hint_label: Label = $HintLabel
@onready var lock_label: Label = $LockLabel

var slot_index: int = -1
var item_id: String = ""
var quantity: int = 0
var locked: bool = false
var selected: bool = false
var empty_label: String = ""

var _hovered: bool = false

func _ready() -> void:
    custom_minimum_size = Vector2(56, 56)
    mouse_filter = Control.MOUSE_FILTER_STOP
    PixelUIStyle.apply_label(quantity_label, 14)
    PixelUIStyle.apply_label(hint_label, 12, Color(0.62, 0.56, 0.45, 1.0))
    PixelUIStyle.apply_label(lock_label, 18, Color(0.96, 0.82, 0.36, 1.0))
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    _refresh()

func configure(index: int, entry: Dictionary = {}, label: String = "", is_locked: bool = false) -> void:
    slot_index = index
    empty_label = label
    locked = is_locked
    item_id = String(entry.get("item_id", ""))
    quantity = int(entry.get("quantity", 0))
    if not is_node_ready():
        return

    _refresh()

func set_item(new_item_id: String, new_quantity: int = 1) -> void:
    item_id = new_item_id
    quantity = new_quantity
    locked = false
    if not is_node_ready():
        return

    _refresh()

func clear_item(label: String = "") -> void:
    item_id = ""
    quantity = 0
    empty_label = label
    if not is_node_ready():
        return

    _refresh()

func set_locked_state(is_locked: bool, label: String = "锁") -> void:
    locked = is_locked
    empty_label = label
    if not is_node_ready():
        return

    _refresh()

func set_selected_state(is_selected: bool) -> void:
    selected = is_selected
    if not is_node_ready():
        return

    _refresh_style()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            left_clicked.emit(slot_index)
            accept_event()
        elif event.button_index == MOUSE_BUTTON_RIGHT:
            right_clicked.emit(slot_index)
            accept_event()

func _on_mouse_entered() -> void:
    _hovered = true
    hovered.emit(slot_index)
    _refresh_style()

func _on_mouse_exited() -> void:
    _hovered = false
    unhovered.emit(slot_index)
    _refresh_style()

func _refresh() -> void:
    var has_item := not item_id.is_empty()
    icon.visible = has_item
    icon.texture = _load_icon(item_id) if has_item else null
    quantity_label.visible = has_item and quantity > 1
    quantity_label.text = str(quantity)
    hint_label.visible = not has_item and not locked and not empty_label.is_empty()
    hint_label.text = empty_label
    lock_label.visible = locked
    lock_label.text = empty_label if not empty_label.is_empty() else "锁"
    _refresh_style()

func _refresh_style() -> void:
    var border := Color.TRANSPARENT
    if not item_id.is_empty():
        var item := ItemDatabase.get_item(item_id)
        border = ItemDatabase.get_quality_color(int(item.get("quality", ItemDatabase.QUALITY_COMMON)))
    PixelUIStyle.apply_item_slot(self, border, locked, selected, _hovered)

func _load_icon(source_item_id: String) -> Texture2D:
    var path := String(ItemDatabase.get_item(source_item_id).get("icon_path", ""))
    if path.is_empty() or not ResourceLoader.exists(path):
        return null

    return load(path)
