extends CanvasLayer

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")
const UI_FRAME_PATH: String = "res://assets/licensed/tiny_swords/ui/panels/Button_Disable_9Slides.png"
const AVATAR_PATH: String = "res://assets/licensed/tiny_swords/ui/avatars/Avatars_01.png"
const GOLD_ICON_PATH: String = "res://assets/licensed/tiny_swords/ui/icons/Icon_03.png"
const PAGE_ICON_PATH: String = "res://assets/licensed/tiny_swords/ui/icons/Icon_02.png"
const REWARD_TOAST_SECONDS: float = 1.4

@onready var panel: Panel = $Panel
@onready var frame_texture: NinePatchRect = $Panel/FrameTexture
@onready var avatar_icon: TextureRect = $Panel/AvatarIcon
@onready var gold_icon: TextureRect = $Panel/GoldIcon
@onready var page_icon: TextureRect = $Panel/PageIcon
@onready var level_label: Label = $Panel/LevelLabel
@onready var hp_label: Label = $Panel/HPLabel
@onready var hp_bar: Control = $Panel/HPBar
@onready var hp_fill: ColorRect = $Panel/HPBar/Fill
@onready var hp_frame: Panel = $Panel/HPBar/Frame
@onready var mp_label: Label = $Panel/MPLabel
@onready var mp_bar: Control = $Panel/MPBar
@onready var mp_fill: ColorRect = $Panel/MPBar/Fill
@onready var mp_frame: Panel = $Panel/MPBar/Frame
@onready var gold_label: Label = $Panel/GoldLabel
@onready var page_label: Label = $Panel/PageLabel
@onready var reward_label: Label = $Panel/RewardLabel

var _reward_toast_version: int = 0

func _ready() -> void:
    _load_pixel_assets()
    PixelUIStyle.apply_asset_panel_shell(panel)
    PixelUIStyle.apply_label(level_label, 18)
    PixelUIStyle.apply_label(hp_label, 16)
    PixelUIStyle.apply_label(mp_label, 16)
    PixelUIStyle.apply_label(gold_label, 18, Color(0.96, 0.82, 0.36, 1.0))
    PixelUIStyle.apply_label(page_label, 18)
    PixelUIStyle.apply_label(reward_label, 18, Color(0.96, 0.82, 0.36, 1.0))
    reward_label.visible = false
    PixelUIStyle.apply_bar_frame(hp_frame)
    PixelUIStyle.apply_bar_frame(mp_frame)
    QuestManager.book_pages_changed.connect(_on_book_pages_changed)
    QuestManager.branch_completed.connect(_on_branch_completed)
    PlayerData.stats_changed.connect(_sync_player_status)
    _on_book_pages_changed(QuestManager.get_book_page_count(), QuestManager.REQUIRED_BOOK_PAGES)
    _sync_player_status()

func _load_pixel_assets() -> void:
    frame_texture.texture = _load_runtime_texture(UI_FRAME_PATH)
    frame_texture.modulate = Color(0.32, 0.38, 0.27, 0.98)
    avatar_icon.texture = _load_runtime_texture(AVATAR_PATH)
    gold_icon.texture = _load_runtime_texture(GOLD_ICON_PATH)
    page_icon.texture = _load_runtime_texture(PAGE_ICON_PATH)

func _on_book_pages_changed(count: int, total: int) -> void:
    page_label.text = "书页：%d/%d" % [count, total]

func _on_branch_completed(branch_id: String) -> void:
    reward_label.text = _reward_text(branch_id)
    reward_label.visible = not reward_label.text.is_empty()
    _reward_toast_version += 1
    var toast_version := _reward_toast_version
    get_tree().create_timer(REWARD_TOAST_SECONDS).timeout.connect(_hide_reward_toast.bind(toast_version))

func _sync_player_status() -> void:
    level_label.text = "Lv.%d" % PlayerData.level
    hp_label.text = "HP %d/%d" % [PlayerData.hp, PlayerData.max_hp]
    _set_bar_fill(hp_bar, hp_fill, PlayerData.hp, PlayerData.max_hp)
    mp_label.text = "MP %d/%d" % [PlayerData.mp, PlayerData.max_mp]
    _set_bar_fill(mp_bar, mp_fill, PlayerData.mp, PlayerData.max_mp)
    gold_label.text = "金币：%d" % PlayerData.gold

func _reward_text(branch_id: String) -> String:
    var rewards := QuestManager.get_branch_reward_results(branch_id)
    var parts: Array[String] = []
    for reward in rewards:
        var reward_data := Dictionary(reward)
        var item_name := String(reward_data.get("item_name", reward_data.get("item_id", "")))
        var added := int(reward_data.get("added", 0))
        var remaining := int(reward_data.get("remaining", 0))
        if item_name.is_empty():
            continue
        if added > 0:
            parts.append("%s%s" % [item_name, " x%d" % added if added > 1 else ""])
        elif remaining > 0:
            parts.append("%s未放入背包" % item_name)

    if not parts.is_empty():
        return "获得：" + "、".join(parts)
    match branch_id:
        "library":
            return "已找回书页"
        "blacksmith":
            return "已完成铁匠训练"
        "garden":
            return "已完成药草任务"
    return ""

func _hide_reward_toast(toast_version: int) -> void:
    if toast_version == _reward_toast_version:
        reward_label.visible = false

func _set_bar_fill(bar: Control, fill: ColorRect, current: int, maximum: int) -> void:
    var ratio: float = clamp(float(current) / float(max(maximum, 1)), 0.0, 1.0)
    fill.position = Vector2(5, 5)
    fill.size = Vector2(max((bar.size.x - 10.0) * ratio, 0.0), max(bar.size.y - 10.0, 1.0))

func _load_runtime_texture(path: String) -> Texture2D:
    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    if error != OK:
        return null

    return ImageTexture.create_from_image(image)
