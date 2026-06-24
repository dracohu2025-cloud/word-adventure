extends CharacterBody2D

const TINY_SWORDS_IDLE_PATH: String = "res://assets/licensed/tiny_swords/units/warrior/Warrior_Idle.png"
const TINY_SWORDS_RUN_PATH: String = "res://assets/licensed/tiny_swords/units/warrior/Warrior_Run.png"
const TINY_SWORDS_FPS: float = 10.0
const AUTO_WAYPOINT_DISTANCE: float = 0.75

@export var speed: float = 160.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var tiny_swords_sprite: AnimatedSprite2D = $TinySwordsSprite

var _auto_path: PackedVector2Array = PackedVector2Array()
var _auto_path_index: int = 0

func _ready() -> void:
    _setup_tiny_swords_animation()

func _physics_process(delta: float) -> void:
    if not GameManager.is_world_active():
        velocity = Vector2.ZERO
        clear_auto_path()
        _play_movement_animation(Vector2.ZERO)
        return

    var input := Vector2.ZERO
    input.x = Input.get_axis("move_left", "move_right")
    input.y = Input.get_axis("move_up", "move_down")

    if input.length() > 1.0:
        input = input.normalized()

    if input.length() > 0.0:
        clear_auto_path()
        velocity = input * speed
    else:
        velocity = _get_auto_path_velocity(delta)

    if velocity.x != 0:
        sprite.flip_h = velocity.x < 0
        tiny_swords_sprite.flip_h = velocity.x < 0

    _play_movement_animation(velocity)

    var previous_position := global_position
    move_and_slide()
    var village := get_parent()
    if village != null and not _can_stand_at(village, global_position):
        global_position = previous_position
        velocity = Vector2.ZERO
        clear_auto_path()

func follow_path(path: PackedVector2Array) -> void:
    _auto_path = path
    _auto_path_index = 0

func clear_auto_path() -> void:
    _auto_path.clear()
    _auto_path_index = 0

func is_following_auto_path() -> bool:
    return _auto_path_index < _auto_path.size()

func _get_auto_path_velocity(delta: float) -> Vector2:
    while _auto_path_index < _auto_path.size():
        var waypoint := _auto_path[_auto_path_index]
        var to_waypoint := waypoint - global_position
        if to_waypoint.length() > AUTO_WAYPOINT_DISTANCE:
            var max_distance := speed * delta
            if to_waypoint.length() <= max_distance and delta > 0.0:
                return to_waypoint / delta
            return to_waypoint.normalized() * speed
        _auto_path_index += 1

    clear_auto_path()
    return Vector2.ZERO

func _can_stand_at(village: Node, position: Vector2) -> bool:
    if village.has_method("can_player_stand_at_position"):
        return village.can_player_stand_at_position(position)
    if village.has_method("is_walkable_position"):
        return village.is_walkable_position(position)
    return true

func _setup_tiny_swords_animation() -> void:
    if not FileAccess.file_exists(TINY_SWORDS_IDLE_PATH) or not FileAccess.file_exists(TINY_SWORDS_RUN_PATH):
        tiny_swords_sprite.visible = false
        sprite.visible = true
        return

    var frames := SpriteFrames.new()
    _add_strip_animation(frames, "idle", TINY_SWORDS_IDLE_PATH, 8, true)
    _add_strip_animation(frames, "run", TINY_SWORDS_RUN_PATH, 6, true)
    tiny_swords_sprite.sprite_frames = frames
    tiny_swords_sprite.visible = true
    sprite.visible = false
    tiny_swords_sprite.play("idle")

func _add_strip_animation(frames: SpriteFrames, animation_name: StringName, path: String, frame_count: int, loop: bool) -> void:
    var texture := _load_runtime_texture(path)
    if texture == null:
        return

    var frame_size := Vector2(texture.get_height(), texture.get_height())
    frames.add_animation(animation_name)
    frames.set_animation_speed(animation_name, TINY_SWORDS_FPS)
    frames.set_animation_loop(animation_name, loop)

    for frame_index in range(frame_count):
        var frame := AtlasTexture.new()
        frame.atlas = texture
        frame.region = Rect2(Vector2(frame_index * frame_size.x, 0), frame_size)
        frames.add_frame(animation_name, frame)

func _load_runtime_texture(path: String) -> Texture2D:
    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    if error != OK:
        return null

    return ImageTexture.create_from_image(image)

func _play_movement_animation(input: Vector2) -> void:
    if not tiny_swords_sprite.visible or tiny_swords_sprite.sprite_frames == null:
        return

    var animation_name := "run" if input.length() > 0.0 else "idle"
    if tiny_swords_sprite.animation != animation_name:
        tiny_swords_sprite.play(animation_name)
