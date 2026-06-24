extends Area2D

const TINY_SWORDS_IDLE_PATH: String = "res://assets/licensed/tiny_swords/enemies/skull/Skull_Idle.png"
const TINY_SWORDS_FRAME_COUNT: int = 8
const TINY_SWORDS_FPS: float = 8.0
const DAMAGE_TEXT_SCENE := preload("res://scenes/ui/floating_damage_text.tscn")

@export var boss_id: String = "word_imp"

var _available: bool = false
var _player_near: bool = false

@onready var fallback_sprite: Sprite2D = $Sprite2D
@onready var tiny_swords_sprite: AnimatedSprite2D = $TinySwordsSprite
@onready var enemy_status_bar = $EnemyStatusBar
@onready var damage_text_layer: Node2D = $DamageTextLayer
@onready var interaction_marker: CanvasItem = $InteractionMarker

func _ready() -> void:
    _setup_tiny_swords_animation()
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    GameManager.state_changed.connect(_on_game_state_changed)
    CombatManager.battle_started.connect(_on_battle_started)
    CombatManager.combatant_changed.connect(_on_combatant_changed)
    CombatManager.damage_dealt.connect(_on_damage_dealt)
    CombatManager.battle_finished.connect(_on_battle_finished)
    set_available(false)

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
    _available = false
    monitoring = false
    monitorable = false
    _sync_interaction_marker()
    CombatManager.start_boss_battle(boss_id)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_near = true
        _sync_interaction_marker()

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_near = false
        _sync_interaction_marker()

func _sync_interaction_marker() -> void:
    var can_interact := _available and _player_near and GameManager.is_world_active()
    interaction_marker.visible = false
    if can_interact:
        ControlHints.show_interaction_hint(self, "空格/E", "挑战")
    else:
        ControlHints.hide_interaction_hint(self)

func _on_game_state_changed(_state) -> void:
    _sync_interaction_marker()

func _on_battle_started(enemy_data: Dictionary) -> void:
    if String(enemy_data.get("enemy_id", "")) != boss_id:
        return

    visible = true
    enemy_status_bar.hide_status()

func _on_combatant_changed() -> void:
    var enemy_data := CombatManager.get_enemy_data()
    if String(enemy_data.get("enemy_id", "")) != boss_id:
        return

    enemy_status_bar.hide_status()

func _on_damage_dealt(event: Dictionary) -> void:
    var damage_text = DAMAGE_TEXT_SCENE.instantiate()
    var target := String(event.get("target", ""))
    var from_enemy := String(event.get("source", "")) == CombatManager.COMBATANT_ENEMY
    damage_text.position = Vector2(18, -124) if target == CombatManager.COMBATANT_ENEMY else Vector2(-44, -18)
    damage_text.setup(
        int(event.get("amount", 0)),
        bool(event.get("is_critical", false)),
        from_enemy
    )
    damage_text_layer.add_child(damage_text)
    if target == CombatManager.COMBATANT_ENEMY:
        _flash_on_hit()

func _on_battle_finished(_victory: bool) -> void:
    enemy_status_bar.hide_status()

func _flash_on_hit() -> void:
    modulate = Color(1.0, 0.72, 0.72, 1.0)
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color.WHITE, 0.12)

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
