extends Node
## Utility scene for capturing the visible supply cache before pickup.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping supply cache screenshot capture in headless mode")
        get_tree().quit()
        return

    var forest = load("res://scenes/world/whispering_forest.tscn").instantiate()
    add_child(forest)
    await get_tree().process_frame
    await get_tree().physics_frame

    var player: CharacterBody2D = forest.get_node("Player")
    var cache = forest.get_node("ForestSupplyCache")
    player.global_position = cache.global_position + Vector2(-54, -36)
    cache._on_body_entered(player)
    await get_tree().physics_frame
    await get_tree().physics_frame
    await get_tree().process_frame

    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp_assets"))
    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/supply_cache_visual_pass.png")
    print("Saved supply cache visual screenshot")
    image = null
    AudioManager.stop_music()
    forest.queue_free()
    await get_tree().process_frame
    get_tree().quit()
