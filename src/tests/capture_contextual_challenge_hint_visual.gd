extends Node
## Utility scene for capturing challenge contextual hints.

func _ready() -> void:
    if DisplayServer.get_name() == "headless":
        print("Skipping challenge hint screenshot capture in headless mode")
        get_tree().quit()
        return

    var forest = load("res://scenes/world/whispering_forest.tscn").instantiate()
    add_child(forest)
    await get_tree().process_frame
    await get_tree().physics_frame

    var player: CharacterBody2D = forest.get_node("Player")
    var enemy: Area2D = forest.get_node("LeafImp")
    enemy.set_available(true)
    player.global_position = enemy.global_position + Vector2(0, 42)
    enemy._on_body_entered(player)
    await get_tree().physics_frame
    await get_tree().physics_frame
    await get_tree().physics_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    image.save_png("res://.tmp_assets/contextual_challenge_hint_visual_pass.png")
    print("Saved challenge contextual hint visual screenshot")
    image = null
    AudioManager.stop_music()
    forest.queue_free()
    await get_tree().process_frame
    get_tree().quit()
