extends Node

func _ready() -> void:
    var capture_viewport := SubViewport.new()
    capture_viewport.name = "PortraitCaptureViewport"
    capture_viewport.size = Vector2i(720, 1280)
    capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    add_child(capture_viewport)

    var prototype = load("res://scenes/prototypes/word_castle_portrait_prototype.tscn").instantiate()
    capture_viewport.add_child(prototype)

    for _frame in range(4):
        await get_tree().process_frame

    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp_assets"))
    var texture := capture_viewport.get_texture()
    if texture == null:
        print("Skipping word castle portrait screenshot capture without a render texture")
        get_tree().quit()
        return

    var image := texture.get_image()
    if image == null:
        print("Skipping word castle portrait screenshot capture without an image")
        get_tree().quit()
        return

    image.save_png("res://.tmp_assets/word_castle_portrait_prototype.png")
    print("Saved word castle portrait prototype screenshot")
    get_tree().quit()
