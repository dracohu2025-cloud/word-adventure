extends Node
## Utility scene for capturing the village visual pass.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping village visual screenshot capture in headless mode")
        get_tree().quit()
        return

    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/village_visual_pass.png")
    print("Saved village visual screenshot")
    get_tree().quit()
