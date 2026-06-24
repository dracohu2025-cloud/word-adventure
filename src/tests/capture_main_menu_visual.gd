extends Node
## Utility scene for capturing the main menu and its modal panels.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping main menu screenshot capture in headless mode")
        get_tree().quit()
        return

    var main_menu = load("res://scenes/main_menu.tscn").instantiate()
    add_child(main_menu)
    await get_tree().process_frame
    await get_tree().process_frame

    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp_assets"))
    _save_viewport("res://.tmp_assets/main_menu_visual_pass.png")

    main_menu.get_node("Root/MenuPanel/MenuButtons/SettingsButton").emit_signal("pressed")
    await get_tree().process_frame
    await get_tree().process_frame
    _save_viewport("res://.tmp_assets/main_menu_settings_visual_pass.png")

    main_menu.get_node("Root/SettingsOverlay/SettingsPanel/CloseSettingsButton").emit_signal("pressed")
    main_menu.get_node("Root/MenuPanel/MenuButtons/IntroButton").emit_signal("pressed")
    await get_tree().process_frame
    await get_tree().process_frame
    _save_viewport("res://.tmp_assets/main_menu_intro_visual_pass.png")

    print("Saved main menu visual screenshots")
    AudioManager.stop_all_sfx()
    AudioManager.stop_music()
    await get_tree().process_frame
    main_menu.queue_free()
    for _frame in range(8):
        await get_tree().process_frame
    get_tree().quit()

func _save_viewport(path: String) -> void:
    var image := get_viewport().get_texture().get_image()
    image.save_png(path)
    image = null
