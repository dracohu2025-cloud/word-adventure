extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var question_label: Label = $Panel/QuestionLabel
@onready var buttons_container: VBoxContainer = $Panel/ButtonsContainer
@onready var feedback_label: Label = $Panel/FeedbackLabel

var _current_answer: String = ""
var _current_data: Dictionary = {}

func _ready() -> void:
    panel.visible = false
    DialogueManager.puzzle_requested.connect(_on_puzzle_requested)

func _on_puzzle_requested(data: Dictionary) -> void:
    _current_data = data
    _current_answer = data.get("answer", "")
    GameManager.change_state(GameManager.GameState.PUZZLE)
    panel.visible = true
    feedback_label.text = ""
    question_label.text = data.get("question", "")

    # Clear old buttons
    for child in buttons_container.get_children():
        child.queue_free()

    var options: Array = data.get("options", [])
    for option in options:
        var btn := Button.new()
        btn.text = option
        btn.custom_minimum_size = Vector2(0, 48)
        btn.pressed.connect(_on_option_selected.bind(option))
        buttons_container.add_child(btn)

func _on_option_selected(option: String) -> void:
    var correct := option == _current_answer
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
