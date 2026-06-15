extends Node2D

@onready var exit_gate: StaticBody2D = $ExitGate
@onready var exit_collision: CollisionShape2D = $ExitGate/CollisionShape2D

func _ready() -> void:
    GameManager.change_state(GameManager.GameState.WORLD)
    DialogueManager.puzzle_solved.connect(_on_puzzle_solved)

func _on_puzzle_solved(correct: bool) -> void:
    if correct:
        open_exit()

func open_exit() -> void:
    exit_collision.set_deferred("disabled", true)
    exit_gate.modulate = Color(1, 1, 1, 0.3)
    print("Exit gate opened!")
