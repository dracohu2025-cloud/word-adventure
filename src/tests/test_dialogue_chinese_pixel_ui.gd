extends Node

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    if not _require(_village_dialogue_is_chinese_first(village), "Village NPC dialogue should use Chinese-first copy"):
        return

    DialogueManager.start_dialogue(["图书管理员：这本魔法书失控了。"], {})
    await get_tree().process_frame
    if not _require(DialogueManager.get_speaker() == "图书管理员", "DialogueManager should parse Chinese speaker names"):
        return
    if not _require(DialogueManager.get_body() == "这本魔法书失控了。", "DialogueManager should parse Chinese dialogue bodies"):
        return
    if not _require(DialogueBox.next_button.text == "继续", "Dialogue next button should be localized"):
        return
    if not _require(_has_pixel_panel_style(DialogueBox.panel), "Dialogue panel should use a square pixel style"):
        return
    DialogueManager.advance()
    await get_tree().process_frame

    var puzzle_data := {
        "challenge_type": "meaning",
        "question": "选择“书”对应的英文单词。",
        "options": ["book", "fire", "friend", "home"],
        "answer": "book",
        "success_line": "答对了！",
        "failure_line": "再想想。",
    }
    DialogueManager.start_dialogue(["图书管理员：选择正确的英文单词。"], puzzle_data)
    DialogueManager.advance()
    await get_tree().process_frame

    if not _require(ChoicePuzzle.question_label.text.contains("英文单词"), "Puzzle question should guide Chinese learners in Chinese"):
        return
    if not _require(ChoicePuzzle.submit_button.text == "确认", "Puzzle submit button should be localized"):
        return
    if not _require(ChoicePuzzle.spelling_input.placeholder_text == "输入英文单词", "Spelling placeholder should be localized"):
        return
    if not _require(_choice_buttons_are_english_words(), "Choice options should stay as English words"):
        return
    if not _require(_has_pixel_panel_style(ChoicePuzzle.panel), "Puzzle panel should use a square pixel style"):
        return
    if not _require(_has_pixel_button_style(DialogueBox.next_button), "Dialogue buttons should use square pixel styles"):
        return

    ChoicePuzzle._on_option_selected("book")
    await get_tree().process_frame
    if not _require(ChoicePuzzle.feedback_label.text == "", "Puzzle card should not render answer feedback"):
        return
    if not _require(GameManager.current_state == GameManager.GameState.DIALOGUE, "Puzzle result should return to dialogue"):
        return
    if not _require(DialogueManager.get_body() == "答对了！", "Correct answer feedback should be dialogue text"):
        return
    DialogueManager.advance()
    await get_tree().process_frame
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    print("Chinese pixel dialogue UI regression test PASSED")
    get_tree().quit()

func _village_dialogue_is_chinese_first(village: Node) -> bool:
    for npc_path in ["LibraryNPC", "BlacksmithNPC", "GardenNPC"]:
        var npc: Node = village.get_node(npc_path)
        for line in npc.dialogue_lines:
            var text := String(line)
            if not _contains_chinese(text):
                return false
            if text.contains("Librarian") or text.contains("Blacksmith") or text.contains("Gardener"):
                return false
        for option in npc.puzzle_options:
            if not _is_ascii_word(String(option)):
                return false
    return true

func _choice_buttons_are_english_words() -> bool:
    for child in ChoicePuzzle.buttons_container.get_children():
        if child is Button and not _is_ascii_word(child.text):
            return false
    return true

func _has_pixel_panel_style(panel: Control) -> bool:
    var stylebox := panel.get_theme_stylebox("panel")
    if not stylebox is StyleBoxFlat:
        return false
    var flat := stylebox as StyleBoxFlat
    return flat.corner_radius_top_left == 0 and flat.border_width_left >= 4

func _has_pixel_button_style(button: Button) -> bool:
    var stylebox := button.get_theme_stylebox("normal")
    if not stylebox is StyleBoxFlat:
        return false
    var flat := stylebox as StyleBoxFlat
    return flat.corner_radius_top_left == 0 and flat.border_width_left >= 3

func _contains_chinese(text: String) -> bool:
    for index in range(text.length()):
        var code := text.unicode_at(index)
        if code >= 0x4e00 and code <= 0x9fff:
            return true
    return false

func _is_ascii_word(text: String) -> bool:
    if text.is_empty():
        return false
    for index in range(text.length()):
        var code := text.unicode_at(index)
        var is_lower := code >= 97 and code <= 122
        var is_upper := code >= 65 and code <= 90
        if not is_lower and not is_upper:
            return false
    return true

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
