extends Panel
class_name ItemTooltip

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")

const TOOLTIP_WIDTH: float = 320.0
const SCREEN_MARGIN: float = 18.0

@onready var title_label: Label = $Margin/Content/TitleLabel
@onready var type_label: Label = $Margin/Content/TypeLabel
@onready var stats_label: Label = $Margin/Content/StatsLabel
@onready var description_label: Label = $Margin/Content/DescriptionLabel
@onready var action_label: Label = $Margin/Content/ActionLabel

var item_id: String = ""

func _ready() -> void:
    custom_minimum_size.x = TOOLTIP_WIDTH
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    PixelUIStyle.apply_tooltip_panel(self)
    PixelUIStyle.apply_label(title_label, 18)
    PixelUIStyle.apply_label(type_label, 14, PixelUIStyle.MUTED_TEXT_COLOR)
    PixelUIStyle.apply_label(stats_label, 14)
    PixelUIStyle.apply_label(description_label, 14, PixelUIStyle.MUTED_TEXT_COLOR)
    PixelUIStyle.apply_label(action_label, 13, Color(0.96, 0.82, 0.36, 1.0))
    visible = false

func set_item(new_item_id: String, action_hint: String = "") -> void:
    item_id = new_item_id
    var item := ItemDatabase.get_item(item_id)
    if item.is_empty():
        hide_tooltip()
        return

    var quality_id := int(item.get("quality", ItemDatabase.QUALITY_COMMON))
    title_label.text = String(item.get("name", item_id))
    title_label.add_theme_color_override("font_color", ItemDatabase.get_quality_color(quality_id))
    type_label.text = _build_type_line(item)
    stats_label.text = _build_stats_text(item)
    stats_label.visible = not stats_label.text.is_empty()
    description_label.text = String(item.get("description", ""))
    description_label.visible = not description_label.text.is_empty()
    action_label.text = action_hint
    action_label.visible = not action_hint.is_empty()
    visible = true

func show_item(new_item_id: String, screen_position: Vector2, action_hint: String = "") -> void:
    set_item(new_item_id, action_hint)
    if not visible:
        return

    await get_tree().process_frame
    _place_near(screen_position)

func hide_tooltip() -> void:
    visible = false
    item_id = ""

func _place_near(screen_position: Vector2) -> void:
    var viewport_size := get_viewport_rect().size
    var target := screen_position + Vector2(18, 18)
    target.x = clampf(target.x, SCREEN_MARGIN, viewport_size.x - size.x - SCREEN_MARGIN)
    target.y = clampf(target.y, SCREEN_MARGIN, viewport_size.y - size.y - SCREEN_MARGIN)
    global_position = target

func _build_type_line(item: Dictionary) -> String:
    var quality_name := ItemDatabase.get_quality_name(int(item.get("quality", ItemDatabase.QUALITY_COMMON)))
    if String(item.get("type", "")) == ItemDatabase.TYPE_EQUIPMENT:
        return "%s · %s" % [quality_name, String(item.get("equipment_type", "装备"))]
    if String(item.get("type", "")) == ItemDatabase.TYPE_CONSUMABLE:
        return "%s · 消耗品" % quality_name

    return quality_name

func _build_stats_text(item: Dictionary) -> String:
    var lines: Array[String] = []
    if item.has("weapon_damage_min"):
        lines.append("伤害 %d-%d  速度 %.1f" % [
            int(item.get("weapon_damage_min", 0)),
            int(item.get("weapon_damage_max", 0)),
            float(item.get("weapon_speed", 0.0)),
        ])
    if item.has("armor"):
        lines.append("护甲 +%d" % int(item.get("armor", 0)))

    var attributes := Dictionary(item.get("attributes", {}))
    for key in ["strength", "agility", "intellect", "stamina", "spirit"]:
        var value := int(attributes.get(key, 0))
        if value != 0:
            lines.append("%s %+d" % [_attribute_name(key), value])

    var effect := Dictionary(item.get("use_effect", {}))
    if effect.has("heal"):
        lines.append("使用：恢复 %d 点生命值" % int(effect.get("heal", 0)))

    return "\n".join(lines)

func _attribute_name(key: String) -> String:
    match key:
        "strength":
            return "力量"
        "agility":
            return "敏捷"
        "intellect":
            return "智力"
        "stamina":
            return "耐力"
        "spirit":
            return "精神"
    return key
