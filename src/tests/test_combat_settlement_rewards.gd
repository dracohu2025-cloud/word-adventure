extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    QuestManager.reset_chapter()

    var overlay = load("res://scenes/ui/combat_focus_overlay.tscn").instantiate()
    add_child(overlay)
    await get_tree().process_frame

    CombatManager.start_battle({
        "enemy_id": "reward_imp",
        "enemy_name": "Reward Imp",
        "max_hp": 8,
        "attack_power": 1,
        "defense": 0,
        "attack_speed": 0.1,
        "crit_chance": 0.0,
        "gold_reward": 7,
        "experience_reward": 11,
        "player_stats": {
            "level": 1,
            "max_hp": 100,
            "hp": 100,
            "max_mp": 40,
            "mp": 40,
            "attack_power": 40,
            "defense": 10,
            "attack_speed": 3.0,
            "crit_chance": 0.0,
            "crit_multiplier": 1.5,
        },
    })
    await get_tree().process_frame

    while CombatManager.is_battle_active():
        CombatManager.advance_battle(0.4)
        await get_tree().process_frame

    var focus_panel: Control = overlay.get_node("FocusPanel")
    var settlement_panel: Control = overlay.get_node("SettlementPanel")
    var settlement_frame: NinePatchRect = overlay.get_node("SettlementPanel/FrameTexture")
    var reward_backdrop: NinePatchRect = overlay.get_node("SettlementPanel/RewardBackdrop")
    var title_label: Label = overlay.get_node("SettlementPanel/TitleLabel")
    var result_label: Label = overlay.get_node("SettlementPanel/ResultLabel")
    var reward_label: Label = overlay.get_node("SettlementPanel/RewardLabel")
    var continue_button: Button = overlay.get_node("SettlementPanel/ContinueButton")
    var continue_button_texture: NinePatchRect = overlay.get_node("SettlementPanel/ContinueButton/ButtonTexture")
    var continue_button_label: Label = overlay.get_node("SettlementPanel/ContinueButton/ButtonLabel")

    assert(overlay.visible, "Victory settlement should keep overlay visible")
    assert(not focus_panel.visible, "Victory settlement should not show the battle panel underneath")
    assert(settlement_panel.visible, "Victory settlement panel should be visible")
    assert(not overlay.has_node("SettlementPanel/HeaderPlate"), "Settlement title should not use an unnecessary pale background plate")
    assert(_uses_tiny_swords_texture(settlement_frame), "Settlement panel frame should use Tiny Swords art")
    assert(_uses_tiny_swords_texture(reward_backdrop), "Settlement reward backdrop should use Tiny Swords art")
    assert(_uses_tiny_swords_texture(continue_button_texture), "Settlement continue button should use Tiny Swords art")
    assert(continue_button.text.is_empty(), "Settlement continue button should not expose default Button text")
    assert(continue_button_label.text == "继续", "Settlement continue label should live on the asset-backed button")
    _assert_control_inside(settlement_frame, title_label, 24.0, "Settlement title should stay inside the main panel")
    _assert_control_inside(settlement_frame, result_label, 24.0, "Settlement result should stay inside the main panel")
    _assert_control_inside(settlement_frame, reward_backdrop, 24.0, "Settlement reward backdrop should stay inside the main panel")
    _assert_control_inside(settlement_frame, continue_button, 24.0, "Settlement continue button should stay inside the main panel")
    assert(continue_button.global_position.y + continue_button.size.y <= settlement_frame.global_position.y + settlement_frame.size.y - 24.0, "Settlement continue button should leave a clear bottom safe margin")
    assert(result_label.text.contains("胜利"), "Settlement should show who won")
    assert(result_label.text.contains("Reward Imp"), "Settlement should show defeated enemy")
    assert(title_label.global_position.y + title_label.size.y <= result_label.global_position.y - 8.0, "Settlement title and result should have clear spacing")
    assert(reward_label.text.contains("金币 +7"), "Settlement should show gold reward")
    assert(reward_label.text.contains("经验 +11"), "Settlement should show experience reward")
    assert(reward_label.global_position.y >= reward_backdrop.global_position.y + 12.0, "Settlement reward text should start inside the reward backdrop")
    assert(reward_label.global_position.y + _estimate_label_text_height(reward_label) <= reward_backdrop.global_position.y + reward_backdrop.size.y - 12.0, "Settlement reward text should stay inside the reward backdrop")
    assert(reward_label.global_position.y + reward_label.size.y <= continue_button.global_position.y - 8.0, "Settlement reward text should not collide with the continue button")

    overlay.confirm_settlement()
    await get_tree().process_frame
    assert(not overlay.visible, "Confirming settlement should return to the map")

    overlay.queue_free()
    await get_tree().process_frame
    print("Combat settlement rewards regression test PASSED")
    get_tree().quit()

func _uses_tiny_swords_texture(rect: NinePatchRect) -> bool:
    if rect.texture == null:
        return false
    return rect.texture.resource_path.contains("assets/licensed/tiny_swords")

func _assert_control_inside(container: Control, child: Control, inset: float, message: String) -> void:
    var left := container.global_position.x + inset
    var top := container.global_position.y + inset
    var right := container.global_position.x + container.size.x - inset
    var bottom := container.global_position.y + container.size.y - inset
    assert(child.global_position.x >= left, message + " left")
    assert(child.global_position.y >= top, message + " top")
    assert(child.global_position.x + child.size.x <= right, message + " right")
    assert(child.global_position.y + child.size.y <= bottom, message + " bottom")

func _estimate_label_text_height(label: Label) -> float:
    var font_size := label.get_theme_font_size("font_size")
    var line_count := label.text.split("\n", false).size()
    return float(line_count * (font_size + 8))
