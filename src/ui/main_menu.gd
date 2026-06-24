extends CanvasLayer

const PROLOGUE_SCENE_PATH: String = "res://scenes/story/prologue.tscn"
const MENU_BGM_PATH: String = "res://assets/audio/bgm/prologue_magic_book_draft_01.ogg"

var _float_phase: float = 0.0
var _music_enabled: bool = true
var _sfx_enabled: bool = true
var _hero_book_base_position: Vector2
var _page_left_base_position: Vector2
var _page_right_base_position: Vector2

@onready var hero_book: TextureRect = $Root/HeroBook
@onready var page_left: TextureRect = $Root/Atmosphere/PageLeft
@onready var page_right: TextureRect = $Root/Atmosphere/PageRight
@onready var hero_title: Label = $Root/HeroTitle
@onready var hero_chinese_title: Label = $Root/HeroChineseTitle
@onready var hero_copy_panel: Panel = $Root/HeroCopyPanel
@onready var hero_copy: Label = $Root/HeroCopyPanel/HeroCopy
@onready var menu_panel: Panel = $Root/MenuPanel
@onready var menu_title: Label = $Root/MenuPanel/MenuTitle
@onready var menu_subtitle: Label = $Root/MenuPanel/MenuSubtitle
@onready var menu_hint: Label = $Root/MenuPanel/MenuHint
@onready var new_game_button: Button = $Root/MenuPanel/MenuButtons/NewGameButton
@onready var continue_button: Button = $Root/MenuPanel/MenuButtons/ContinueButton
@onready var settings_button: Button = $Root/MenuPanel/MenuButtons/SettingsButton
@onready var intro_button: Button = $Root/MenuPanel/MenuButtons/IntroButton
@onready var quit_button: Button = $Root/MenuPanel/MenuButtons/QuitButton
@onready var settings_overlay: Control = $Root/SettingsOverlay
@onready var settings_panel: Panel = $Root/SettingsOverlay/SettingsPanel
@onready var settings_title: Label = $Root/SettingsOverlay/SettingsPanel/SettingsTitle
@onready var master_label: Label = $Root/SettingsOverlay/SettingsPanel/MasterLabel
@onready var master_slider: HSlider = $Root/SettingsOverlay/SettingsPanel/MasterSlider
@onready var music_check: CheckButton = $Root/SettingsOverlay/SettingsPanel/MusicCheck
@onready var sfx_check: CheckButton = $Root/SettingsOverlay/SettingsPanel/SfxCheck
@onready var settings_note: Label = $Root/SettingsOverlay/SettingsPanel/SettingsNote
@onready var close_settings_button: Button = $Root/SettingsOverlay/SettingsPanel/CloseSettingsButton
@onready var intro_overlay: Control = $Root/IntroOverlay
@onready var intro_panel: Panel = $Root/IntroOverlay/IntroPanel
@onready var intro_title: Label = $Root/IntroOverlay/IntroPanel/IntroTitle
@onready var intro_body: Label = $Root/IntroOverlay/IntroPanel/IntroBody
@onready var intro_goal: Label = $Root/IntroOverlay/IntroPanel/IntroGoal
@onready var close_intro_button: Button = $Root/IntroOverlay/IntroPanel/CloseIntroButton

func _ready() -> void:
    print("MainMenu _ready called")
    _capture_base_positions()
    _apply_pixel_styles()
    _sync_continue_button()
    _play_menu_music()
    new_game_button.grab_focus()
    set_process(true)

func _process(delta: float) -> void:
    _float_phase += delta
    hero_book.position = _hero_book_base_position + Vector2(0.0, sin(_float_phase * 1.6) * 5.0)
    page_left.position = _page_left_base_position + Vector2(0.0, sin(_float_phase * 2.0) * 7.0)
    page_right.position = _page_right_base_position + Vector2(0.0, cos(_float_phase * 2.1) * 7.0)

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
        if settings_overlay.visible:
            _hide_settings()
        elif intro_overlay.visible:
            _hide_intro()

func _on_new_game_button_pressed() -> void:
    print("New game triggered")
    _play_confirm_sfx()
    new_game_button.text = "正在打开序章..."
    new_game_button.disabled = true
    QuestManager.reset_chapter()
    PlayerData.reset_runtime_state()

    var err := get_tree().change_scene_to_file(PROLOGUE_SCENE_PATH)
    if err != OK:
        printerr("Failed to change scene: ", err)
        new_game_button.text = "进入失败：" + str(err)
        new_game_button.disabled = false
    else:
        print("Scene change initiated")

func _on_continue_button_pressed() -> void:
    if not _has_save_game():
        return

    _on_new_game_button_pressed()

func _on_settings_button_pressed() -> void:
    _play_confirm_sfx()
    settings_overlay.visible = true
    intro_overlay.visible = false
    close_settings_button.grab_focus()

func _on_intro_button_pressed() -> void:
    _play_confirm_sfx()
    intro_overlay.visible = true
    settings_overlay.visible = false
    close_intro_button.grab_focus()

func _on_quit_button_pressed() -> void:
    print("Quit triggered")
    _play_confirm_sfx()
    get_tree().quit()

func _on_master_slider_value_changed(value: float) -> void:
    var bus_index := AudioServer.get_bus_index("Master")
    if bus_index == -1:
        return

    var linear_volume = clamp(value / 100.0, 0.0, 1.0)
    AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume) if linear_volume > 0.0 else -80.0)

func _on_music_check_toggled(button_pressed: bool) -> void:
    _music_enabled = button_pressed
    if _music_enabled:
        _play_menu_music()
    else:
        AudioManager.stop_music()

func _on_sfx_check_toggled(button_pressed: bool) -> void:
    _sfx_enabled = button_pressed
    if _sfx_enabled:
        _play_confirm_sfx()

func _on_close_settings_button_pressed() -> void:
    _hide_settings()

func _on_close_intro_button_pressed() -> void:
    _hide_intro()

func is_settings_open() -> bool:
    return settings_overlay.visible

func is_intro_open() -> bool:
    return intro_overlay.visible

func has_continue_game_enabled() -> bool:
    return not continue_button.disabled

func _hide_settings() -> void:
    settings_overlay.visible = false
    settings_button.grab_focus()

func _hide_intro() -> void:
    intro_overlay.visible = false
    intro_button.grab_focus()

func _sync_continue_button() -> void:
    var has_save := _has_save_game()
    continue_button.disabled = not has_save
    continue_button.text = "继续游戏" if has_save else "继续游戏（暂无存档）"

func _has_save_game() -> bool:
    return FileAccess.file_exists("user://savegame.json")

func _play_menu_music() -> void:
    if _music_enabled:
        AudioManager.play_music_path(MENU_BGM_PATH)

func _play_confirm_sfx() -> void:
    if _sfx_enabled:
        AudioManager.play_sfx_path(AudioManager.SFX_UI_CONFIRM)

func _capture_base_positions() -> void:
    _hero_book_base_position = hero_book.position
    _page_left_base_position = page_left.position
    _page_right_base_position = page_right.position

func _apply_pixel_styles() -> void:
    PixelUIStyle.apply_panel(hero_copy_panel)
    PixelUIStyle.apply_panel(menu_panel)
    PixelUIStyle.apply_panel(settings_panel)
    PixelUIStyle.apply_panel(intro_panel)

    for button in [new_game_button, continue_button, settings_button, intro_button, quit_button, close_settings_button, close_intro_button]:
        PixelUIStyle.apply_button(button)
        button.focus_mode = Control.FOCUS_ALL

    PixelUIStyle.apply_label(hero_title, 46, Color(1.0, 0.88, 0.35, 1.0))
    PixelUIStyle.apply_label(hero_chinese_title, 38, PixelUIStyle.TEXT_COLOR)
    PixelUIStyle.apply_label(hero_copy, 22, PixelUIStyle.TEXT_COLOR)
    PixelUIStyle.apply_label(menu_title, 32, Color(1.0, 0.88, 0.35, 1.0))
    PixelUIStyle.apply_label(menu_subtitle, 18, PixelUIStyle.MUTED_TEXT_COLOR)
    PixelUIStyle.apply_label(menu_hint, 16, PixelUIStyle.MUTED_TEXT_COLOR)
    PixelUIStyle.apply_label(settings_title, 34, Color(1.0, 0.88, 0.35, 1.0))
    PixelUIStyle.apply_label(master_label, 22, PixelUIStyle.TEXT_COLOR)
    PixelUIStyle.apply_label(settings_note, 18, PixelUIStyle.MUTED_TEXT_COLOR)
    PixelUIStyle.apply_label(intro_title, 34, Color(1.0, 0.88, 0.35, 1.0))
    PixelUIStyle.apply_label(intro_body, 22, PixelUIStyle.TEXT_COLOR)
    PixelUIStyle.apply_label(intro_goal, 20, Color(1.0, 0.88, 0.35, 1.0))

    for check_button in [music_check, sfx_check]:
        check_button.add_theme_font_size_override("font_size", 22)
        check_button.add_theme_color_override("font_color", PixelUIStyle.TEXT_COLOR)
        check_button.add_theme_color_override("font_hover_color", PixelUIStyle.TEXT_COLOR)
        check_button.add_theme_color_override("font_pressed_color", Color(1.0, 0.88, 0.35, 1.0))
