extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var body_label: Label = $Panel/BodyLabel
@onready var next_button: Button = $Panel/NextButton

func _ready() -> void:
    panel.visible = false
    DialogueManager.dialogue_started.connect(_on_dialogue_started)
    GameManager.state_changed.connect(_on_state_changed)
    next_button.pressed.connect(_on_next_pressed)

func _on_dialogue_started() -> void:
    panel.visible = true
    update_text()

func _on_state_changed(_state) -> void:
    if GameManager.current_state != GameManager.GameState.DIALOGUE:
        panel.visible = false

func _input(event: InputEvent) -> void:
    if GameManager.current_state == GameManager.GameState.DIALOGUE and event.is_action_pressed("interact"):
        _on_next_pressed()

func _on_next_pressed() -> void:
    DialogueManager.advance()
    update_text()

func update_text() -> void:
    speaker_label.text = DialogueManager.get_speaker()
    body_label.text = DialogueManager.get_body()
