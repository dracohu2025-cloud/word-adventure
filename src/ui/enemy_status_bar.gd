extends Node2D

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var hp_label: Label = $Panel/HPLabel
@onready var hp_bar: ProgressBar = $Panel/HPBar

func _ready() -> void:
    PixelUIStyle.apply_panel(panel)
    PixelUIStyle.apply_label(name_label, 14)
    PixelUIStyle.apply_label(hp_label, 12)
    _apply_bar_style()
    hide_status()

func show_status(enemy_name: String, hp: int, max_hp: int) -> void:
    visible = true
    name_label.text = enemy_name
    update_hp(hp, max_hp)

func update_hp(hp: int, max_hp: int) -> void:
    hp_bar.max_value = max(max_hp, 1)
    hp_bar.value = clamp(hp, 0, max_hp)
    hp_label.text = "%d/%d" % [hp, max_hp]

func hide_status() -> void:
    visible = false

func _apply_bar_style() -> void:
    var background := StyleBoxFlat.new()
    background.bg_color = Color(0.05, 0.05, 0.05, 0.95)
    background.border_color = PixelUIStyle.PANEL_BORDER
    background.border_width_left = 1
    background.border_width_top = 1
    background.border_width_right = 1
    background.border_width_bottom = 1
    hp_bar.add_theme_stylebox_override("background", background)

    var fill := StyleBoxFlat.new()
    fill.bg_color = Color(0.70, 0.10, 0.10, 1.0)
    hp_bar.add_theme_stylebox_override("fill", fill)
