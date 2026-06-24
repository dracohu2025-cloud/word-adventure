extends Area2D

const DEFAULT_CACHE_TEXTURE_PATH: String = "res://assets/generated/tiny_swords_compatible/props/supply_chest_closed.png"
const DEFAULT_CACHE_ASSET_SOURCE: String = "generated_tiny_swords_compatible"

@export var item_id: String = "minor_healing_potion"
@export var item_quantity: int = 1
@export var gold_reward: int = 4

var _collected: bool = false
var _player_near: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_marker: CanvasItem = $InteractionMarker
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
    _setup_sprite()
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    GameManager.state_changed.connect(_on_game_state_changed)
    _sync_interaction_marker()

func _input(event: InputEvent) -> void:
    if not _collected and _player_near and event.is_action_pressed("interact") and GameManager.is_world_active():
        start_interaction()

func start_interaction() -> void:
    if _collected:
        return

    if gold_reward > 0:
        PlayerData.add_gold(gold_reward)
    if not item_id.is_empty():
        PlayerData.add_item(item_id, max(item_quantity, 1))
    AudioManager.play_sfx_path(AudioManager.SFX_QUEST_REWARD)
    _collected = true
    _apply_collected_state()
    ControlHints.hide_interaction_hint(self)
    _sync_interaction_marker()

func is_collected() -> bool:
    return _collected

func is_collectable_visible() -> bool:
    return sprite.visible

func get_collectable_texture_path() -> String:
    return DEFAULT_CACHE_TEXTURE_PATH

func get_collectable_asset_source() -> String:
    return DEFAULT_CACHE_ASSET_SOURCE

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

func _sync_interaction_marker() -> void:
    var can_interact := not _collected and _player_near and GameManager.is_world_active()
    interaction_marker.visible = false
    if can_interact:
        ControlHints.show_interaction_hint(self, "空格/E", "拾取")
    else:
        ControlHints.hide_interaction_hint(self)

func _apply_collected_state() -> void:
    sprite.visible = false
    interaction_marker.visible = false
    monitoring = false
    monitorable = false
    collision_shape.set_deferred("disabled", true)

func _setup_sprite() -> void:
    var imported_texture := load(DEFAULT_CACHE_TEXTURE_PATH)
    if imported_texture is Texture2D:
        sprite.texture = imported_texture
        sprite.set_meta("asset_source", DEFAULT_CACHE_ASSET_SOURCE)
        return

    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(DEFAULT_CACHE_TEXTURE_PATH))
    if error != OK:
        return

    sprite.texture = ImageTexture.create_from_image(image)
    sprite.set_meta("asset_source", DEFAULT_CACHE_ASSET_SOURCE)
