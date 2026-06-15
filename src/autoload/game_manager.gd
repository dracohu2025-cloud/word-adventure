extends Node

enum GameState { MENU, WORLD, DIALOGUE, PUZZLE, COMBAT, PAUSED }

var current_state: GameState = GameState.MENU

signal state_changed(new_state: GameState)

func _ready() -> void:
    print("GameManager initialized")

func change_state(new_state: GameState) -> void:
    current_state = new_state
    state_changed.emit(new_state)
    print("Game state changed to: ", GameState.keys()[new_state])

func load_scene(scene_path: String) -> void:
    SceneTransition.transition_to(scene_path)

func is_world_active() -> bool:
    return current_state == GameState.WORLD
