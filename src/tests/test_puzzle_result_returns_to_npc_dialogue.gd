extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var npc: Node = village.get_node("LibraryNPC")
    await _open_library_puzzle(npc)
    ChoicePuzzle._on_option_selected("fire")
    await get_tree().process_frame

    if not _require(not ChoicePuzzle.panel.visible, "Puzzle panel should close immediately after an answer"):
        return
    if not _require(ChoicePuzzle.feedback_label.text == "", "Puzzle card should not render answer feedback"):
        return
    if not _require(GameManager.current_state == GameManager.GameState.DIALOGUE, "Answer feedback should return to NPC dialogue"):
        return
    if not _require(DialogueManager.get_speaker() == "图书管理员", "NPC should remain the speaker for answer feedback"):
        return
    if not _require(DialogueManager.get_body() == npc.failure_line.get_slice("：", 1), "NPC dialogue should show the failure line after an incorrect answer"):
        return

    DialogueManager.advance()
    await get_tree().process_frame

    if not _require(GameManager.current_state == GameManager.GameState.WORLD, "Continuing the failure dialogue should return to world state"):
        return
    if not _require(not QuestManager.is_branch_completed("library"), "Incorrect answer should not complete the branch"):
        return

    await _open_library_puzzle(npc)
    ChoicePuzzle._on_option_selected("book")
    await get_tree().process_frame

    if not _require(not ChoicePuzzle.panel.visible, "Puzzle panel should close immediately after the correct answer"):
        return
    if not _require(ChoicePuzzle.feedback_label.text == "", "Puzzle card should keep answer feedback empty after the correct answer"):
        return
    if not _require(GameManager.current_state == GameManager.GameState.DIALOGUE, "Correct answer feedback should return to NPC dialogue"):
        return
    if not _require(DialogueManager.get_body() == npc.success_line.get_slice("：", 1), "NPC dialogue should show the success line after a correct answer"):
        return

    DialogueManager.advance()
    await get_tree().process_frame

    if not _require(GameManager.current_state == GameManager.GameState.WORLD, "Continuing the result dialogue should return to world state"):
        return
    if not _require(QuestManager.is_branch_completed("library"), "Correct answer should still complete the branch"):
        return

    print("Puzzle result NPC dialogue regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _open_library_puzzle(npc: Node) -> void:
    npc.start_interaction()
    await _advance_dialogue_lines(3)
    if GameManager.current_state != GameManager.GameState.PUZZLE:
        push_error("NPC should request a puzzle after intro dialogue")
        get_tree().quit(1)

func _advance_dialogue_lines(count: int) -> void:
    for i in range(count):
        DialogueManager.advance()
        await get_tree().process_frame

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
