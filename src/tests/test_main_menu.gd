extends Node

func _ready() -> void:
    var main_menu = load("res://scenes/main_menu.tscn").instantiate()
    add_child(main_menu)

    await get_tree().create_timer(0.1).timeout

    print("Clicking StartButton programmatically...")
    var btn = main_menu.get_node("CenterContainer/VBoxContainer/StartButton")
    btn.emit_signal("pressed")

    # Note: after change_scene_to_file, this scene is freed.
    await get_tree().create_timer(0.5).timeout
    print("Test complete (should not reach here if scene changed)")
    get_tree().quit()
