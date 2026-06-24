extends Area2D

@export var target_scene_path: String = ""
@export var hint_key_text: String = "空格/E"
@export var action_text: String = "进入"

var _available: bool = false
var _player_near: bool = false

@onready var interaction_marker: CanvasItem = $InteractionMarker

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    GameManager.state_changed.connect(_on_game_state_changed)
    set_available(false)

func _input(event: InputEvent) -> void:
    if _available and _player_near and event.is_action_pressed("interact") and GameManager.is_world_active():
        start_interaction()

func set_available(value: bool) -> void:
    _available = value
    monitoring = value
    monitorable = value
    _sync_interaction_marker()

func is_available() -> bool:
    return _available

func get_target_scene_path() -> String:
    return target_scene_path

func start_interaction() -> void:
    if not _available or target_scene_path.is_empty():
        return

    ControlHints.hide_interaction_hint(self)
    GameManager.load_scene(target_scene_path)

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
    var can_interact := _available and _player_near and GameManager.is_world_active()
    interaction_marker.visible = false
    if can_interact:
        ControlHints.show_interaction_hint(self, hint_key_text, action_text)
    else:
        ControlHints.hide_interaction_hint(self)
