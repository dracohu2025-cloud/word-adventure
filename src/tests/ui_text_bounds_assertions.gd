extends RefCounted
class_name UITextBoundsAssertions

const DEFAULT_PADDING: float = 2.0

static func assert_label_inside_control(label: Label, container: Control, message: String, padding: float = DEFAULT_PADDING) -> void:
    var label_rect := Rect2(label.global_position, label.size)
    var container_rect := Rect2(container.global_position, container.size).grow(-padding)
    assert(container_rect.encloses(label_rect), message + " label rect should stay inside its container")

static func assert_label_text_fits(label: Label, message: String, padding: float = DEFAULT_PADDING) -> void:
    var available := label.size - Vector2(padding * 2.0, padding * 2.0)
    assert(available.x > 0.0 and available.y > 0.0, message + " label should have positive inner space")

    var font := label.get_theme_font("font")
    var font_size := label.get_theme_font_size("font_size")
    if font == null or font_size <= 0:
        return

    var text_size := font.get_multiline_string_size(
        label.text,
        label.horizontal_alignment,
        available.x,
        font_size,
        -1,
        TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
    )
    assert(text_size.x <= available.x + 1.0, message + " text width should fit inside label")
    assert(text_size.y <= available.y + 1.0, message + " text height should fit inside label")

static func assert_button_uses_safe_label(button: Button, label: Label, message: String) -> void:
    assert(button.text.is_empty(), message + " button should not render its own text")
    assert_label_text_fits(label, message)
    assert_label_inside_control(label, button, message, -8.0)

