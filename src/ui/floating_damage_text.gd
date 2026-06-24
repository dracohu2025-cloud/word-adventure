extends Label

const LIFETIME: float = 0.7
const RISE_SPEED: float = 34.0

var _age: float = 0.0

func setup(amount: int, is_critical: bool, from_enemy: bool) -> void:
    text = str(amount)
    horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    add_theme_font_size_override("font_size", 24 if is_critical else 18)
    var color := Color(1.0, 0.18, 0.16, 1.0) if from_enemy else Color(1.0, 0.88, 0.28, 1.0)
    if is_critical:
        color = Color(1.0, 0.96, 0.42, 1.0)
        text = "暴击 " + text
    add_theme_color_override("font_color", color)
    custom_minimum_size = Vector2(96, 28)
    pivot_offset = custom_minimum_size * 0.5

func _process(delta: float) -> void:
    _age += delta
    position.y -= RISE_SPEED * delta
    modulate.a = max(1.0 - (_age / LIFETIME), 0.0)
    if _age >= LIFETIME:
        queue_free()
