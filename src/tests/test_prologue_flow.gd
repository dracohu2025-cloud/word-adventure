extends Node

const PROLOGUE_SCENE_PATH: String = "res://scenes/story/prologue.tscn"
const VILLAGE_SCENE_PATH: String = "res://scenes/world/village.tscn"
const PROLOGUE_BGM_PATH: String = "res://assets/audio/bgm/prologue_magic_book_draft_01.ogg"
const TextBounds := preload("res://src/tests/ui_text_bounds_assertions.gd")

func _ready() -> void:
    var prologue = load(PROLOGUE_SCENE_PATH).instantiate()
    add_child(prologue)
    await get_tree().process_frame

    assert(not prologue.has_node("Root/StoryPanel/SkipButton"), "Prologue should not expose a skip button")
    assert(not prologue.has_node("Root/StoryPanel/FocusLabel"), "Vocabulary hints should not live inside the dialogue panel")
    assert(not prologue.has_node("Root/StudyPanel"), "Prologue should not use a separate system-like study card")
    assert(prologue.get_current_step_index() == 0, "Prologue should start at the first story beat")
    assert(prologue.get_focus_text().is_empty(), "Narrative beats should not expose extra study-card text")
    assert(not prologue.is_study_panel_visible(), "Narrative beats should keep the study panel hidden")
    assert(not prologue.has_visible_floating_words(), "Prologue should not show decorative floating words")
    assert(not prologue.is_book_magic_word_visible(), "Book art should not show redundant magic-word text")
    assert(not prologue.is_dialogue_speaker_plate_visible(), "Dialogue panel should not carry the book name")
    assert(prologue.is_book_name_plate_visible(), "Book name should appear below the book art")
    assert(prologue.get_book_name_text() == "万语之书", "Book name plate should identify the book itself")
    assert(prologue.get_next_button_text() == "继续", "Prologue should use a clear continue action")
    assert(not prologue.is_title_visible(), "Prologue beat titles should not appear inside the dialogue box")
    assert(prologue.is_next_button_visible(), "Narrative beats should expose a continue action")
    assert(AudioManager.get_music_stream_path() == PROLOGUE_BGM_PATH, "Prologue should request its own BGM")
    _assert_dialogue_text_fits(prologue, "Opening beat")
    _assert_next_button_text_safe(prologue, "Opening beat")

    prologue.advance()
    await get_tree().process_frame
    assert(prologue.get_current_step_index() == 1, "Prologue should advance into the first word choice")
    assert(prologue.is_choice_panel_visible(), "Choice beat should show word options")
    assert(not prologue.is_study_panel_visible(), "Choice beat should stay inside the dialogue panel")
    assert(prologue.get_study_title_text().is_empty(), "Choice beat should not show system-like labels such as 小测试")
    var choice_panel: Control = prologue.get_node("Root/StoryPanel/ChoicePanel")
    var story_panel: Control = prologue.get_node("Root/StoryPanel")
    var body_label: Control = prologue.get_node("Root/StoryPanel/BodyLabel")
    var book_button: Control = prologue.get_node("Root/StoryPanel/ChoicePanel/BookButton")
    var book_button_label: Control = prologue.get_node("Root/StoryPanel/ChoicePanel/BookButton/ButtonLabel")
    var fire_button: Button = prologue.get_node("Root/StoryPanel/ChoicePanel/FireButton")
    var fire_button_label: Label = prologue.get_node("Root/StoryPanel/ChoicePanel/FireButton/ButtonLabel")
    var tree_button: Button = prologue.get_node("Root/StoryPanel/ChoicePanel/TreeButton")
    var tree_button_label: Label = prologue.get_node("Root/StoryPanel/ChoicePanel/TreeButton/ButtonLabel")
    assert(choice_panel.global_position.y >= body_label.global_position.y + body_label.size.y + 4.0, "Choice buttons should sit below the dialogue line with clear spacing")
    assert(choice_panel.global_position.y + choice_panel.size.y <= story_panel.global_position.y + story_panel.size.y - 24.0, "Choice buttons should stay inside the dialogue panel")
    var button_center_y := book_button.global_position.y + book_button.size.y / 2.0
    var label_center_y := book_button_label.global_position.y + book_button_label.size.y / 2.0
    assert(absf((button_center_y - 7.0) - label_center_y) <= 2.0, "Choice button text should use a visual-centering offset for the asset button")
    TextBounds.assert_button_uses_safe_label(book_button, book_button_label, "Book choice")
    TextBounds.assert_button_uses_safe_label(fire_button, fire_button_label, "Fire choice")
    TextBounds.assert_button_uses_safe_label(tree_button, tree_button_label, "Tree choice")
    _assert_dialogue_text_fits(prologue, "Choice beat")
    assert(not prologue.has_visible_floating_words(), "Choice beat should keep decorative floating words hidden")
    assert(not prologue.is_book_magic_word_visible(), "Choice beat should keep redundant book text hidden")
    assert(not prologue.is_dialogue_speaker_plate_visible(), "Choice beat should keep speaker name off the dialogue panel")
    assert(not prologue.is_next_button_visible(), "Choice beat should hide continue until the player answers")
    assert(prologue.get_body_text() == "这一页在发光。告诉我，“书”的英文是什么？", "Choice beat should ask through the book dialogue itself")
    assert(body_label is RichTextLabel, "Choice beat body should support inline highlighted target words")
    assert((body_label as RichTextLabel).text.contains("[color=#ffd84f]书[/color]"), "Choice beat should highlight the tested Chinese target word")
    assert(not prologue.get_body_text().contains("[color"), "Choice beat public body text should stay plain")

    prologue.choose_word("fire")
    assert(not prologue.is_choice_resolved(), "Wrong prologue answer should not resolve the choice")
    assert(not prologue.is_choice_panel_visible(), "Wrong answer should switch to a full feedback dialogue")
    assert(not prologue.is_study_panel_visible(), "Wrong answer feedback should hide the study panel")
    assert(prologue.is_next_button_visible(), "Wrong answer feedback should expose retry action")
    assert(prologue.get_next_button_text() == "再试一次", "Wrong answer should use a clear retry action")
    assert(prologue.get_body_text() == "再看一眼书页。正在发光的词是 book。准备好后，再试一次。", "Wrong answer feedback should replace the whole dialogue content")
    assert(prologue.get_focus_text().is_empty(), "Wrong answer feedback should not show extra system-like helper text")
    _assert_dialogue_text_fits(prologue, "Wrong answer feedback")
    _assert_next_button_text_safe(prologue, "Wrong answer feedback")

    prologue.advance()
    await get_tree().process_frame
    assert(prologue.get_current_step_index() == 1, "Retry should return to the same word choice")
    assert(prologue.is_choice_panel_visible(), "Retry should restore word options")

    prologue.choose_word("book")
    assert(prologue.is_choice_resolved(), "Correct prologue answer should resolve the choice")
    assert(not prologue.is_choice_panel_visible(), "Correct answer should switch to a full feedback dialogue")
    assert(not prologue.is_study_panel_visible(), "Correct answer feedback should hide the study panel")
    assert(prologue.get_body_text() == "对，就是 book。你刚帮“书”找回了名字。", "Correct answer feedback should replace the whole dialogue content")
    assert(prologue.get_focus_text().is_empty(), "Correct answer feedback should keep the panel as a clean dialogue line")
    _assert_dialogue_text_fits(prologue, "Correct answer feedback")
    _assert_next_button_text_safe(prologue, "Correct answer feedback")

    prologue.advance()
    await get_tree().process_frame
    assert(prologue.get_current_step_index() == 2, "Prologue should continue after the correct word choice")
    assert(prologue.get_focus_text().is_empty(), "Later narrative beats should not show study-card text")
    assert(not prologue.is_study_panel_visible(), "Narrative vocabulary should not return as a separate card")
    assert(not prologue.has_visible_floating_words(), "Later narrative beats should keep decorative floating words hidden")
    assert(not prologue.is_book_magic_word_visible(), "Later narrative beats should keep redundant book text hidden")
    assert(not prologue.is_dialogue_speaker_plate_visible(), "Later narrative beats should keep speaker name off the dialogue panel")

    prologue.advance()
    await get_tree().process_frame
    assert(prologue.get_current_step_index() == 3, "Prologue should continue into the lost-word-spirit beat")

    prologue.advance()
    await get_tree().process_frame
    assert(prologue.get_current_step_index() == 4, "Prologue should name the first chapter village")
    assert(prologue.get_body_text().contains("书灯村"), "First chapter village should use a proper world name")
    assert(not prologue.get_body_text().contains("冒险入口村"), "First chapter village should not use a functional placeholder name")
    _assert_dialogue_text_fits(prologue, "Village naming beat")
    assert(prologue.get_target_scene_path() == VILLAGE_SCENE_PATH, "Prologue should hand off to the first chapter village")

    print("Prologue flow regression test PASSED")
    prologue.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _assert_dialogue_text_fits(prologue: Node, context: String) -> void:
    var body_label: RichTextLabel = prologue.get_node("Root/StoryPanel/BodyLabel")
    _assert_rich_text_fits(body_label, prologue.get_body_text(), context + " body")

func _assert_next_button_text_safe(prologue: Node, context: String) -> void:
    var next_button: Button = prologue.get_node("Root/StoryPanel/NextButton")
    var next_button_label: Label = prologue.get_node("Root/StoryPanel/NextButton/ButtonLabel")
    TextBounds.assert_button_uses_safe_label(next_button, next_button_label, context + " next button")

func _assert_rich_text_fits(label: RichTextLabel, plain_text: String, message: String) -> void:
    var padding := 2.0
    var available := label.size - Vector2(padding * 2.0, padding * 2.0)
    assert(available.x > 0.0 and available.y > 0.0, message + " rich text should have positive inner space")

    var font := label.get_theme_font("normal_font")
    var font_size := label.get_theme_font_size("normal_font_size")
    if font == null:
        font = label.get_theme_font("font")
    if font_size <= 0:
        font_size = label.get_theme_font_size("font_size")
    if font == null or font_size <= 0:
        return

    var text_size := font.get_multiline_string_size(
        plain_text,
        HORIZONTAL_ALIGNMENT_LEFT,
        available.x,
        font_size,
        -1,
        TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
    )
    assert(text_size.x <= available.x + 1.0, message + " rich text width should fit inside label")
    assert(text_size.y <= available.y + 1.0, message + " rich text height should fit inside label")
