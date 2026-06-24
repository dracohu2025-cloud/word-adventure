extends Area2D

const TINY_SWORDS_DEFAULT_PATH: String = "res://assets/licensed/tiny_swords/units/pawn/Pawn_Idle.png"
const TINY_SWORDS_FPS: float = 8.0

@export var npc_name: String = "Villager"
@export var quest_id: String = ""
@export var challenge_type: String = "meaning"
@export var dialogue_lines: Array[String] = []
@export var puzzle_word: String = ""
@export var puzzle_question: String = ""
@export var puzzle_options: Array[String] = []
@export var puzzle_answer: String = ""
@export var success_line: String = "Correct! The path is open."
@export var failure_line: String = "Not quite. Try again when you're ready."
@export var tiny_swords_idle_path: String = TINY_SWORDS_DEFAULT_PATH
@export var tiny_swords_frame_count: int = 8

var _player_near: bool = false
var _interaction_active: bool = false
var _waiting_for_puzzle_result: bool = false
var _dialogue_completed: bool = false

@onready var fallback_sprite: Sprite2D = $Sprite2D
@onready var tiny_swords_sprite: AnimatedSprite2D = $TinySwordsSprite
@onready var interaction_marker: CanvasItem = $InteractionMarker

func _ready() -> void:
    _setup_tiny_swords_animation()
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
    DialogueManager.puzzle_solved.connect(_on_puzzle_solved)
    GameManager.state_changed.connect(_on_game_state_changed)
    _sync_interaction_marker()

func _input(event: InputEvent) -> void:
    if _player_near and event.is_action_pressed("interact") and GameManager.is_world_active():
        start_interaction()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_near = true
        _sync_interaction_marker()

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_near = false
        _sync_interaction_marker()

func start_interaction() -> void:
    if not is_available():
        return
    if dialogue_lines.is_empty():
        return

    ControlHints.hide_interaction_hint(self)
    var puzzle_data: Dictionary = {}
    _interaction_active = true
    _waiting_for_puzzle_result = not puzzle_word.is_empty()

    if not puzzle_word.is_empty():
        puzzle_data = _build_puzzle_data()

    DialogueManager.start_dialogue(dialogue_lines, puzzle_data, self)

func is_dialogue_completed() -> bool:
    return _dialogue_completed or (not quest_id.is_empty() and QuestManager.is_branch_completed(quest_id))

func is_available() -> bool:
    return not is_dialogue_completed()

func _on_dialogue_finished() -> void:
    if not _interaction_active or _waiting_for_puzzle_result:
        return

    _mark_dialogue_completed()
    _interaction_active = false

func _on_puzzle_solved(correct: bool) -> void:
    if not _interaction_active or not _waiting_for_puzzle_result:
        return

    if correct:
        if not quest_id.is_empty():
            QuestManager.complete_branch(quest_id)
        _mark_dialogue_completed()

    _waiting_for_puzzle_result = false
    _interaction_active = false

func _mark_dialogue_completed() -> void:
    _dialogue_completed = true
    _sync_interaction_marker()

func _sync_interaction_marker() -> void:
    var can_interact := _player_near and not is_dialogue_completed() and GameManager.is_world_active()
    interaction_marker.visible = false
    if can_interact:
        ControlHints.show_interaction_hint(self, "空格/E", "交谈")
    else:
        ControlHints.hide_interaction_hint(self)

func _on_game_state_changed(_state) -> void:
    _sync_interaction_marker()

func _build_puzzle_data() -> Dictionary:
    var data := WordBank.build_challenge(puzzle_word, challenge_type)
    if data.is_empty():
        data = {
            "challenge_type": challenge_type,
            "word": puzzle_word,
            "question": puzzle_question,
            "options": puzzle_options,
            "answer": puzzle_answer,
        }

    data["quest_id"] = quest_id
    data["success_line"] = success_line
    data["failure_line"] = failure_line
    return data

func _setup_tiny_swords_animation() -> void:
    if not FileAccess.file_exists(tiny_swords_idle_path):
        tiny_swords_sprite.visible = false
        fallback_sprite.visible = true
        return

    var texture := _load_runtime_texture(tiny_swords_idle_path)
    if texture == null:
        tiny_swords_sprite.visible = false
        fallback_sprite.visible = true
        return

    var frames := SpriteFrames.new()
    frames.add_animation("idle")
    frames.set_animation_speed("idle", TINY_SWORDS_FPS)
    frames.set_animation_loop("idle", true)

    var frame_size := Vector2(texture.get_height(), texture.get_height())
    for frame_index in range(tiny_swords_frame_count):
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
