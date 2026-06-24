extends Node
## Regression test for contextual interaction hints.

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame

    var panel: Control = ControlHints.get_node("Panel")
    var hint_label: Label = ControlHints.get_node("Panel/HintLabel")
    if not _require(ControlHints.has_node("Panel/FrameTexture"), "Contextual hint should use an asset-backed pixel frame"):
        return
    if not _require(ControlHints.has_node("Panel/KeyBackground"), "Contextual hint should render the keyboard shortcut inside an asset-backed segment"):
        return
    if not _require(ControlHints.has_node("Panel/ActionLabel"), "Contextual hint should render action text outside the hit button"):
        return
    if not _require(ControlHints.has_node("Panel/ActionHighlight"), "Contextual hint should render a clear visual action button"):
        return
    if not _require(ControlHints.has_node("Panel/ActionButton"), "Contextual hint should expose an action button"):
        return

    var frame_texture: NinePatchRect = ControlHints.get_node("Panel/FrameTexture")
    var key_background: NinePatchRect = ControlHints.get_node("Panel/KeyBackground")
    var action_highlight: NinePatchRect = ControlHints.get_node("Panel/ActionHighlight")
    var action_label: Label = ControlHints.get_node("Panel/ActionLabel")
    var action_button: Button = ControlHints.get_node("Panel/ActionButton")
    if not _require(not panel.visible, "World scene should not show a persistent bottom control hint"):
        return

    var player: CharacterBody2D = village.get_node("Player")
    var npc: Area2D = village.get_node("BlacksmithNPC")
    player.global_position = npc.global_position + Vector2(0, 48)
    await get_tree().physics_frame
    await get_tree().physics_frame

    if not _require(panel.visible, "NPC proximity should show a contextual interaction hint"):
        return
    if not _require(not npc.get_node("InteractionMarker").visible, "NPC exclamation marker should stay hidden when the contextual prompt is visible"):
        return
    if not _require(key_background.visible, "NPC hint should show an asset-backed keyboard segment"):
        return
    if not _require(key_background.texture != null, "NPC keyboard segment should use an asset-backed pixel texture"):
        return
    if not _require(key_background.texture.resource_path.ends_with("Button_Disable_9Slides.png"), "NPC keyboard segment should use the neutral prompt asset"):
        return
    if not _require(panel.size == Vector2(156, 38), "NPC hint should stay compact and avoid covering scene art"):
        return
    if not _require(hint_label.text == "空格/E", "NPC hint should keep the keyboard shortcut compact"):
        return
    if not _require(hint_label.get_theme_font_size("font_size") == action_label.get_theme_font_size("font_size"), "Keyboard and action text should use the same font size"):
        return
    if not _require(hint_label.get_theme_font_size("font_size") <= 15, "Contextual hint text should be small enough for the pixel frame"):
        return
    if not _require(_fills_prompt_height(panel, hint_label), "Keyboard hint should use the full prompt height for clean vertical alignment"):
        return
    if not _require(_fills_prompt_height(panel, action_label), "Action label should use the full prompt height for clean vertical alignment"):
        return
    if not _require(action_button.visible, "NPC hint should show a clickable action button"):
        return
    if not _require(action_highlight.visible, "NPC hint should highlight the clickable action area"):
        return
    if not _require(action_highlight.texture != null, "NPC action highlight should use an asset-backed pixel texture"):
        return
    if not _require(action_highlight.texture.resource_path.ends_with("Button_Hover_3Slides.png"), "NPC action highlight should use a clear button asset"):
        return
    if not _require(absf(key_background.size.y - action_highlight.size.y) <= 1.0, "Keyboard and action visual containers should have the same height"):
        return
    if not _require(absf(key_background.position.y - action_highlight.position.y) <= 1.0, "Keyboard and action visual containers should share the same top alignment"):
        return
    if not _require(_wraps_label(action_highlight, action_label), "NPC action highlight should sit directly behind the action text"):
        return
    if not _require(action_button.text.is_empty(), "Clickable hit area should not draw a separate ugly button label"):
        return
    if not _require(action_button.flat, "Clickable hit area should not draw a default button frame"):
        return
    if not _require(action_label.text == "交谈", "NPC action label should describe talking"):
        return
    if not _require(action_label.get_theme_font_size("font_size") <= 18, "Action text should not overpower the compact prompt"):
        return
    if not _require(_is_vertically_centered(panel, hint_label), "Keyboard hint should be vertically centered in the prompt"):
        return
    if not _require(_is_vertically_centered(panel, action_label), "Action label should be vertically centered in the prompt"):
        return
    if not _require(_is_near_target(panel, npc, 170.0), "NPC hint should appear near the interactable NPC"):
        return

    var npc_click_position := action_button.global_position + action_button.size * 0.5
    if not _require(ControlHints.contains_screen_point(npc_click_position), "ControlHints should detect clicks inside the contextual prompt"):
        return
    if not _require(not village._handle_world_click(_left_click(npc_click_position)), "World click-to-move should not steal NPC hint clicks"):
        return

    action_button.pressed.emit()
    await get_tree().process_frame
    if not _require(GameManager.current_state == GameManager.GameState.DIALOGUE, "Clicking the NPC action button should start dialogue"):
        return

    village.queue_free()
    await get_tree().process_frame
    village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().physics_frame
    panel = ControlHints.get_node("Panel")
    hint_label = ControlHints.get_node("Panel/HintLabel")
    frame_texture = ControlHints.get_node("Panel/FrameTexture")
    key_background = ControlHints.get_node("Panel/KeyBackground")
    action_label = ControlHints.get_node("Panel/ActionLabel")
    action_highlight = ControlHints.get_node("Panel/ActionHighlight")
    action_button = ControlHints.get_node("Panel/ActionButton")
    player = village.get_node("Player")
    npc = village.get_node("BlacksmithNPC")

    player.global_position = npc.global_position + Vector2(-260, 0)
    await get_tree().physics_frame
    await get_tree().physics_frame
    if not _require(not panel.visible, "NPC hint should hide after leaving interaction range"):
        return

    var boss: Area2D = village.get_node("WordImpBoss")
    boss.set_available(true)
    await get_tree().physics_frame
    player.global_position = boss.global_position + Vector2(0, 40)
    await get_tree().physics_frame
    await get_tree().physics_frame

    if not _require(panel.visible, "Boss proximity should show a contextual interaction hint"):
        return
    if not _require(not boss.get_node("InteractionMarker").visible, "Boss exclamation marker should stay hidden when the contextual prompt is visible"):
        return
    if not _require(key_background.visible, "Boss hint should show an asset-backed keyboard segment"):
        return
    if not _require(key_background.texture != null, "Boss keyboard segment should use an asset-backed pixel texture"):
        return
    if not _require(key_background.texture.resource_path.ends_with("Button_Disable_9Slides.png"), "Boss keyboard segment should use the neutral prompt asset"):
        return
    if not _require(panel.size == Vector2(156, 38), "Boss hint should stay compact and avoid covering scene art"):
        return
    if not _require(hint_label.text == "空格/E", "Boss hint should keep the keyboard shortcut compact"):
        return
    if not _require(action_button.visible, "Boss hint should show a clickable action button"):
        return
    if not _require(action_highlight.visible, "Boss hint should highlight the clickable action area"):
        return
    if not _require(action_highlight.texture.resource_path.ends_with("Button_Hover_3Slides.png"), "Boss action highlight should use a clear button asset"):
        return
    if not _require(absf(key_background.size.y - action_highlight.size.y) <= 1.0, "Boss keyboard and action visual containers should have the same height"):
        return
    if not _require(absf(key_background.position.y - action_highlight.position.y) <= 1.0, "Boss keyboard and action visual containers should share the same top alignment"):
        return
    if not _require(_wraps_label(action_highlight, action_label), "Boss action highlight should sit directly behind the action text"):
        return
    if not _require(action_button.text.is_empty(), "Boss hit area should not draw a separate ugly button label"):
        return
    if not _require(action_label.text == "挑战", "Boss action label should describe challenging"):
        return
    if not _require(hint_label.get_theme_font_size("font_size") == action_label.get_theme_font_size("font_size"), "Boss keyboard and action text should use the same font size"):
        return
    if not _require(_fills_prompt_height(panel, hint_label), "Boss keyboard hint should use the full prompt height"):
        return
    if not _require(_fills_prompt_height(panel, action_label), "Boss action label should use the full prompt height"):
        return
    if not _require(_is_near_target(panel, boss, 170.0), "Boss hint should appear near the interactable boss"):
        return

    var boss_click_position := action_button.global_position + action_button.size * 0.5
    if not _require(ControlHints.contains_screen_point(boss_click_position), "ControlHints should detect clicks inside the boss prompt"):
        return
    if not _require(not village._handle_world_click(_left_click(boss_click_position)), "World click-to-move should not steal boss hint clicks"):
        return

    action_button.pressed.emit()
    await get_tree().process_frame
    if not _require(GameManager.current_state == GameManager.GameState.COMBAT, "Clicking the boss action button should start combat"):
        return

    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    print("Contextual control hints regression test PASSED")
    get_tree().quit()

func _is_near_target(panel: Control, target: Node2D, max_distance: float) -> bool:
    var panel_center := panel.global_position + panel.size * 0.5
    var target_screen_position := target.get_global_transform_with_canvas().origin
    return panel_center.distance_to(target_screen_position) <= max_distance

func _is_vertically_centered(panel: Control, label: Control) -> bool:
    var panel_center_y := panel.size.y * 0.5
    var label_center_y := label.position.y + label.size.y * 0.5
    return absf(label_center_y - panel_center_y) <= 1.0

func _fills_prompt_height(panel: Control, label: Control) -> bool:
    return label.position.y == 0.0 and absf(label.size.y - panel.size.y) <= 1.0

func _wraps_label(background: Control, label: Control) -> bool:
    var background_rect := Rect2(background.position, background.size)
    var label_rect := Rect2(label.position, label.size)
    return background_rect.encloses(label_rect)

func _left_click(screen_position: Vector2) -> InputEventMouseButton:
    var click := InputEventMouseButton.new()
    click.button_index = MOUSE_BUTTON_LEFT
    click.pressed = true
    click.position = screen_position
    click.global_position = screen_position
    return click

func _require(condition: bool, message: String) -> bool:
    if condition:
        return true
    push_error(message)
    get_tree().quit(1)
    return false
