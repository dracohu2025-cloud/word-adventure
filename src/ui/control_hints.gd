extends CanvasLayer

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")
const PROMPT_FRAME_TEXTURE: Texture2D = preload("res://assets/licensed/tiny_swords/ui/panels/Button_Disable_9Slides.png")
const ACTION_HIGHLIGHT_TEXTURE: Texture2D = preload("res://assets/licensed/tiny_swords/ui/buttons/Button_Hover_3Slides.png")
const CONTEXT_HINT_SIZE: Vector2 = Vector2(156, 38)
const MENU_HINT_SIZE: Vector2 = Vector2(420, 44)
const SCREEN_MARGIN: float = 24.0
const TARGET_OFFSET: Vector2 = Vector2(-78, -94)
const CONTEXT_PROMPT_FONT_SIZE: int = 14
const MENU_PROMPT_FONT_SIZE: int = 16
const CONTEXT_KEY_BACKGROUND_RECT: Rect2 = Rect2(0, 0, 76, 38)
const CONTEXT_KEY_RECT: Rect2 = Rect2(8, 0, 60, 38)
const CONTEXT_DIVIDER_RECT: Rect2 = Rect2(77, 8, 2, 22)
const CONTEXT_ACTION_HIGHLIGHT_RECT: Rect2 = Rect2(80, 0, 76, 38)
const CONTEXT_ACTION_RECT: Rect2 = Rect2(88, 0, 60, 38)
const PROMPT_NORMAL_MODULATE: Color = Color(1.0, 1.0, 1.0, 0.98)
const PROMPT_HOVER_MODULATE: Color = Color(1.0, 1.0, 1.0, 1.0)
const PROMPT_PRESSED_MODULATE: Color = Color(0.86, 0.82, 0.72, 1.0)
const PROMPT_TEXT_COLOR: Color = Color(0.08, 0.12, 0.10, 1.0)
const ACTION_NORMAL_MODULATE: Color = Color(1.0, 1.0, 1.0, 0.98)
const ACTION_HOVER_MODULATE: Color = Color(1.12, 1.12, 1.05, 1.0)
const ACTION_PRESSED_MODULATE: Color = Color(0.78, 0.84, 0.82, 1.0)

@onready var panel: Panel = $Panel
@onready var frame_texture: NinePatchRect = $Panel/FrameTexture
@onready var key_background: NinePatchRect = $Panel/KeyBackground
@onready var hint_label: Label = $Panel/HintLabel
@onready var divider: ColorRect = $Panel/Divider
@onready var action_highlight: NinePatchRect = $Panel/ActionHighlight
@onready var action_label: Label = $Panel/ActionLabel
@onready var action_button: Button = $Panel/ActionButton

var _context_target: Node2D = null
var _button_hovered: bool = false
var _button_pressed: bool = false

func _ready() -> void:
    panel.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
    panel.visible = false
    frame_texture.texture = PROMPT_FRAME_TEXTURE
    frame_texture.modulate = PROMPT_NORMAL_MODULATE
    frame_texture.visible = false
    key_background.texture = PROMPT_FRAME_TEXTURE
    key_background.modulate = PROMPT_NORMAL_MODULATE
    key_background.visible = false
    action_highlight.texture = ACTION_HIGHLIGHT_TEXTURE
    action_highlight.modulate = ACTION_NORMAL_MODULATE
    action_highlight.visible = false
    divider.visible = false
    action_label.visible = false
    action_button.visible = false
    PixelUIStyle.apply_panel(panel)
    PixelUIStyle.apply_label(hint_label, CONTEXT_PROMPT_FONT_SIZE, PROMPT_TEXT_COLOR)
    PixelUIStyle.apply_label(action_label, CONTEXT_PROMPT_FONT_SIZE, PROMPT_TEXT_COLOR)
    _apply_prompt_hit_button()
    action_button.pressed.connect(_on_action_button_pressed)
    action_button.mouse_entered.connect(_on_action_button_mouse_entered)
    action_button.mouse_exited.connect(_on_action_button_mouse_exited)
    action_button.button_down.connect(_on_action_button_down)
    action_button.button_up.connect(_on_action_button_up)
    await get_tree().process_frame
    GameManager.state_changed.connect(_on_game_state_changed)
    update_hint()

func update_hint() -> void:
    var current_scene = get_tree().current_scene
    if current_scene and current_scene.scene_file_path == "res://scenes/main_menu.tscn":
        _show_menu_hint()
    elif _context_target == null:
        panel.visible = false

func show_interaction_hint(target: Node2D, text: String, action_text: String = "") -> void:
    if target == null or not GameManager.is_world_active():
        return

    _context_target = target
    PixelUIStyle.apply_asset_panel_shell(panel)
    _apply_context_prompt_layout()
    hint_label.text = text
    action_label.text = action_text if not action_text.is_empty() else _action_text_from_hint(text)
    frame_texture.visible = false
    key_background.visible = true
    divider.visible = true
    action_highlight.visible = true
    action_label.visible = true
    action_button.text = ""
    action_button.visible = true
    panel.size = CONTEXT_HINT_SIZE
    panel.visible = true
    _button_hovered = false
    _button_pressed = false
    _sync_prompt_visual_state()
    _position_near_context_target()

func hide_interaction_hint(target: Node2D) -> void:
    if target != null and target != _context_target:
        return
    clear_interaction_hint()

func clear_interaction_hint() -> void:
    _context_target = null
    frame_texture.visible = false
    key_background.visible = false
    divider.visible = false
    action_highlight.visible = false
    action_label.visible = false
    action_button.visible = false
    panel.visible = false

func contains_screen_point(screen_position: Vector2) -> bool:
    if not panel.visible:
        return false
    return Rect2(panel.global_position, panel.size).has_point(screen_position)

func _process(_delta: float) -> void:
    if _context_target == null or not panel.visible:
        return
    if not is_instance_valid(_context_target) or not GameManager.is_world_active():
        clear_interaction_hint()
        return

    _position_near_context_target()

func _on_game_state_changed(_state) -> void:
    if not GameManager.is_world_active():
        clear_interaction_hint()
    elif _context_target == null:
        panel.visible = false

func _show_menu_hint() -> void:
    _context_target = null
    PixelUIStyle.apply_panel(panel)
    _apply_menu_prompt_layout()
    hint_label.text = "按 空格/回车 开始  |  或点击开始按钮"
    frame_texture.visible = false
    key_background.visible = false
    divider.visible = false
    action_highlight.visible = false
    action_label.visible = false
    action_button.visible = false
    panel.size = MENU_HINT_SIZE
    var viewport_size := get_viewport().get_visible_rect().size
    panel.position = Vector2(20.0, viewport_size.y - MENU_HINT_SIZE.y - 20.0)
    panel.visible = true

func _apply_context_prompt_layout() -> void:
    panel.size = CONTEXT_HINT_SIZE
    PixelUIStyle.apply_label(hint_label, CONTEXT_PROMPT_FONT_SIZE, PROMPT_TEXT_COLOR)
    PixelUIStyle.apply_label(action_label, CONTEXT_PROMPT_FONT_SIZE, PROMPT_TEXT_COLOR)
    _place_control(key_background, CONTEXT_KEY_BACKGROUND_RECT)
    _place_control(hint_label, CONTEXT_KEY_RECT)
    _place_control(divider, CONTEXT_DIVIDER_RECT)
    _place_control(action_highlight, CONTEXT_ACTION_HIGHLIGHT_RECT)
    _place_control(action_label, CONTEXT_ACTION_RECT)
    _place_control(action_button, CONTEXT_ACTION_HIGHLIGHT_RECT)
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    hint_label.clip_text = true
    action_label.clip_text = true

func _apply_menu_prompt_layout() -> void:
    panel.size = MENU_HINT_SIZE
    PixelUIStyle.apply_label(hint_label, MENU_PROMPT_FONT_SIZE)
    _place_control(hint_label, Rect2(12, 0, MENU_HINT_SIZE.x - 24, MENU_HINT_SIZE.y))
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    hint_label.clip_text = true

func _place_control(control: Control, rect: Rect2) -> void:
    control.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
    control.position = rect.position
    control.size = rect.size

func _on_action_button_pressed() -> void:
    if _context_target == null or not is_instance_valid(_context_target):
        clear_interaction_hint()
        return
    if not GameManager.is_world_active():
        return
    if _context_target.has_method("start_interaction"):
        _context_target.start_interaction()

func _on_action_button_mouse_entered() -> void:
    _button_hovered = true
    _sync_prompt_visual_state()

func _on_action_button_mouse_exited() -> void:
    _button_hovered = false
    _button_pressed = false
    _sync_prompt_visual_state()

func _on_action_button_down() -> void:
    _button_pressed = true
    _sync_prompt_visual_state()

func _on_action_button_up() -> void:
    _button_pressed = false
    _sync_prompt_visual_state()

func _position_near_context_target() -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    var target_position := _context_target.get_global_transform_with_canvas().origin
    var panel_position := target_position + TARGET_OFFSET
    if panel_position.y < SCREEN_MARGIN:
        panel_position.y = target_position.y + 48.0

    panel_position.x = clampf(panel_position.x, SCREEN_MARGIN, viewport_size.x - CONTEXT_HINT_SIZE.x - SCREEN_MARGIN)
    panel_position.y = clampf(panel_position.y, SCREEN_MARGIN, viewport_size.y - CONTEXT_HINT_SIZE.y - SCREEN_MARGIN)
    panel.position = panel_position

func _apply_prompt_hit_button() -> void:
    action_button.flat = true
    for style_name in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
        action_button.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
    for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
        action_button.add_theme_color_override(color_name, Color.TRANSPARENT)

func _sync_prompt_visual_state() -> void:
    if _button_pressed:
        key_background.modulate = PROMPT_NORMAL_MODULATE
        action_highlight.modulate = ACTION_PRESSED_MODULATE
    elif _button_hovered:
        key_background.modulate = PROMPT_HOVER_MODULATE
        action_highlight.modulate = ACTION_HOVER_MODULATE
    else:
        key_background.modulate = PROMPT_NORMAL_MODULATE
        action_highlight.modulate = ACTION_NORMAL_MODULATE

func _action_text_from_hint(text: String) -> String:
    if text.contains("挑战"):
        return "挑战"
    if text.contains("交谈"):
        return "交谈"
    return "互动"
