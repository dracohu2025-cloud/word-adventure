extends CanvasLayer

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")

@onready var panel: Panel = $Panel
@onready var question_label: Label = $Panel/QuestionLabel
@onready var buttons_container: VBoxContainer = $Panel/ButtonsContainer
@onready var spelling_input: LineEdit = $Panel/SpellingInput
@onready var submit_button: Button = $Panel/SubmitButton
@onready var feedback_label: Label = $Panel/FeedbackLabel

var _current_answer: String = ""
var _current_data: Dictionary = {}
var _current_challenge_type: String = "meaning"
var _accepting_answer: bool = false

func _ready() -> void:
    panel.visible = false
    spelling_input.visible = false
    submit_button.visible = false
    feedback_label.visible = false
    _apply_pixel_style()
    submit_button.pressed.connect(_on_submit_pressed)
    spelling_input.text_submitted.connect(_on_spelling_submitted)
    DialogueManager.puzzle_requested.connect(_on_puzzle_requested)

func _on_puzzle_requested(data: Dictionary) -> void:
    _current_data = data
    _current_answer = data.get("answer", "")
    _current_challenge_type = data.get("challenge_type", "meaning")
    GameManager.change_state(GameManager.GameState.PUZZLE)
    panel.visible = true
    feedback_label.text = ""
    feedback_label.visible = false
    _accepting_answer = true
    question_label.text = data.get("question", "")
    spelling_input.text = ""
    spelling_input.visible = _current_challenge_type == "spelling"
    submit_button.visible = _current_challenge_type == "spelling"
    buttons_container.visible = _current_challenge_type != "spelling"

    for child in buttons_container.get_children():
        child.queue_free()

    if _current_challenge_type == "spelling":
        spelling_input.grab_focus()
    else:
        var options: Array = data.get("options", [])
        for option in options:
            var btn := Button.new()
            btn.text = option
            btn.custom_minimum_size = Vector2(0, 48)
            PixelUIStyle.apply_button(btn)
            btn.pressed.connect(_on_option_selected.bind(option))
            buttons_container.add_child(btn)

func _on_option_selected(option: String) -> void:
    _resolve_answer(option)

func _on_submit_pressed() -> void:
    _resolve_answer(spelling_input.text)

func _on_spelling_submitted(text: String) -> void:
    _resolve_answer(text)

func _resolve_answer(raw_answer: String) -> void:
    if not _accepting_answer:
        return
    _accepting_answer = false

    var submitted := raw_answer.strip_edges().to_lower()
    var expected := _current_answer.strip_edges().to_lower()
    var correct := submitted == expected
    feedback_label.text = ""
    panel.visible = false
    DialogueManager.report_puzzle_result(correct)

func _apply_pixel_style() -> void:
    spelling_input.placeholder_text = "输入英文单词"
    submit_button.text = "确认"
    PixelUIStyle.apply_panel(panel)
    PixelUIStyle.apply_button(submit_button)
    PixelUIStyle.apply_line_edit(spelling_input)
    PixelUIStyle.apply_label(question_label, 24)
    PixelUIStyle.apply_label(feedback_label, 20, Color(0.96, 0.82, 0.36, 1.0))
