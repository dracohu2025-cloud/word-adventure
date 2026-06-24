extends Node2D

const VILLAGE_BGM_PATH: String = "res://assets/audio/bgm/village_theme_draft_01.mp3"
const WALKABLE_RECTS: Array[Rect2] = [
    Rect2(Vector2(-600, 78), Vector2(1200, 36)),
    Rect2(Vector2(-522, 48), Vector2(36, 48)),
    Rect2(Vector2(-282, 48), Vector2(36, 48)),
    Rect2(Vector2(222, 48), Vector2(36, 48)),
    Rect2(Vector2(462, -72), Vector2(36, 168)),
    Rect2(Vector2(498, -18), Vector2(54, 36)),
]
const PLAYER_GROUND_HALF_EXTENTS: Vector2 = Vector2(10, 10)
const PATH_GRID_STEP: int = 8
const PATH_POINT_MARGIN: float = 4.0
const CLICK_SNAP_RADIUS: float = 1200.0

@onready var exit_gate: StaticBody2D = $ExitGate
@onready var exit_collision: CollisionShape2D = $ExitGate/CollisionShape2D
@onready var chapter_exit: Area2D = $ChapterExit
@onready var word_imp_boss = $WordImpBoss
@onready var character_panel = $CharacterPanel
@onready var inventory_panel = $InventoryPanel
@onready var player: CharacterBody2D = $Player

var _pathfinder := AStar2D.new()
var _path_point_ids: Dictionary = {}

func _ready() -> void:
    GameManager.change_state(GameManager.GameState.WORLD)
    AudioManager.play_music_path(VILLAGE_BGM_PATH)
    QuestManager.forest_gate_ready.connect(_on_forest_gate_ready)
    CombatManager.battle_finished.connect(_on_battle_finished)
    word_imp_boss.set_available(QuestManager.is_forest_gate_ready() and not QuestManager.is_boss_defeated())
    chapter_exit.set_available(false)
    if QuestManager.is_boss_defeated():
        word_imp_boss.set_available(false)
        open_exit()
    _build_pathfinder()

func _on_forest_gate_ready() -> void:
    print("Forest gate is ready for the Word Imp encounter.")
    if not QuestManager.is_boss_defeated():
        word_imp_boss.set_available(true)

func _on_battle_finished(victory: bool) -> void:
    if victory and QuestManager.is_boss_defeated():
        word_imp_boss.set_available(false)
        open_exit()
    elif QuestManager.is_forest_gate_ready():
        word_imp_boss.set_available(true)

func _input(event: InputEvent) -> void:
    _handle_world_click(event)

func _unhandled_input(event: InputEvent) -> void:
    if _is_panel_toggle_action(event) and GameManager.is_world_active():
        _toggle_player_panels()
        get_viewport().set_input_as_handled()
    else:
        _handle_world_click(event)

func _is_panel_toggle_action(event: InputEvent) -> bool:
    if event is InputEventAction:
        return event.pressed and event.action in [
            "toggle_player_panels",
            "toggle_character",
            "toggle_inventory",
        ]

    return event.is_action_pressed("toggle_player_panels")

func _toggle_player_panels() -> void:
    if character_panel.visible or inventory_panel.visible:
        character_panel.hide_panel()
        inventory_panel.hide_panel()
        return

    character_panel.show_panel()
    inventory_panel.show_panel()

func open_exit() -> void:
    exit_collision.set_deferred("disabled", true)
    exit_gate.modulate = Color(1, 1, 1, 0.3)
    chapter_exit.set_available(true)
    print("Exit gate opened!")

func is_walkable_position(world_position: Vector2) -> bool:
    for rect in WALKABLE_RECTS:
        if _rect_contains_position(rect, world_position):
            return true
    return false

func can_player_stand_at_position(world_position: Vector2) -> bool:
    var corners := [
        world_position + Vector2(-PLAYER_GROUND_HALF_EXTENTS.x, -PLAYER_GROUND_HALF_EXTENTS.y),
        world_position + Vector2(PLAYER_GROUND_HALF_EXTENTS.x, -PLAYER_GROUND_HALF_EXTENTS.y),
        world_position + Vector2(-PLAYER_GROUND_HALF_EXTENTS.x, PLAYER_GROUND_HALF_EXTENTS.y),
        world_position + Vector2(PLAYER_GROUND_HALF_EXTENTS.x, PLAYER_GROUND_HALF_EXTENTS.y),
    ]

    for corner in corners:
        if not is_walkable_position(corner):
            return false
    return true

func request_player_move_to(world_position: Vector2) -> bool:
    if player == null or not player.has_method("follow_path"):
        return false

    var path := build_player_path(player.global_position, world_position)
    if path.is_empty():
        if player.has_method("clear_auto_path"):
            player.clear_auto_path()
        return false

    player.follow_path(path)
    return true

func build_player_path(start_position: Vector2, target_position: Vector2) -> PackedVector2Array:
    var snapped_target := _resolve_click_target(target_position)
    if not _is_safe_path_point(snapped_target):
        return PackedVector2Array()
    if not can_player_stand_at_position(start_position):
        return PackedVector2Array()
    if _segment_is_standable(start_position, snapped_target):
        return PackedVector2Array([snapped_target])
    if _pathfinder.get_point_count() == 0:
        return PackedVector2Array()

    var start_id := _pathfinder.get_closest_point(start_position)
    var target_id := _pathfinder.get_closest_point(snapped_target)
    if start_id < 0 or target_id < 0:
        return PackedVector2Array()

    var grid_path := _pathfinder.get_point_path(start_id, target_id)
    if grid_path.is_empty():
        return PackedVector2Array()

    var path := PackedVector2Array()
    for point in grid_path:
        path.append(point)
    path.append(snapped_target)
    return _compact_path(path)

func _is_world_click(event: InputEvent) -> bool:
    if not GameManager.is_world_active():
        return false
    if character_panel.visible or inventory_panel.visible:
        return false
    if event is InputEventMouseButton:
        if ControlHints.contains_screen_point(event.position):
            return false
        return event.button_index == MOUSE_BUTTON_LEFT and event.pressed
    return false

func _handle_world_click(event: InputEvent) -> bool:
    if not _is_world_click(event):
        return false

    var mouse_event: InputEventMouseButton = event
    var world_position := _screen_to_world_position(mouse_event.position)
    if not request_player_move_to(world_position):
        return false

    get_viewport().set_input_as_handled()
    return true

func _screen_to_world_position(screen_position: Vector2) -> Vector2:
    return get_viewport().get_canvas_transform().affine_inverse() * screen_position

func _build_pathfinder() -> void:
    _pathfinder.clear()
    _path_point_ids.clear()
    var bounds := _walkable_bounds()
    var start_x := int(floor(bounds.position.x / PATH_GRID_STEP)) * PATH_GRID_STEP
    var end_x := int(ceil((bounds.position.x + bounds.size.x) / PATH_GRID_STEP)) * PATH_GRID_STEP
    var start_y := int(floor(bounds.position.y / PATH_GRID_STEP)) * PATH_GRID_STEP
    var end_y := int(ceil((bounds.position.y + bounds.size.y) / PATH_GRID_STEP)) * PATH_GRID_STEP
    var next_id := 1

    for x in range(start_x, end_x + PATH_GRID_STEP, PATH_GRID_STEP):
        for y in range(start_y, end_y + PATH_GRID_STEP, PATH_GRID_STEP):
            var point := Vector2(x, y)
            if not _is_safe_path_point(point):
                continue
            _pathfinder.add_point(next_id, point)
            _path_point_ids[_path_key(point)] = next_id
            next_id += 1

    for key in _path_point_ids.keys():
        var id := int(_path_point_ids[key])
        var point := _pathfinder.get_point_position(id)
        for offset in [Vector2(PATH_GRID_STEP, 0), Vector2(0, PATH_GRID_STEP)]:
            var neighbor_id := int(_path_point_ids.get(_path_key(point + offset), -1))
            if neighbor_id >= 0 and not _pathfinder.are_points_connected(id, neighbor_id):
                _pathfinder.connect_points(id, neighbor_id)

func _resolve_click_target(target_position: Vector2) -> Vector2:
    if _is_safe_path_point(target_position):
        return target_position

    if _pathfinder.get_point_count() == 0:
        return target_position

    var closest_id := _pathfinder.get_closest_point(target_position)
    if closest_id < 0:
        return target_position

    var closest_position := _pathfinder.get_point_position(closest_id)
    if target_position.distance_to(closest_position) <= CLICK_SNAP_RADIUS:
        return closest_position

    return target_position

func _is_safe_path_point(world_position: Vector2) -> bool:
    for offset in [
        Vector2.ZERO,
        Vector2(-PATH_POINT_MARGIN, 0),
        Vector2(PATH_POINT_MARGIN, 0),
        Vector2(0, -PATH_POINT_MARGIN),
        Vector2(0, PATH_POINT_MARGIN),
    ]:
        if not can_player_stand_at_position(world_position + offset):
            return false
    return true

func _segment_is_standable(start_position: Vector2, target_position: Vector2) -> bool:
    var distance := start_position.distance_to(target_position)
    var sample_count = max(int(ceil(distance / float(PATH_GRID_STEP))), 1)
    for index in range(sample_count + 1):
        var ratio := float(index) / float(sample_count)
        if not can_player_stand_at_position(start_position.lerp(target_position, ratio)):
            return false
    return true

func _compact_path(path: PackedVector2Array) -> PackedVector2Array:
    if path.size() <= 2:
        return path

    var compacted := PackedVector2Array()
    compacted.append(path[0])
    var previous_direction := Vector2.ZERO
    for index in range(1, path.size()):
        var direction := (path[index] - path[index - 1]).sign()
        if direction == Vector2.ZERO:
            continue
        if previous_direction != Vector2.ZERO and direction != previous_direction:
            compacted.append(path[index - 1])
        previous_direction = direction

    if compacted[compacted.size() - 1] != path[path.size() - 1]:
        compacted.append(path[path.size() - 1])

    return compacted

func _walkable_bounds() -> Rect2:
    var bounds := WALKABLE_RECTS[0]
    for rect in WALKABLE_RECTS:
        bounds = bounds.merge(rect)
    return bounds

func _path_key(position: Vector2) -> String:
    return "%d:%d" % [int(round(position.x)), int(round(position.y))]

func _rect_contains_position(rect: Rect2, position: Vector2) -> bool:
    var end := rect.position + rect.size
    return (
        position.x >= rect.position.x
        and position.x <= end.x
        and position.y >= rect.position.y
        and position.y <= end.y
    )
