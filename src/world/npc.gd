extends Area2D

@export var npc_name: String = "Villager"
@export var dialogue_lines: Array[String] = []
@export var puzzle_word: String = ""
@export var puzzle_question: String = ""
@export var puzzle_options: Array[String] = []
@export var puzzle_answer: String = ""
@export var success_line: String = "Correct! The path is open."
@export var failure_line: String = "Not quite. Try again when you're ready."

var _player_near: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
    if _player_near and event.is_action_pressed("interact") and GameManager.is_world_active():
        start_interaction()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_near = true

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_near = false

func start_interaction() -> void:
    if dialogue_lines.is_empty():
        return

    var puzzle_data := {}
    if not puzzle_word.is_empty():
        puzzle_data = {
            "word": puzzle_word,
            "question": puzzle_question,
            "options": puzzle_options,
            "answer": puzzle_answer,
            "success_line": success_line,
            "failure_line": failure_line,
        }

    DialogueManager.start_dialogue(dialogue_lines, puzzle_data)
