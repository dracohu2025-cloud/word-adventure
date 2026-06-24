extends CanvasLayer

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")

const VILLAGE_SCENE_PATH: String = "res://scenes/world/village.tscn"
const PROLOGUE_BGM_PATH: String = "res://assets/audio/bgm/prologue_magic_book_draft_01.ogg"
const UI_FRAME_PATH: String = "res://assets/licensed/tiny_swords/ui/panels/Button_Disable_9Slides.png"
const UI_PLATE_PATH: String = "res://assets/licensed/tiny_swords/ui/banners/Carved_9Slides.png"
const UI_BUTTON_PATH: String = "res://assets/licensed/tiny_swords/ui/buttons/Button_Hover_3Slides.png"
const OPEN_BOOK_PATH: String = "res://assets/story/prologue_open_magic_book.png"
const MAGIC_PAGE_PATH: String = "res://assets/story/prologue_floating_page.png"
const MAGIC_SPARK_PATH: String = "res://assets/story/prologue_magic_spark.png"
const HIGHLIGHT_COLOR_HEX: String = "#ffd84f"
const CHOICE_SUCCESS_BODY: String = "对，就是 book。你刚帮“书”找回了名字。"
const CHOICE_RETRY_BODY: String = "再看一眼书页。正在发光的词是 book。准备好后，再试一次。"

const STORY_STEPS: Array[Dictionary] = [
    {
        "title": "序章：会说话的旧书",
        "speaker": "旁白",
        "body": "夜深了，书桌上的旧书忽然自己翻开。金色的字从纸页里浮起来，轻轻念出一个词：book。",
        "requires_choice": false,
    },
    {
        "title": "先认出它",
        "speaker": "万语之书",
        "body": "这一页在发光。告诉我，“书”的英文是什么？",
        "highlight_terms": ["书"],
        "requires_choice": true,
    },
    {
        "title": "书页散落了",
        "speaker": "万语之书",
        "body": "刚才那阵光不是梦。书里的英语书页突然裂开，许多单词掉进了村子，连自己的意思都忘了。",
        "requires_choice": false,
    },
    {
        "title": "迷失的词灵",
        "speaker": "万语之书",
        "body": "忘了意思的单词，会变成迷失词灵，到处乱跑。帮它找回意思，它就会安静下来。",
        "requires_choice": false,
    },
    {
        "title": "书灯村",
        "speaker": "万语之书",
        "body": "最重要的三页书页落在书灯村。去找图书管理员、铁匠和园丁，他们会帮你把书页找回来。",
        "requires_choice": false,
    },
    {
        "title": "现在，出发吧",
        "speaker": "万语之书",
        "body": "等三页书页回到书中，森林入口的 Word Imp 就会现身。先别害怕，它只是忘了自己是谁。",
        "requires_choice": false,
    },
]

var _step_index: int = 0
var _choice_resolved: bool = false
var _choice_feedback_active: bool = false
var _body_plain_text: String = ""
var _float_phase: float = 0.0
var _book_base_position: Vector2
var _book_name_plate_base_position: Vector2
var _page_base_positions: Array[Vector2] = []
var _spark_base_positions: Array[Vector2] = []
var _word_base_positions: Array[Vector2] = []

@onready var background: ColorRect = $Root/Background
@onready var desk: ColorRect = $Root/Desk
@onready var book_glow: ColorRect = $Root/Stage/BookGlow
@onready var book_group: Control = $Root/Stage/BookGroup
@onready var book_art: TextureRect = $Root/Stage/BookGroup/BookArt
@onready var book_magic_word: Label = $Root/Stage/BookGroup/MagicWord
@onready var book_name_plate: Panel = $Root/Stage/BookNamePlate
@onready var book_name_label: Label = $Root/Stage/BookNamePlate/BookNameLabel
@onready var page_a: TextureRect = $Root/Stage/PageA
@onready var page_b: TextureRect = $Root/Stage/PageB
@onready var page_c: TextureRect = $Root/Stage/PageC
@onready var spark_a: TextureRect = $Root/Stage/SparkA
@onready var spark_b: TextureRect = $Root/Stage/SparkB
@onready var spark_c: TextureRect = $Root/Stage/SparkC
@onready var word_book: Label = $Root/Stage/WordBook
@onready var word_sword: Label = $Root/Stage/WordSword
@onready var word_shield: Label = $Root/Stage/WordShield
@onready var story_panel: Panel = $Root/StoryPanel
@onready var frame_texture: NinePatchRect = $Root/StoryPanel/FrameTexture
@onready var speaker_plate: Panel = $Root/StoryPanel/SpeakerPlate
@onready var title_label: Label = $Root/StoryPanel/TitleLabel
@onready var speaker_label: Label = $Root/StoryPanel/SpeakerPlate/SpeakerLabel
@onready var body_label: RichTextLabel = $Root/StoryPanel/BodyLabel
@onready var choice_panel: HBoxContainer = $Root/StoryPanel/ChoicePanel
@onready var book_button: Button = $Root/StoryPanel/ChoicePanel/BookButton
@onready var fire_button: Button = $Root/StoryPanel/ChoicePanel/FireButton
@onready var tree_button: Button = $Root/StoryPanel/ChoicePanel/TreeButton
@onready var book_button_label: Label = $Root/StoryPanel/ChoicePanel/BookButton/ButtonLabel
@onready var fire_button_label: Label = $Root/StoryPanel/ChoicePanel/FireButton/ButtonLabel
@onready var tree_button_label: Label = $Root/StoryPanel/ChoicePanel/TreeButton/ButtonLabel
@onready var next_button: Button = $Root/StoryPanel/NextButton
@onready var next_button_label: Label = $Root/StoryPanel/NextButton/ButtonLabel

func _ready() -> void:
    GameManager.change_state(GameManager.GameState.MENU)
    AudioManager.play_music_path(PROLOGUE_BGM_PATH)
    _load_pixel_assets()
    _apply_pixel_styles()
    _connect_buttons()
    _capture_base_positions()
    _show_step(0)

func _process(delta: float) -> void:
    _float_phase += delta
    _animate_magic_book()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
        advance()

func advance() -> void:
    var step := STORY_STEPS[_step_index]
    if _choice_feedback_active:
        if _choice_resolved:
            _show_step(_step_index + 1)
        else:
            _show_step(_step_index)
        return

    if bool(step.get("requires_choice", false)) and not _choice_resolved:
        AudioManager.play_sfx_path(AudioManager.SFX_UI_CONFIRM)
        return

    if _step_index >= STORY_STEPS.size() - 1:
        _go_to_village()
        return

    _show_step(_step_index + 1)

func choose_word(word: String) -> void:
    var step := STORY_STEPS[_step_index]
    if not bool(step.get("requires_choice", false)):
        return

    if word == "book":
        _show_choice_feedback(true)
        AudioManager.play_sfx_path(AudioManager.SFX_SPELL)
    else:
        _show_choice_feedback(false)
        AudioManager.play_sfx_path(AudioManager.SFX_UI_CONFIRM)

func get_current_step_index() -> int:
    return _step_index

func get_focus_text() -> String:
    return ""

func get_body_text() -> String:
    return _body_plain_text

func get_next_button_text() -> String:
    return next_button_label.text

func is_choice_resolved() -> bool:
    return _choice_resolved

func is_choice_panel_visible() -> bool:
    return choice_panel.visible

func is_next_button_visible() -> bool:
    return next_button.visible

func is_title_visible() -> bool:
    return title_label.visible

func is_study_panel_visible() -> bool:
    return false

func get_study_title_text() -> String:
    return ""

func has_visible_floating_words() -> bool:
    return word_book.visible or word_sword.visible or word_shield.visible

func is_book_magic_word_visible() -> bool:
    return book_magic_word.visible

func is_dialogue_speaker_plate_visible() -> bool:
    return speaker_plate.visible

func is_book_name_plate_visible() -> bool:
    return book_name_plate.visible

func get_book_name_text() -> String:
    return book_name_label.text

func get_target_scene_path() -> String:
    return VILLAGE_SCENE_PATH

func _show_step(next_index: int) -> void:
    _step_index = clampi(next_index, 0, STORY_STEPS.size() - 1)
    _choice_resolved = false
    _choice_feedback_active = false
    var step := STORY_STEPS[_step_index]

    title_label.text = String(step.get("title", ""))
    title_label.visible = false
    speaker_label.text = String(step.get("speaker", ""))
    speaker_plate.visible = false
    _set_body_text(String(step.get("body", "")), Array(step.get("highlight_terms", [])))

    var requires_choice := bool(step.get("requires_choice", false))
    _set_dialogue_body_height(requires_choice)
    choice_panel.visible = requires_choice

    next_button.visible = not choice_panel.visible
    next_button_label.text = "开始冒险" if _step_index == STORY_STEPS.size() - 1 else "继续"

    _sync_visual_words()
    AudioManager.play_sfx_path(AudioManager.SFX_BOOK if _step_index == 0 else AudioManager.SFX_UI_CONFIRM)

func _show_choice_feedback(success: bool) -> void:
    _choice_feedback_active = true
    _choice_resolved = success
    _set_dialogue_body_height(false)
    choice_panel.visible = false
    next_button.visible = true
    next_button_label.text = "继续" if success else "再试一次"
    _set_body_text(CHOICE_SUCCESS_BODY if success else CHOICE_RETRY_BODY, ["书"] if success else [])

func _sync_visual_words() -> void:
    word_book.modulate = Color(1.0, 0.9, 0.42, 1.0)
    word_sword.modulate = Color(0.78, 0.86, 1.0, 0.85)
    word_shield.modulate = Color(0.72, 0.95, 0.80, 0.85)
    book_magic_word.visible = false
    word_book.visible = false
    word_sword.visible = false
    word_shield.visible = false

func _set_dialogue_body_height(has_choices: bool) -> void:
    body_label.offset_bottom = 128.0 if has_choices else 146.0

func _set_body_text(plain_text: String, highlight_terms: Array = []) -> void:
    _body_plain_text = plain_text
    body_label.text = _format_highlighted_text(plain_text, highlight_terms)

func _format_highlighted_text(plain_text: String, highlight_terms: Array) -> String:
    var formatted := _escape_bbcode_text(plain_text)
    for term_value in highlight_terms:
        var term := String(term_value)
        if term.is_empty():
            continue
        var escaped_term := _escape_bbcode_text(term)
        formatted = formatted.replace(escaped_term, "[color=%s]%s[/color]" % [HIGHLIGHT_COLOR_HEX, escaped_term])
    return formatted

func _escape_bbcode_text(text: String) -> String:
    return text.replace("[", "[lb]").replace("]", "[rb]")

func _go_to_village() -> void:
    QuestManager.reset_chapter()
    var error := get_tree().change_scene_to_file(VILLAGE_SCENE_PATH)
    if error != OK:
        printerr("Failed to enter village from prologue: ", error)

func _connect_buttons() -> void:
    next_button.pressed.connect(advance)
    book_button.pressed.connect(choose_word.bind("book"))
    fire_button.pressed.connect(choose_word.bind("fire"))
    tree_button.pressed.connect(choose_word.bind("tree"))

func _apply_pixel_styles() -> void:
    PixelUIStyle.apply_asset_panel_shell(story_panel)
    _apply_asset_panel(speaker_plate)
    _apply_asset_panel(book_name_plate)
    PixelUIStyle.apply_label(title_label, 32, Color(1.0, 0.86, 0.36, 1.0))
    PixelUIStyle.apply_label(speaker_label, 20, Color(1.0, 0.86, 0.36, 1.0))
    PixelUIStyle.apply_label(book_name_label, 20, Color(0.18, 0.17, 0.10, 1.0))
    _apply_body_label_style(body_label, 24)
    PixelUIStyle.apply_label(book_magic_word, 22, Color(0.29, 0.14, 0.07, 1.0))
    PixelUIStyle.apply_label(word_book, 34, Color(1.0, 0.9, 0.42, 1.0))
    PixelUIStyle.apply_label(word_sword, 28, Color(0.78, 0.86, 1.0, 0.85))
    PixelUIStyle.apply_label(word_shield, 28, Color(0.72, 0.95, 0.80, 0.85))
    for label in [book_button_label, fire_button_label, tree_button_label, next_button_label]:
        PixelUIStyle.apply_label(label, 22, Color(0.12, 0.15, 0.10, 1.0))
    for button in [book_button, fire_button, tree_button, next_button]:
        _apply_asset_button(button)
    for button in [book_button, fire_button, tree_button, next_button]:
        button.text = ""

func _load_pixel_assets() -> void:
    frame_texture.texture = _load_runtime_texture(UI_FRAME_PATH)
    frame_texture.modulate = Color(0.34, 0.40, 0.29, 0.98)
    book_art.texture = _load_runtime_texture(OPEN_BOOK_PATH)
    for page in [page_a, page_b, page_c]:
        page.texture = _load_runtime_texture(MAGIC_PAGE_PATH)
        page.modulate = Color(1.0, 0.96, 0.72, 0.94)
    for spark in [spark_a, spark_b, spark_c]:
        spark.texture = _load_runtime_texture(MAGIC_SPARK_PATH)
        spark.modulate = Color(1.0, 0.92, 0.42, 0.88)

func _capture_base_positions() -> void:
    _book_base_position = book_group.position
    _book_name_plate_base_position = book_name_plate.position
    _page_base_positions = [page_a.position, page_b.position, page_c.position]
    _spark_base_positions = [spark_a.position, spark_b.position, spark_c.position]
    _word_base_positions = [word_book.position, word_sword.position, word_shield.position]

func _animate_magic_book() -> void:
    book_glow.modulate.a = 0.08 + sin(_float_phase * 2.0) * 0.03
    book_group.position = _book_base_position + Vector2(0, sin(_float_phase * 2.8) * 5.0)
    book_group.rotation = sin(_float_phase * 1.7) * 0.035
    book_name_plate.position = _book_name_plate_base_position + Vector2(0, sin(_float_phase * 2.8) * 5.0)

    var pages := [page_a, page_b, page_c]
    for index in range(pages.size()):
        var page: TextureRect = pages[index]
        var base_position := _page_base_positions[index]
        page.position = base_position + Vector2(sin(_float_phase * 1.6 + index) * 8.0, cos(_float_phase * 1.4 + index) * 6.0)
        page.rotation = sin(_float_phase * 1.8 + index) * 0.12

    var sparks := [spark_a, spark_b, spark_c]
    for index in range(sparks.size()):
        var spark: TextureRect = sparks[index]
        var base_spark_position := _spark_base_positions[index]
        spark.position = base_spark_position + Vector2(sin(_float_phase * 2.4 + index) * 10.0, cos(_float_phase * 2.2 + index) * 7.0)
        spark.modulate.a = 0.45 + (sin(_float_phase * 3.0 + index) + 1.0) * 0.22

    var words := [word_book, word_sword, word_shield]
    for index in range(words.size()):
        var label: Label = words[index]
        var base_word_position := _word_base_positions[index]
        label.position = base_word_position + Vector2(0, sin(_float_phase * 1.9 + index * 0.8) * 4.0)

func _load_runtime_texture(path: String) -> Texture2D:
    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    if error != OK:
        return null

    return ImageTexture.create_from_image(image)

func _apply_asset_panel(panel: Control) -> void:
    var texture := _load_runtime_texture(UI_PLATE_PATH)
    if texture == null:
        PixelUIStyle.apply_asset_panel_shell(panel)
        return

    panel.add_theme_stylebox_override("panel", _make_texture_box(texture, 48, 10))

func _apply_asset_button(button: Button) -> void:
    var texture := _load_runtime_texture(UI_BUTTON_PATH)
    if texture != null:
        button.add_theme_stylebox_override("normal", _make_texture_box(texture, 24, 10))
        button.add_theme_stylebox_override("hover", _make_texture_box(texture, 24, 10))
        button.add_theme_stylebox_override("pressed", _make_texture_box(texture, 24, 12))
        button.add_theme_stylebox_override("disabled", _make_texture_box(texture, 24, 10))

    button.add_theme_color_override("font_color", Color(0.15, 0.18, 0.13, 1.0))
    button.add_theme_color_override("font_hover_color", Color(0.06, 0.08, 0.06, 1.0))
    button.add_theme_color_override("font_pressed_color", Color(0.08, 0.10, 0.07, 1.0))
    button.add_theme_color_override("font_disabled_color", Color(0.40, 0.39, 0.32, 1.0))
    button.add_theme_font_size_override("font_size", 22)

func _apply_body_label_style(label: RichTextLabel, font_size: int) -> void:
    label.add_theme_font_size_override("normal_font_size", font_size)
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("default_color", PixelUIStyle.TEXT_COLOR)
    label.add_theme_color_override("font_color", PixelUIStyle.TEXT_COLOR)
    label.add_theme_constant_override("line_separation", 6)

func _make_texture_box(texture: Texture2D, texture_margin: int, content_margin: int) -> StyleBoxTexture:
    var box := StyleBoxTexture.new()
    box.texture = texture
    box.texture_margin_left = texture_margin
    box.texture_margin_top = texture_margin
    box.texture_margin_right = texture_margin
    box.texture_margin_bottom = texture_margin
    box.content_margin_left = content_margin
    box.content_margin_top = content_margin
    box.content_margin_right = content_margin
    box.content_margin_bottom = content_margin
    return box
