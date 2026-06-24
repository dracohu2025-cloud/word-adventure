extends Node

func _ready() -> void:
    var tree := get_tree()
    var main_menu = load("res://scenes/main_menu.tscn").instantiate()
    add_child(main_menu)

    await tree.create_timer(0.1).timeout

    assert(not main_menu.has_continue_game_enabled(), "Continue game should be disabled without a save file")

    var settings_button = main_menu.get_node("Root/MenuPanel/MenuButtons/SettingsButton")
    settings_button.emit_signal("pressed")
    await tree.create_timer(0.05).timeout
    assert(main_menu.is_settings_open(), "Settings overlay should open from the settings button")

    var close_settings_button = main_menu.get_node("Root/SettingsOverlay/SettingsPanel/CloseSettingsButton")
    close_settings_button.emit_signal("pressed")
    await tree.create_timer(0.05).timeout
    assert(not main_menu.is_settings_open(), "Settings overlay should close from the return button")

    var intro_button = main_menu.get_node("Root/MenuPanel/MenuButtons/IntroButton")
    intro_button.emit_signal("pressed")
    await tree.create_timer(0.05).timeout
    assert(main_menu.is_intro_open(), "Intro overlay should open from the intro button")

    var close_intro_button = main_menu.get_node("Root/IntroOverlay/IntroPanel/CloseIntroButton")
    close_intro_button.emit_signal("pressed")
    await tree.create_timer(0.05).timeout
    assert(not main_menu.is_intro_open(), "Intro overlay should close from the return button")

    print("Clicking NewGameButton programmatically...")
    var btn = main_menu.get_node("Root/MenuPanel/MenuButtons/NewGameButton")
    btn.emit_signal("pressed")
    assert(btn.disabled, "New game button should be disabled after starting the game")
    assert(btn.text == "正在打开序章...", "New game button should show loading state after starting the game")

    print("✅ Main menu regression test PASSED")
    tree.quit()
