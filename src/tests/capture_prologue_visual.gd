extends Node
## Utility scene for capturing the prologue story and choice screens.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping prologue screenshot capture in headless mode")
        get_tree().quit()
        return

    var prologue = load("res://scenes/story/prologue.tscn").instantiate()
    add_child(prologue)
    await get_tree().process_frame
    await get_tree().process_frame

    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp_assets"))
    _save_viewport("res://.tmp_assets/prologue_visual_pass.png")
    prologue.advance()
    await get_tree().process_frame
    await get_tree().process_frame
    _save_viewport("res://.tmp_assets/prologue_choice_visual_pass.png")
    prologue.choose_word("book")
    await get_tree().process_frame
    await get_tree().process_frame
    _save_viewport("res://.tmp_assets/prologue_choice_feedback_visual_pass.png")
    prologue.advance()
    await get_tree().process_frame
    prologue.advance()
    await get_tree().process_frame
    prologue.advance()
    await get_tree().process_frame
    await get_tree().process_frame
    _save_viewport("res://.tmp_assets/prologue_late_dialogue_visual_pass.png")
    print("Saved prologue visual screenshots")
    AudioManager.stop_all_sfx()
    AudioManager.stop_music()
    await get_tree().process_frame
    prologue.queue_free()
    for _frame in range(8):
        await get_tree().process_frame
    get_tree().quit()

func _save_viewport(path: String) -> void:
    var image := get_viewport().get_texture().get_image()
    image.save_png(path)
    image = null
