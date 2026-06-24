extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    QuestManager.reset_chapter()

    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    await get_tree().process_frame

    _require_node(village, "CombatFocusOverlay")
    _require_node(village, "CombatFocusOverlay/FocusPanel")
    _require_node(village, "CombatFocusOverlay/FocusPanel/PanelFill")
    _require_node(village, "CombatFocusOverlay/FocusPanel/PlayerAnchor/PlayerSprite")
    _require_node(village, "CombatFocusOverlay/FocusPanel/EnemyAnchor/EnemySprite")
    _require_node(village, "CombatFocusOverlay/FocusPanel/EnemyStatus/EnemyHPBar")
    _require_node(village, "CombatFocusOverlay/FocusPanel/EnemyStatus/EnemyHPBar/Frame")
    _require_node(village, "CombatFocusOverlay/FocusPanel/DamageTextLayer")
    _require_node(village, "CombatFocusOverlay/SettlementPanel")
    _require_node(village, "CombatFocusOverlay/SettlementPanel/FrameTexture")
    _require_node(village, "CombatFocusOverlay/SettlementPanel/RewardBackdrop")
    _require_node(village, "CombatFocusOverlay/SettlementPanel/ResultLabel")
    _require_node(village, "CombatFocusOverlay/SettlementPanel/RewardLabel")
    _require_node(village, "CombatFocusOverlay/SettlementPanel/ContinueButton")
    _require_node(village, "CombatFocusOverlay/SettlementPanel/ContinueButton/ButtonTexture")
    _require_node(village, "CombatFocusOverlay/SettlementPanel/ContinueButton/ButtonLabel")

    var overlay = village.get_node("CombatFocusOverlay")
    assert(not overlay.visible, "Combat focus overlay should start hidden")

    CombatManager.start_boss_battle("word_imp")
    await get_tree().process_frame

    assert(overlay.visible, "Combat focus overlay should appear during battle")
    var player_sprite: AnimatedSprite2D = overlay.get_node("FocusPanel/PlayerAnchor/PlayerSprite")
    var enemy_sprite: AnimatedSprite2D = overlay.get_node("FocusPanel/EnemyAnchor/EnemySprite")
    var focus_panel: Control = overlay.get_node("FocusPanel")
    var panel_fill: ColorRect = overlay.get_node("FocusPanel/PanelFill")
    var player_hp_frame: Node = overlay.get_node("FocusPanel/PlayerStatus/PlayerHPBar/Frame")
    var enemy_hp_frame: Node = overlay.get_node("FocusPanel/EnemyStatus/EnemyHPBar/Frame")
    var player_status: Control = overlay.get_node("FocusPanel/PlayerStatus")
    var enemy_status: Control = overlay.get_node("FocusPanel/EnemyStatus")
    var player_name_label: Label = overlay.get_node("FocusPanel/PlayerStatus/PlayerNameLabel")
    var player_hp_bar: Control = overlay.get_node("FocusPanel/PlayerStatus/PlayerHPBar")
    var enemy_name_label: Label = overlay.get_node("FocusPanel/EnemyStatus/EnemyNameLabel")
    var enemy_hp_bar: Control = overlay.get_node("FocusPanel/EnemyStatus/EnemyHPBar")
    var focus_panel_box := focus_panel.get_theme_stylebox("panel") as StyleBoxFlat
    var panel_center_x := focus_panel.global_position.x + focus_panel.size.x / 2.0
    var player_offset_x := player_sprite.global_position.x - panel_center_x
    var enemy_offset_x := enemy_sprite.global_position.x - panel_center_x
    var player_status_offset_x := (player_status.global_position.x + player_status.size.x / 2.0) - panel_center_x
    var enemy_status_offset_x := (enemy_status.global_position.x + enemy_status.size.x / 2.0) - panel_center_x
    assert(player_sprite.sprite_frames != null, "Overlay player should have sprite frames")
    assert(player_sprite.sprite_frames.has_animation("attack"), "Overlay player should expose an attack animation")
    assert(enemy_sprite.sprite_frames != null, "Overlay enemy should have sprite frames")
    assert(enemy_sprite.sprite_frames.has_animation("attack"), "Overlay enemy should expose an attack animation")
    assert(focus_panel_box != null, "Combat focus panel should use a StyleBoxFlat panel style")
    assert(focus_panel_box.bg_color.a >= 0.98, "Combat focus panel should be opaque enough to hide map clutter")
    assert(panel_fill.color.a >= 0.96, "Combat focus panel fill should be opaque enough to reduce background clutter")
    assert(focus_panel.size.x <= 540.0, "Combat focus panel should stay compact enough to read attack contact")
    assert(absf(player_sprite.global_position.x - enemy_sprite.global_position.x) <= 220.0, "Combatants should stand close enough for attack motion to read")
    assert(player_offset_x < 0.0 and enemy_offset_x > 0.0, "Combatants should stand on opposite sides of the focus panel")
    assert(absf(absf(player_offset_x) - absf(enemy_offset_x)) <= 8.0, "Combatants should be horizontally symmetrical in the focus panel")
    assert(absf(player_sprite.global_position.y - enemy_sprite.global_position.y) <= 4.0, "Combatants should align vertically in the focus panel")
    assert(absf(absf(player_status_offset_x) - absf(enemy_status_offset_x)) <= 8.0, "Combat status blocks should mirror each other")
    assert(player_name_label.text == "你", "Player combat label should address the player directly")
    assert(player_name_label.global_position.y + player_name_label.size.y <= player_sprite.global_position.y - 28.0, "Player name should sit above the avatar")
    assert(enemy_name_label.global_position.y + enemy_name_label.size.y <= enemy_sprite.global_position.y - 28.0, "Enemy name should sit above the avatar")
    assert(player_name_label.position.y + player_name_label.size.y <= player_hp_bar.position.y, "Player name should sit above the HP bar")
    assert(enemy_name_label.position.y + enemy_name_label.size.y <= enemy_hp_bar.position.y, "Enemy name should sit above the HP bar")
    if player_hp_bar.global_position.y < _get_sprite_visual_bottom(player_sprite) + 12.0:
        _fail("Player HP bar should not cover the avatar")
        return
    if enemy_hp_bar.global_position.y < _get_sprite_visual_bottom(enemy_sprite) + 12.0:
        _fail("Enemy HP bar should not cover the avatar")
        return
    assert(player_hp_frame is Panel, "Overlay player HP should use a clean pixel frame panel")
    assert(enemy_hp_frame is Panel, "Overlay enemy HP should use a clean pixel frame panel")

    var damage_layer: Control = overlay.get_node("FocusPanel/DamageTextLayer")
    var previous_damage_count := damage_layer.get_child_count()
    CombatManager.advance_battle(1.2)
    await get_tree().process_frame
    assert(damage_layer.get_child_count() > previous_damage_count, "Combat focus overlay should show large damage text")

    CombatManager.end_battle()
    await get_tree().process_frame
    var settlement_panel: Control = overlay.get_node("SettlementPanel")
    var settlement_frame: NinePatchRect = overlay.get_node("SettlementPanel/FrameTexture")
    var settlement_button_texture: NinePatchRect = overlay.get_node("SettlementPanel/ContinueButton/ButtonTexture")
    var title_label: Label = overlay.get_node("SettlementPanel/TitleLabel")
    var result_label: Label = overlay.get_node("SettlementPanel/ResultLabel")
    assert(overlay.visible, "Combat focus overlay should remain visible for settlement")
    assert(not focus_panel.visible, "Combat battle panel should hide during settlement")
    assert(settlement_panel.visible, "Combat settlement should appear after battle")
    assert(not overlay.has_node("SettlementPanel/HeaderPlate"), "Settlement title should not sit on a redundant pale plate")
    assert(_uses_tiny_swords_texture(settlement_frame), "Combat settlement should use Tiny Swords panel art")
    assert(_uses_tiny_swords_texture(settlement_button_texture), "Combat settlement continue button should use Tiny Swords button art")
    assert(title_label.global_position.y + title_label.size.y <= result_label.global_position.y - 8.0, "Settlement title and result should have clear spacing")
    assert(result_label.text.contains("失败"), "Settlement should explain player defeat")

    overlay.confirm_settlement()
    await get_tree().process_frame
    assert(not overlay.visible, "Combat focus overlay should hide after battle")

    village.queue_free()
    await get_tree().process_frame
    print("Combat focus overlay regression test PASSED")
    get_tree().quit()

func _require_node(root: Node, node_path: String) -> void:
    if not root.has_node(node_path):
        _fail("Missing combat focus node: " + node_path)

func _get_sprite_visual_bottom(sprite: AnimatedSprite2D) -> float:
    var frames := sprite.sprite_frames
    if frames == null:
        return sprite.global_position.y

    var texture := frames.get_frame_texture("idle", 0)
    if texture == null:
        return sprite.global_position.y

    return sprite.global_position.y + float(texture.get_height()) * sprite.global_scale.y * 0.5

func _uses_tiny_swords_texture(rect: NinePatchRect) -> bool:
    if rect.texture == null:
        return false
    return rect.texture.resource_path.contains("assets/licensed/tiny_swords")

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
