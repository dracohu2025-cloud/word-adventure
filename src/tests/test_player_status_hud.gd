extends Node

func _ready() -> void:
    PlayerData.reset_runtime_state()
    QuestManager.reset_chapter()

    var hud = load("res://scenes/ui/village_hud.tscn").instantiate()
    add_child(hud)
    await get_tree().process_frame

    _require_node(hud, "Panel/LevelLabel")
    _require_node(hud, "Panel/HPLabel")
    _require_node(hud, "Panel/FrameTexture")
    _require_node(hud, "Panel/AvatarIcon")
    _require_node(hud, "Panel/GoldIcon")
    _require_node(hud, "Panel/PageIcon")
    _require_node(hud, "Panel/HPBar")
    _require_node(hud, "Panel/MPLabel")
    _require_node(hud, "Panel/MPBar")
    _require_node(hud, "Panel/GoldLabel")
    _require_node(hud, "Panel/PageLabel")
    _require_node(hud, "Panel/RewardLabel")

    var panel: Panel = hud.get_node("Panel")
    var level_label: Label = hud.get_node("Panel/LevelLabel")
    var hp_label: Label = hud.get_node("Panel/HPLabel")
    var frame_texture: NinePatchRect = hud.get_node("Panel/FrameTexture")
    var avatar_icon: TextureRect = hud.get_node("Panel/AvatarIcon")
    var gold_icon: TextureRect = hud.get_node("Panel/GoldIcon")
    var page_icon: TextureRect = hud.get_node("Panel/PageIcon")
    var hp_bar: Control = hud.get_node("Panel/HPBar")
    var hp_fill: ColorRect = hud.get_node("Panel/HPBar/Fill")
    var hp_frame: Node = hud.get_node("Panel/HPBar/Frame")
    var mp_label: Label = hud.get_node("Panel/MPLabel")
    var mp_bar: Control = hud.get_node("Panel/MPBar")
    var mp_frame: Node = hud.get_node("Panel/MPBar/Frame")
    var gold_label: Label = hud.get_node("Panel/GoldLabel")
    var page_label: Label = hud.get_node("Panel/PageLabel")
    var reward_label: Label = hud.get_node("Panel/RewardLabel")

    assert(frame_texture.texture != null, "HUD should use a Tiny Swords pixel frame texture")
    assert(not String(hud.UI_FRAME_PATH).contains("Carved"), "HUD status frame should not use the damaged carved banner")
    assert(String(hud.UI_FRAME_PATH).ends_with("Button_Disable_9Slides.png"), "HUD should use a complete 9-slice status panel frame")
    assert(panel.get_theme_stylebox("panel") is StyleBoxEmpty, "HUD panel should leave its border rendering to the pixel frame asset")
    assert(avatar_icon.texture != null, "HUD should show a player avatar asset")
    assert(gold_icon.texture != null, "HUD should show a gold icon asset")
    assert(String(hud.GOLD_ICON_PATH).ends_with("Icon_03.png"), "HUD gold icon should use the coin asset")
    assert(FileAccess.file_exists(hud.GOLD_ICON_PATH), "HUD coin asset should exist locally")
    assert(page_icon.texture != null, "HUD should show a page icon asset")
    assert(hp_frame is Panel, "HUD HP bar should use a clean pixel frame panel")
    assert(mp_frame is Panel, "HUD MP bar should use a clean pixel frame panel")
    assert(level_label.text.contains("Lv.1"), "HUD should show player level")
    assert(hp_label.text.contains("120/120"), "HUD should show full HP")
    assert(hp_label.position.x + hp_label.size.x + 8.0 <= hp_bar.position.x, "HUD HP text should not overlap the HP bar")
    assert(hp_fill.size.x >= hp_bar.size.x - 38.0, "HUD HP fill should reflect full HP")
    assert(mp_label.text.contains("40/40"), "HUD should show full MP")
    assert(mp_label.position.x + mp_label.size.x + 8.0 <= mp_bar.position.x, "HUD MP text should not overlap the MP bar")
    assert(is_equal_approx(mp_bar.size.x, hp_bar.size.x), "HUD HP and MP bars should have matching widths")
    var mp_fill: ColorRect = hud.get_node("Panel/MPBar/Fill")
    assert(mp_fill.size.x >= mp_bar.size.x - 38.0, "HUD MP fill should reflect full MP")
    assert(gold_label.text.contains("0"), "HUD should show starting gold")
    assert(page_label.text.contains("0/3"), "HUD should show book pages")
    if reward_label.visible:
        _fail("HUD reward text should not be a persistent status item")
        return

    PlayerData.apply_damage(20)
    PlayerData.add_gold(5)
    QuestManager.complete_branch("library")
    await get_tree().process_frame

    if not reward_label.visible:
        _fail("Completing a branch should show a temporary reward toast")
        return
    if reward_label.global_position.y < mp_bar.global_position.y + mp_bar.size.y + 8.0:
        _fail("Reward toast should not overlap the MP bar")
        return
    assert(hp_label.text.contains("100/120"), "HUD should update HP after damage")
    assert(hp_fill.size.x < hp_bar.size.x - 38.0, "HUD HP fill should shrink after damage")
    assert(gold_label.text.contains("5"), "HUD should update gold")
    assert(page_label.text.contains("1/3"), "HUD should keep quest progress")
    await get_tree().create_timer(hud.REWARD_TOAST_SECONDS + 0.2).timeout
    if reward_label.visible:
        _fail("Reward toast should auto-hide instead of staying in the HUD")
        return

    hud.queue_free()
    await get_tree().process_frame
    print("Player status HUD regression test PASSED")
    get_tree().quit()

func _require_node(root: Node, node_path: String) -> void:
    if not root.has_node(node_path):
        _fail("Missing HUD node: " + node_path)

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
