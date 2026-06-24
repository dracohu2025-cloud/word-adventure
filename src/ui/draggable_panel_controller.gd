extends RefCounted
class_name DraggablePanelController

const DRAG_HANDLE_HEIGHT: float = 64.0

var _panel: Control = null
var _dragging: bool = false

func attach(panel: Control) -> void:
    _panel = panel
    _panel.gui_input.connect(_on_panel_gui_input)

func _on_panel_gui_input(event: InputEvent) -> void:
    if _panel == null:
        return

    if event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
        if mouse_event.button_index != MOUSE_BUTTON_LEFT:
            return

        if mouse_event.pressed:
            if not _is_drag_handle_position(mouse_event.position):
                return
            _dragging = true
            _panel.get_viewport().set_input_as_handled()
        elif _dragging:
            _dragging = false
            _panel.get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion and _dragging:
        var motion_event := event as InputEventMouseMotion
        _panel.position = _clamp_position(_panel.position + motion_event.relative)
        _panel.get_viewport().set_input_as_handled()

func _is_drag_handle_position(local_position: Vector2) -> bool:
    return Rect2(Vector2.ZERO, Vector2(_panel.size.x, DRAG_HANDLE_HEIGHT)).has_point(local_position)

func _clamp_position(next_position: Vector2) -> Vector2:
    var viewport_size := _panel.get_viewport().get_visible_rect().size
    var max_position := Vector2(
        max(0.0, viewport_size.x - _panel.size.x),
        max(0.0, viewport_size.y - _panel.size.y)
    )
    return Vector2(
        clampf(next_position.x, 0.0, max_position.x),
        clampf(next_position.y, 0.0, max_position.y)
    )
