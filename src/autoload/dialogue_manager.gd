extends Node

signal dialogue_started
signal dialogue_finished
signal puzzle_requested(word_data: Dictionary)
signal puzzle_solved(correct: bool)

var _current_lines: Array[String] = []
var _current_index: int = 0
var _pending_puzzle: Dictionary = {}
var _puzzle_active: bool = false

func start_dialogue(lines: Array[String], puzzle_data: Dictionary = {}) -> void:
    _current_lines = lines.duplicate()
    _current_index = 0
    _pending_puzzle = puzzle_data
    _puzzle_active = false
    GameManager.change_state(GameManager.GameState.DIALOGUE)
    dialogue_started.emit()
    _show_current_line()

func advance() -> void:
    if _puzzle_active:
        return
    _current_index += 1
    if _current_index < _current_lines.size():
        _show_current_line()
    else:
        _finish_dialogue()

func _show_current_line() -> void:
    var line := _current_lines[_current_index]
    # UI will listen to this signal or read via get_current_line()

func get_current_line() -> String:
    if _current_index < _current_lines.size():
        return _current_lines[_current_index]
    return ""

func get_speaker() -> String:
    var line := get_current_line()
    if line.contains(":"):
        return line.split(":")[0].strip_edges()
    return ""

func get_body() -> String:
    var line := get_current_line()
    if line.contains(":"):
        var parts := line.split(":", true, 1)
        return parts[1].strip_edges()
    return line

func _finish_dialogue() -> void:
    if _pending_puzzle.is_empty():
        GameManager.change_state(GameManager.GameState.WORLD)
        dialogue_finished.emit()
    else:
        _puzzle_active = true
        puzzle_requested.emit(_pending_puzzle)

func report_puzzle_result(correct: bool) -> void:
    _puzzle_active = false
    puzzle_solved.emit(correct)
    if correct:
        _pending_puzzle = {}
    GameManager.change_state(GameManager.GameState.WORLD)
    dialogue_finished.emit()
