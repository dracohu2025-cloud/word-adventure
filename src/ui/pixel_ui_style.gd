extends RefCounted
class_name PixelUIStyle

const PANEL_BG: Color = Color(0.10, 0.12, 0.10, 0.92)
const COMBAT_PANEL_BG: Color = Color(0.07, 0.09, 0.06, 0.99)
const PANEL_BORDER: Color = Color(0.82, 0.66, 0.38, 1.0)
const PANEL_SHADOW: Color = Color(0.04, 0.05, 0.04, 1.0)
const BUTTON_BG: Color = Color(0.22, 0.28, 0.20, 1.0)
const BUTTON_HOVER: Color = Color(0.32, 0.40, 0.24, 1.0)
const BUTTON_PRESSED: Color = Color(0.13, 0.17, 0.12, 1.0)
const TEXT_COLOR: Color = Color(0.96, 0.92, 0.82, 1.0)
const MUTED_TEXT_COLOR: Color = Color(0.82, 0.76, 0.64, 1.0)
const BAR_BG: Color = Color(0.04, 0.05, 0.04, 0.95)
const SLOT_BG: Color = Color(0.09, 0.11, 0.08, 0.96)
const SLOT_EMPTY_BG: Color = Color(0.06, 0.07, 0.05, 0.92)
const SLOT_HOVER_BG: Color = Color(0.16, 0.20, 0.13, 0.98)
const SLOT_SELECTED_BG: Color = Color(0.22, 0.25, 0.15, 1.0)
const SLOT_LOCKED_BG: Color = Color(0.04, 0.04, 0.04, 0.84)
const TOOLTIP_BG: Color = Color(0.06, 0.07, 0.05, 0.98)

static func apply_panel(panel: Control) -> void:
    panel.add_theme_stylebox_override("panel", _make_box(PANEL_BG, PANEL_BORDER, 6, 8))

static func apply_asset_panel_shell(panel: Control) -> void:
    panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

static func apply_combat_panel(panel: Control) -> void:
    panel.add_theme_stylebox_override("panel", _make_box(COMBAT_PANEL_BG, PANEL_BORDER, 6, 8))

static func apply_button(button: Button) -> void:
    button.add_theme_stylebox_override("normal", _make_box(BUTTON_BG, PANEL_BORDER, 3, 8))
    button.add_theme_stylebox_override("hover", _make_box(BUTTON_HOVER, PANEL_BORDER, 3, 8))
    button.add_theme_stylebox_override("pressed", _make_box(BUTTON_PRESSED, PANEL_SHADOW, 3, 8))
    button.add_theme_color_override("font_color", TEXT_COLOR)
    button.add_theme_color_override("font_hover_color", TEXT_COLOR)
    button.add_theme_color_override("font_pressed_color", TEXT_COLOR)
    button.add_theme_font_size_override("font_size", 22)

static func apply_filter_button(button: Button) -> void:
    var inactive_border := Color(0.20, 0.23, 0.16, 1.0)
    var active_bg := Color(0.30, 0.38, 0.22, 1.0)
    var active_text := Color(1.00, 0.88, 0.42, 1.0)
    button.add_theme_stylebox_override("normal", _make_box(BUTTON_BG, inactive_border, 3, 8))
    button.add_theme_stylebox_override("hover", _make_box(BUTTON_HOVER, PANEL_BORDER, 3, 8))
    button.add_theme_stylebox_override("pressed", _make_box(active_bg, PANEL_BORDER, 4, 8))
    button.add_theme_stylebox_override("hover_pressed", _make_box(active_bg, PANEL_BORDER, 4, 8))
    button.add_theme_color_override("font_color", TEXT_COLOR)
    button.add_theme_color_override("font_hover_color", TEXT_COLOR)
    button.add_theme_color_override("font_pressed_color", active_text)
    button.add_theme_font_size_override("font_size", 22)

static func apply_line_edit(line_edit: LineEdit) -> void:
    line_edit.add_theme_stylebox_override("normal", _make_box(Color(0.07, 0.08, 0.07, 0.98), PANEL_BORDER, 4, 8))
    line_edit.add_theme_stylebox_override("focus", _make_box(Color(0.11, 0.14, 0.10, 0.98), Color(0.96, 0.82, 0.36, 1.0), 4, 8))
    line_edit.add_theme_color_override("font_color", TEXT_COLOR)
    line_edit.add_theme_color_override("font_placeholder_color", MUTED_TEXT_COLOR)
    line_edit.add_theme_font_size_override("font_size", 22)

static func apply_bar_frame(panel: Panel) -> void:
    panel.add_theme_stylebox_override("panel", _make_box(BAR_BG, PANEL_BORDER, 3, 0))

static func apply_item_slot(panel: Panel, border: Color, locked: bool, selected: bool, hovered: bool) -> void:
    var bg := SLOT_BG
    if locked:
        bg = SLOT_LOCKED_BG
    elif selected:
        bg = SLOT_SELECTED_BG
    elif hovered:
        bg = SLOT_HOVER_BG
    elif border.is_equal_approx(Color.TRANSPARENT):
        bg = SLOT_EMPTY_BG

    var border_color := border
    if border_color.is_equal_approx(Color.TRANSPARENT):
        border_color = Color(0.34, 0.29, 0.19, 1.0)
    panel.add_theme_stylebox_override("panel", _make_box(bg, border_color, 3, 3))

static func apply_tooltip_panel(panel: Panel) -> void:
    panel.add_theme_stylebox_override("panel", _make_box(TOOLTIP_BG, PANEL_BORDER, 4, 12))

static func apply_label(label: Label, font_size: int, color: Color = TEXT_COLOR) -> void:
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)

static func _make_box(bg: Color, border: Color, border_width: int, content_margin: int) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = bg
    box.border_color = border
    box.border_width_left = border_width
    box.border_width_top = border_width
    box.border_width_right = border_width
    box.border_width_bottom = border_width
    box.corner_radius_top_left = 0
    box.corner_radius_top_right = 0
    box.corner_radius_bottom_right = 0
    box.corner_radius_bottom_left = 0
    box.content_margin_left = content_margin
    box.content_margin_top = content_margin
    box.content_margin_right = content_margin
    box.content_margin_bottom = content_margin
    return box
