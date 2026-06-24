extends Node

func _ready() -> void:
    var tree := get_tree()
    var prototype = load("res://scenes/prototypes/word_castle_portrait_prototype.tscn").instantiate()
    add_child(prototype)
    await tree.process_frame

    if not _require(prototype.get_design_size() == Vector2(720, 1280), "Prototype should use the agreed 720x1280 portrait baseline"):
        return
    if not _require(prototype.get_current_room_name().contains("旧书回廊"), "Prototype should expose the first castle room name"):
        return
    if not _require(prototype.get_active_target() == "图书管理员", "Prototype should start near a clear NPC target"):
        return
    if not _require(prototype.get_environment_mode() == "castle_room_maze", "Prototype should use castle room maze visuals instead of village/outdoor placeholders"):
        return

    var report: Dictionary = prototype.get_layout_report()
    for key in report.keys():
        if not _require(report[key], "Layout check failed: %s" % key):
            return

    prototype.trigger_action("inventory")
    await tree.process_frame
    if not _require(prototype.is_overlay_visible("InventoryOverlay"), "Inventory overlay should open through the shared action API"):
        return

    prototype.trigger_action("map")
    await tree.process_frame
    if not _require(prototype.is_overlay_visible("MapOverlay"), "Map overlay should open through the shared action API"):
        return

    var old_room_name: String = prototype.get_current_room_name()
    prototype.trigger_action("enter")
    await tree.process_frame
    if not _require(prototype.get_current_room_name() != old_room_name, "Enter action should advance the room title"):
        return

    print("Word castle portrait prototype regression test PASSED")
    tree.quit()

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
