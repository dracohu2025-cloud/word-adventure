extends CanvasLayer

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")

const BUBBLE_SIZE: Vector2 = Vector2(560, 172)
const SCREEN_MARGIN: float = 28.0
const SPEAKER_TOP_OFFSET: float = 88.0
const SPEAKER_BOTTOM_OFFSET: float = 56.0
const POINTER_WIDTH: float = 14.0
const POINTER_HEIGHT: float = 18.0

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var body_label: Label = $Panel/BodyLabel
@onready var continue_hint_label: Label = $Panel/ContinueHintLabel
@onready var next_button: Button = $Panel/NextButton
@onready var pointer: Polygon2D = $Pointer
@onready var speaker_highlight: Line2D = $SpeakerHighlight

func _ready() -> void:
    panel.visible = false
    pointer.visible = false
    speaker_highlight.visible = false
    panel.set_anchors_preset(Control.PRESET_TOP_LEFT, false)
    panel.size = BUBBLE_SIZE
    _apply_pixel_style()
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    GameManager.state_changed.connect(_on_state_changed)
    next_button.pressed.connect(_on_next_pressed)

func _on_dialogue_started() -> void:
    panel.visible = true
    pointer.visible = true
    speaker_highlight.visible = true
    update_text()

func _on_state_changed(_state) -> void:
    if GameManager.current_state != GameManager.GameState.DIALOGUE:
        panel.visible = false
        pointer.visible = false
        speaker_highlight.visible = false

func _input(event: InputEvent) -> void:
    if GameManager.current_state == GameManager.GameState.DIALOGUE and event.is_action_pressed("interact"):
        _on_next_pressed()

func _on_next_pressed() -> void:
    DialogueManager.advance()
    update_text()

func update_text() -> void:
    speaker_label.text = DialogueManager.get_speaker()
    body_label.text = DialogueManager.get_body()
    _position_near_speaker()

func _apply_pixel_style() -> void:
    next_button.text = "继续"
    PixelUIStyle.apply_panel(panel)
    PixelUIStyle.apply_button(next_button)
    PixelUIStyle.apply_label(speaker_label, 22, Color(0.96, 0.82, 0.36, 1.0))
    PixelUIStyle.apply_label(body_label, 24)
    PixelUIStyle.apply_label(continue_hint_label, 16, Color(0.88, 0.82, 0.66, 1.0))
    continue_hint_label.text = "空格 / E 继续"

func _position_near_speaker() -> void:
    var speaker_node := DialogueManager.get_speaker_node()
    if speaker_node == null:
        _position_at_bottom()
        return

    var viewport_size := get_viewport().get_visible_rect().size
    var speaker_screen_position := speaker_node.get_global_transform_with_canvas().origin
    var panel_position := speaker_screen_position + Vector2(-BUBBLE_SIZE.x * 0.5, -BUBBLE_SIZE.y - SPEAKER_TOP_OFFSET)
    var pointer_points := PackedVector2Array([
        Vector2(-POINTER_WIDTH, 0),
        Vector2(POINTER_WIDTH, 0),
        Vector2(0, POINTER_HEIGHT),
    ])

    if panel_position.y < SCREEN_MARGIN:
        panel_position.y = speaker_screen_position.y + SPEAKER_BOTTOM_OFFSET
        pointer_points = PackedVector2Array([
            Vector2(-POINTER_WIDTH, 0),
            Vector2(POINTER_WIDTH, 0),
            Vector2(0, -POINTER_HEIGHT),
        ])

    panel_position.x = clampf(panel_position.x, SCREEN_MARGIN, viewport_size.x - BUBBLE_SIZE.x - SCREEN_MARGIN)
    panel_position.y = clampf(panel_position.y, SCREEN_MARGIN, viewport_size.y - BUBBLE_SIZE.y - SCREEN_MARGIN)
    panel.position = panel_position
    panel.size = BUBBLE_SIZE

    var pointer_x := clampf(
        speaker_screen_position.x,
        panel_position.x + 36.0,
        panel_position.x + BUBBLE_SIZE.x - 36.0
    )
    var pointer_y := panel_position.y + BUBBLE_SIZE.y - 1.0
    if pointer_points[2].y < 0:
        pointer_y = panel_position.y + 1.0

    pointer.position = Vector2(pointer_x, pointer_y)
    pointer.polygon = pointer_points
    pointer.visible = true
    speaker_highlight.position = speaker_screen_position + Vector2(0, -18)
    speaker_highlight.visible = true

func _position_at_bottom() -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    panel.size = BUBBLE_SIZE
    panel.position = Vector2(
        (viewport_size.x - BUBBLE_SIZE.x) * 0.5,
        viewport_size.y - BUBBLE_SIZE.y - 40.0
    )
    pointer.visible = false
    speaker_highlight.visible = false
