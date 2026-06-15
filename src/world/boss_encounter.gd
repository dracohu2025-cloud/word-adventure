extends Area2D

@export var boss_id: String = "word_imp"

var _available: bool = false
var _player_near: bool = false

@onready var interaction_marker: CanvasItem = $InteractionMarker

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
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

    set_available(false)
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
    interaction_marker.visible = _available and _player_near
