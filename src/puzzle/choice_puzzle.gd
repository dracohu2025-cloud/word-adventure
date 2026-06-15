extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var question_label: Label = $Panel/QuestionLabel
@onready var buttons_container: VBoxContainer = $Panel/ButtonsContainer
@onready var spelling_input: LineEdit = $Panel/SpellingInput
@onready var submit_button: Button = $Panel/SubmitButton
@onready var feedback_label: Label = $Panel/FeedbackLabel

var _current_answer: String = ""
var _current_data: Dictionary = {}
var _current_challenge_type: String = "meaning"

func _ready() -> void:
    panel.visible = false
    spelling_input.visible = false
    submit_button.visible = false
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
            btn.pressed.connect(_on_option_selected.bind(option))
            buttons_container.add_child(btn)

func _on_option_selected(option: String) -> void:
    _resolve_answer(option)

func _on_submit_pressed() -> void:
    _resolve_answer(spelling_input.text)

func _on_spelling_submitted(text: String) -> void:
    _resolve_answer(text)

func _resolve_answer(raw_answer: String) -> void:
    var submitted := raw_answer.strip_edges().to_lower()
    var expected := _current_answer.strip_edges().to_lower()
    var correct := submitted == expected
    if correct:
        feedback_label.text = _current_data.get("success_line", "Correct!")
        feedback_label.modulate = Color(0.5, 1, 0.5)
        DialogueManager.report_puzzle_result(true)
        await get_tree().create_timer(1.5).timeout
        panel.visible = false
    else:
        feedback_label.text = _current_data.get("failure_line", "Try again.")
        feedback_label.modulate = Color(1, 0.5, 0.5)
        DialogueManager.report_puzzle_result(false)
        await get_tree().create_timer(1.5).timeout
        panel.visible = false
