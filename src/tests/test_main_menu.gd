extends Node

func _ready() -> void:
    var tree := get_tree()
    var main_menu = load("res://scenes/main_menu.tscn").instantiate()
    add_child(main_menu)

    await tree.create_timer(0.1).timeout

    print("Clicking StartButton programmatically...")
    var btn = main_menu.get_node("CenterContainer/VBoxContainer/StartButton")
    btn.emit_signal("pressed")
    assert(btn.disabled, "Start button should be disabled after starting the game")
    assert(btn.text == "Loading...", "Start button should show loading state after starting the game")

    print("✅ Main menu regression test PASSED")
    tree.quit()
