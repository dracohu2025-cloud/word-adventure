extends Node

func _ready() -> void:
    print("SceneTransition initialized")

func transition_to(scene_path: String) -> void:
    get_tree().change_scene_to_file(scene_path)
