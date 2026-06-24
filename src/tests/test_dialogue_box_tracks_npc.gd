extends Node
## Regression test for NPC-localized dialogue bubbles.

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame

    var blacksmith: Area2D = village.get_node("BlacksmithNPC")
    blacksmith.start_interaction()
    await get_tree().process_frame

    if not _require(DialogueManager.has_method("get_speaker_node"), "DialogueManager should expose the active speaker node"):
        return
    if not _require(DialogueManager.get_speaker_node() == blacksmith, "DialogueManager should track the NPC that started the dialogue"):
        return
    if not _require(DialogueBox.speaker_label.text == "铁匠", "Dialogue bubble should name the speaking NPC"):
        return
    if not _require(DialogueBox.panel.visible, "Dialogue bubble should be visible during NPC dialogue"):
        return
    if not _require(DialogueBox.has_node("Pointer"), "Dialogue bubble should include a pointer toward the NPC"):
        return
    if not _require(DialogueBox.has_node("SpeakerHighlight"), "Dialogue bubble should highlight the speaking NPC"):
        return
    if not _require(DialogueBox.has_node("Panel/ContinueHintLabel"), "Dialogue bubble should include its own continue key hint"):
        return

    var pointer: CanvasItem = DialogueBox.get_node("Pointer")
    var speaker_highlight: Node2D = DialogueBox.get_node("SpeakerHighlight")
    var continue_hint_label: Label = DialogueBox.get_node("Panel/ContinueHintLabel")
    var speaker_screen_position := blacksmith.get_global_transform_with_canvas().origin
    var panel_center := DialogueBox.panel.global_position + DialogueBox.panel.size * 0.5

    if not _require(pointer.visible, "Dialogue pointer should be visible during NPC dialogue"):
        return
    if not _require(speaker_highlight.visible, "Speaker highlight should be visible during NPC dialogue"):
        return
    if not _require(panel_center.distance_to(speaker_screen_position) <= 260.0, "Dialogue bubble should appear close to the speaking NPC"):
        return
    if not _require(abs(pointer.global_position.x - speaker_screen_position.x) <= 120.0, "Dialogue pointer should horizontally indicate the speaking NPC"):
        return
    if not _require(speaker_highlight.global_position.distance_to(speaker_screen_position + Vector2(0, -18)) <= 4.0, "Speaker highlight should track the speaking NPC"):
        return
    if not _require(continue_hint_label.text == "空格 / E 继续", "Dialogue bubble should carry the continue key hint"):
        return

    DialogueManager.advance()
    await get_tree().process_frame
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    print("NPC-localized dialogue bubble regression test PASSED")
    get_tree().quit()

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
