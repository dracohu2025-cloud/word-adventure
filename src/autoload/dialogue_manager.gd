extends Node

signal dialogue_started
signal dialogue_finished
signal puzzle_requested(word_data: Dictionary)
signal puzzle_solved(correct: bool)

var _current_lines: Array[String] = []
var _current_index: int = 0
var _pending_puzzle: Dictionary = {}
var _puzzle_active: bool = false
var _speaker_node: Node2D = null

func start_dialogue(lines: Array[String], puzzle_data: Dictionary = {}, speaker_node: Node2D = null) -> void:
    _current_lines = lines.duplicate()
    _current_index = 0
    _pending_puzzle = puzzle_data
    _puzzle_active = false
    _speaker_node = speaker_node
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
    var separator_index := _speaker_separator_index(line)
    if separator_index >= 0:
        return line.substr(0, separator_index).strip_edges()
    return ""

func get_body() -> String:
    var line := get_current_line()
    var separator_index := _speaker_separator_index(line)
    if separator_index >= 0:
        return line.substr(separator_index + 1).strip_edges()
    return line

func get_speaker_node() -> Node2D:
    if is_instance_valid(_speaker_node):
        return _speaker_node
    return null

func _speaker_separator_index(line: String) -> int:
    var english_index := line.find(":")
    var chinese_index := line.find("：")
    if english_index < 0:
        return chinese_index
    if chinese_index < 0:
        return english_index
    return min(english_index, chinese_index)

func _finish_dialogue() -> void:
    if _pending_puzzle.is_empty():
        GameManager.change_state(GameManager.GameState.WORLD)
        dialogue_finished.emit()
        _speaker_node = null
    else:
        _puzzle_active = true
        puzzle_requested.emit(_pending_puzzle)

func report_puzzle_result(correct: bool) -> void:
    _puzzle_active = false
    puzzle_solved.emit(correct)
    var result_line := String(_pending_puzzle.get("success_line" if correct else "failure_line", ""))
    _pending_puzzle = {}
    if not result_line.is_empty():
        _current_lines = [result_line]
        _current_index = 0
        GameManager.change_state(GameManager.GameState.DIALOGUE)
        dialogue_started.emit()
        _show_current_line()
        return

    GameManager.change_state(GameManager.GameState.WORLD)
    dialogue_finished.emit()
    _speaker_node = null
