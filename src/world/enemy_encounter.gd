extends Area2D

const TINY_SWORDS_IDLE_PATH: String = "res://assets/licensed/tiny_swords/enemies/skull/Skull_Idle.png"
const TINY_SWORDS_FRAME_COUNT: int = 8
const TINY_SWORDS_FPS: float = 8.0

@export var enemy_id: String = "leaf_imp"
@export var enemy_name: String = "Leaf Imp"
@export var max_hp: int = 90
@export var attack_power: int = 10
@export var defense: int = 4
@export var attack_speed: float = 0.85
@export var gold_reward: int = 6
@export var experience_reward: int = 12
@export var loot_item_id: String = "minor_healing_potion"
@export var loot_quantity: int = 1
@export var loot_chance: float = 0.35

var _available: bool = true
var _player_near: bool = false
var _battle_started_by_self: bool = false

@onready var fallback_sprite: Sprite2D = $Sprite2D
@onready var tiny_swords_sprite: AnimatedSprite2D = $TinySwordsSprite
@onready var interaction_marker: CanvasItem = $InteractionMarker

func _ready() -> void:
    _setup_tiny_swords_animation()
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    GameManager.state_changed.connect(_on_game_state_changed)
    CombatManager.battle_finished.connect(_on_battle_finished)
    set_available(true)

func _input(event: InputEvent) -> void:
    if _available and _player_near and event.is_action_pressed("interact") and GameManager.is_world_active():
        start_interaction()

func set_available(value: bool) -> void:
    _available = value
    visible = value
    monitoring = value
    monitorable = value
    _sync_interaction_marker()

func is_available() -> bool:
    return _available

func start_interaction() -> void:
    if not _available:
        return

    ControlHints.hide_interaction_hint(self)
    _battle_started_by_self = true
    CombatManager.start_battle(_build_enemy_data())

func _build_enemy_data() -> Dictionary:
    var loot_table: Array[Dictionary] = []
    if not loot_item_id.is_empty():
        loot_table.append({
            "item_id": loot_item_id,
            "quantity": max(loot_quantity, 1),
            "chance": clampf(loot_chance, 0.0, 1.0),
        })

    return {
        "enemy_id": enemy_id,
        "enemy_name": enemy_name,
        "max_hp": max_hp,
        "attack_power": attack_power,
        "defense": defense,
        "attack_speed": attack_speed,
        "crit_chance": 0.04,
        "crit_multiplier": 1.5,
        "level": 1,
        "is_boss": false,
        "gold_reward": gold_reward,
        "experience_reward": experience_reward,
        "loot_table": loot_table,
        "sprite_path": TINY_SWORDS_IDLE_PATH,
    }

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_near = true
        _sync_interaction_marker()

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_near = false
        _sync_interaction_marker()

func _on_game_state_changed(_state) -> void:
    _sync_interaction_marker()

func _on_battle_finished(victory: bool) -> void:
    if not _battle_started_by_self:
        return

    _battle_started_by_self = false
    if victory:
        set_available(false)
    else:
        _sync_interaction_marker()

func _sync_interaction_marker() -> void:
    var can_interact := _available and _player_near and GameManager.is_world_active()
    interaction_marker.visible = false
    if can_interact:
        ControlHints.show_interaction_hint(self, "空格/E", "挑战")
    else:
        ControlHints.hide_interaction_hint(self)

func _setup_tiny_swords_animation() -> void:
    if not FileAccess.file_exists(TINY_SWORDS_IDLE_PATH):
        tiny_swords_sprite.visible = false
        fallback_sprite.visible = true
        return

    var texture := _load_runtime_texture(TINY_SWORDS_IDLE_PATH)
    if texture == null:
        tiny_swords_sprite.visible = false
        fallback_sprite.visible = true
        return

    var frames := SpriteFrames.new()
    frames.add_animation("idle")
    frames.set_animation_speed("idle", TINY_SWORDS_FPS)
    frames.set_animation_loop("idle", true)

    var frame_size := Vector2(texture.get_height(), texture.get_height())
    for frame_index in range(TINY_SWORDS_FRAME_COUNT):
        var frame := AtlasTexture.new()
        frame.atlas = texture
        frame.region = Rect2(Vector2(frame_index * frame_size.x, 0), frame_size)
        frames.add_frame("idle", frame)

    tiny_swords_sprite.sprite_frames = frames
    tiny_swords_sprite.visible = true
    fallback_sprite.visible = false
    tiny_swords_sprite.play("idle")

func _load_runtime_texture(path: String) -> Texture2D:
    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    if error != OK:
        return null

    return ImageTexture.create_from_image(image)
