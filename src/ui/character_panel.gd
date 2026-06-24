extends CanvasLayer

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")
const DraggablePanelControllerScript := preload("res://src/ui/draggable_panel_controller.gd")

const UI_FRAME_PATH: String = "res://assets/licensed/tiny_swords/ui/panels/Button_Disable_9Slides.png"
const AVATAR_PATH: String = "res://assets/licensed/tiny_swords/ui/avatars/Avatars_01.png"
const OPEN_SLOT_ORDER: Array[String] = [
    "head",
    "amulet",
    "chest",
    "hands",
    "weapon",
    "offhand",
    "legs",
    "feet",
]
const LOCKED_SLOT_ORDER: Array[String] = [
    "ring",
    "cloak",
    "trinket",
    "relic",
]
const SLOT_NODE_NAMES: Dictionary = {
    "head": "SlotHead",
    "amulet": "SlotAmulet",
    "chest": "SlotChest",
    "hands": "SlotHands",
    "weapon": "SlotWeapon",
    "offhand": "SlotOffhand",
    "legs": "SlotLegs",
    "feet": "SlotFeet",
    "ring": "SlotRing",
    "cloak": "SlotCloak",
    "trinket": "SlotTrinket",
    "relic": "SlotRelic",
}
const SLOT_LABELS: Dictionary = {
    "head": "头",
    "amulet": "护符",
    "chest": "胸",
    "hands": "手",
    "weapon": "主手",
    "offhand": "副手",
    "legs": "腿",
    "feet": "脚",
    "ring": "戒指",
    "cloak": "披风",
    "trinket": "饰品",
    "relic": "遗物",
}

@onready var panel: Panel = $Panel
@onready var frame_texture: NinePatchRect = $Panel/FrameTexture
@onready var close_button: Button = $Panel/CloseButton
@onready var title_label: Label = $Panel/TitleLabel
@onready var name_label: Label = $Panel/NameLabel
@onready var class_label: Label = $Panel/ClassLabel
@onready var avatar_icon: TextureRect = $Panel/AvatarIcon
@onready var attack_stats_label: Label = $Panel/AttackStatsLabel
@onready var defense_stats_label: Label = $Panel/DefenseStatsLabel
@onready var survival_stats_label: Label = $Panel/SurvivalStatsLabel
@onready var attribute_stats_label: Label = $Panel/AttributeStatsLabel
@onready var tooltip = $ItemTooltip

var _slot_index_to_name: Dictionary = {}
var _slot_name_to_index: Dictionary = {}
var _slot_name_to_node: Dictionary = {}
var _drag_controller = null

func _ready() -> void:
    visible = false
    _drag_controller = DraggablePanelControllerScript.new()
    _drag_controller.attach(panel)
    _load_pixel_assets()
    _apply_style()
    _bind_slots()
    close_button.pressed.connect(hide_panel)
    PlayerData.equipment_changed.connect(_refresh)
    PlayerData.stats_changed.connect(_refresh)
    GameManager.state_changed.connect(_on_game_state_changed)
    _refresh()

func toggle_panel() -> void:
    if visible:
        hide_panel()
    else:
        show_panel()

func show_panel() -> void:
    visible = true
    _refresh()

func hide_panel() -> void:
    visible = false
    tooltip.hide_tooltip()

func _load_pixel_assets() -> void:
    frame_texture.texture = _load_runtime_texture(UI_FRAME_PATH)
    frame_texture.modulate = Color(0.34, 0.40, 0.27, 0.98)
    avatar_icon.texture = _load_runtime_texture(AVATAR_PATH)

func _apply_style() -> void:
    PixelUIStyle.apply_asset_panel_shell(panel)
    PixelUIStyle.apply_button(close_button)
    PixelUIStyle.apply_label(title_label, 22, Color(0.96, 0.82, 0.36, 1.0))
    PixelUIStyle.apply_label(name_label, 19)
    PixelUIStyle.apply_label(class_label, 15, PixelUIStyle.MUTED_TEXT_COLOR)
    PixelUIStyle.apply_label(attack_stats_label, 15)
    PixelUIStyle.apply_label(defense_stats_label, 15)
    PixelUIStyle.apply_label(survival_stats_label, 15)
    PixelUIStyle.apply_label(attribute_stats_label, 15)

func _bind_slots() -> void:
    var index := 0
    for slot_name in OPEN_SLOT_ORDER:
        _bind_slot(slot_name, index, false)
        index += 1
    for slot_name in LOCKED_SLOT_ORDER:
        _bind_slot(slot_name, index, true)
        index += 1

func _bind_slot(slot_name: String, slot_index: int, is_locked: bool) -> void:
    var node_name := String(SLOT_NODE_NAMES.get(slot_name, ""))
    if node_name.is_empty():
        return
    var slot_node = panel.get_node(node_name)
    _slot_index_to_name[slot_index] = slot_name
    _slot_name_to_index[slot_name] = slot_index
    _slot_name_to_node[slot_name] = slot_node
    slot_node.configure(slot_index, {}, String(SLOT_LABELS.get(slot_name, slot_name)), is_locked)
    slot_node.left_clicked.connect(_on_slot_left_clicked)
    slot_node.right_clicked.connect(_on_slot_right_clicked)
    slot_node.hovered.connect(_on_slot_hovered)
    slot_node.unhovered.connect(_on_slot_unhovered)

func _refresh() -> void:
    name_label.text = PlayerData.player_name
    class_label.text = "Lv.%d  %s" % [PlayerData.level, _vocation_name(PlayerData.vocation)]

    for slot_name in OPEN_SLOT_ORDER:
        var slot_node = _slot_name_to_node.get(slot_name)
        if slot_node == null:
            continue
        var item_id := String(PlayerData.equipment.get(slot_name, ""))
        var entry := {"item_id": item_id, "quantity": 1} if not item_id.is_empty() else {}
        slot_node.configure(
            int(_slot_name_to_index.get(slot_name, -1)),
            entry,
            String(SLOT_LABELS.get(slot_name, slot_name)),
            false
        )

    for slot_name in LOCKED_SLOT_ORDER:
        var slot_node = _slot_name_to_node.get(slot_name)
        if slot_node != null:
            slot_node.configure(
                int(_slot_name_to_index.get(slot_name, -1)),
                {},
                String(SLOT_LABELS.get(slot_name, slot_name)),
                true
            )

    _refresh_stats()

func _refresh_stats() -> void:
    var combat_stats := PlayerData.get_combat_stats()
    var attributes := PlayerData.get_total_attributes()
    var equipment_bonus := PlayerData.get_equipment_stat_bonus()
    var armor := int(equipment_bonus.get("armor", 0))
    attack_stats_label.text = "攻击力 %d\n攻速 %.2f\n暴击 %.1f%%" % [
        int(combat_stats.get("attack_power", 0)),
        float(combat_stats.get("attack_speed", 0.0)),
        float(combat_stats.get("crit_chance", 0.0)) * 100.0,
    ]
    defense_stats_label.text = "护甲 %d\n防御 %d" % [
        armor,
        int(combat_stats.get("defense", 0)),
    ]
    survival_stats_label.text = "生命 %d/%d\n魔法 %d/%d" % [
        PlayerData.hp,
        int(combat_stats.get("max_hp", PlayerData.max_hp)),
        PlayerData.mp,
        int(combat_stats.get("max_mp", PlayerData.max_mp)),
    ]
    attribute_stats_label.text = "力量 %d  敏捷 %d\n耐力 %d  智力 %d\n精神 %d" % [
        int(attributes.get("strength", 0)),
        int(attributes.get("agility", 0)),
        int(attributes.get("stamina", 0)),
        int(attributes.get("intellect", 0)),
        int(attributes.get("spirit", 0)),
    ]

func _on_slot_left_clicked(slot_index: int) -> void:
    _show_tooltip_for_slot(slot_index)

func _on_slot_right_clicked(slot_index: int) -> void:
    var slot_name := String(_slot_index_to_name.get(slot_index, ""))
    if slot_name.is_empty() or not PlayerData.equipment.has(slot_name):
        return
    var result := PlayerData.unequip_slot(slot_name)
    if bool(result.get("success", false)):
        tooltip.hide_tooltip()
        _refresh()

func _on_slot_hovered(slot_index: int) -> void:
    _show_tooltip_for_slot(slot_index)

func _on_slot_unhovered(_slot_index: int) -> void:
    tooltip.hide_tooltip()

func _show_tooltip_for_slot(slot_index: int) -> void:
    var slot_name := String(_slot_index_to_name.get(slot_index, ""))
    var item_id := String(PlayerData.equipment.get(slot_name, ""))
    if item_id.is_empty():
        tooltip.hide_tooltip()
        return

    var slot_node = _slot_name_to_node.get(slot_name)
    if slot_node == null:
        return
    tooltip.show_item(item_id, slot_node.global_position + Vector2(slot_node.size.x, 0), "右键卸下")

func _on_game_state_changed(_state) -> void:
    if not GameManager.is_world_active():
        hide_panel()

func _vocation_name(vocation: String) -> String:
    match vocation:
        "warrior":
            return "战士"
    return vocation

func _load_runtime_texture(path: String) -> Texture2D:
    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    if error != OK:
        return null

    return ImageTexture.create_from_image(image)
