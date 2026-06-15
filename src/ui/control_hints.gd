extends CanvasLayer

func _ready() -> void:
    await get_tree().process_frame
    update_hint()

func update_hint() -> void:
    var current_scene = get_tree().current_scene
    if current_scene and current_scene.scene_file_path == "res://scenes/main_menu.tscn":
        $Panel/HintLabel.text = "按 空格/回车 开始  |  或点击 Start Journey"
    else:
        $Panel/HintLabel.text = "移动: ↑ ↓ ← →  |  交互: 空格 / E"
