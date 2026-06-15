extends CanvasLayer

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton

func _ready() -> void:
    print("MainMenu _ready called")
    start_button.grab_focus()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        print("Key pressed: ", event.physical_keycode)
        if event.is_action("ui_accept"):
            _on_start_button_pressed()

func _unhandled_input(event: InputEvent) -> void:
    # Fallback: if the button click didn't register, any unhandled click starts the game
    if event is InputEventMouseButton and event.pressed:
        print("Unhandled mouse click on main menu - starting game")
        _on_start_button_pressed()

func _on_start_button_pressed() -> void:
    print("Start Journey triggered!")
    start_button.text = "Loading..."
    start_button.disabled = true
    QuestManager.reset_chapter()

    var err = get_tree().change_scene_to_file("res://scenes/world/village.tscn")
    if err != OK:
        printerr("Failed to change scene: ", err)
        start_button.text = "Error: " + str(err)
        start_button.disabled = false
    else:
        print("Scene change initiated")

func _on_quit_button_pressed() -> void:
    print("Quit triggered!")
    get_tree().quit()
