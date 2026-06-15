extends Node2D

const TILE_SIZE: int = 16
const TILE_SCALE: float = 3.0
const WORLD_TILE: int = int(TILE_SIZE * TILE_SCALE)
const TILE_PATH: String = "res://assets/third_party/kenney_tiny_town/Tiles/tile_%04d.png"
const DUNGEON_TILE_PATH: String = "res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_%04d.png"

var _textures: Dictionary = {}
var _dungeon_textures: Dictionary = {}

@onready var ground: Node2D = $Ground
@onready var main_road: Node2D = $MainRoad
@onready var exit_road: Node2D = $ExitRoad
@onready var houses: Node2D = $Houses
@onready var trees: Node2D = $Trees
@onready var stones: Node2D = $Stones
@onready var signpost: Node2D = $Signpost
@onready var branch_anchors: Node2D = $BranchAnchors
@onready var gate_visual: Node2D = $"../ExitGate/GateVisual"

func _ready() -> void:
    _load_textures()
    _build_ground()
    _build_roads()
    _build_houses()
    _build_trees()
    _build_stones()
    _build_branch_anchors()
    _build_signpost()
    _build_gate()

func _load_textures() -> void:
    var ids := [
        0, 1, 2, 3, 4, 16, 17, 25, 28, 29, 44, 45, 46, 47,
        48, 49, 50, 52, 53, 54, 60, 61, 62, 63, 64, 65, 66, 67,
        68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 83, 84,
        85, 86, 87, 88, 89, 90, 91, 92, 104, 105, 106, 107, 115, 130, 131
    ]

    for id in ids:
        _textures[id] = load(TILE_PATH % id)

    var dungeon_ids := [
        63, 72, 75, 101, 102, 103, 104, 113, 114, 115, 116, 129, 130, 131
    ]

    for id in dungeon_ids:
        _dungeon_textures[id] = load(DUNGEON_TILE_PATH % id)

func _build_ground() -> void:
    for x in range(-13, 14):
        for y in range(-7, 8):
            var tile_id := 0
            if (x + y) % 7 == 0:
                tile_id = 1
            if (x * 3 + y) % 23 == 0:
                tile_id = 2
            _add_tile(ground, tile_id, Vector2(x * WORLD_TILE, y * WORLD_TILE))

func _build_roads() -> void:
    for x in range(-12, 13):
        _add_tile(main_road, 25, Vector2(x * WORLD_TILE, 96))

    var branch_points := [
        Vector2(-240, 48), Vector2(-192, 48), Vector2(-144, 48),
        Vector2(-96, 48), Vector2(-48, 48), Vector2(0, 48),
        Vector2(48, 48), Vector2(96, 48), Vector2(144, 48),
        Vector2(192, 48), Vector2(240, 48), Vector2(288, 48),
        Vector2(336, 48), Vector2(384, 48), Vector2(432, 48),
        Vector2(480, 48), Vector2(528, 48)
    ]

    for point in branch_points:
        _add_tile(exit_road, 25, point)

func _build_houses() -> void:
    _add_tile_group(houses, [
        [48, 49, 50],
        [60, 63, 62],
        [72, 73, 75],
    ], Vector2(-552, -72))

    _add_tile_group(houses, [
        [52, 53, 54],
        [64, 67, 66],
        [76, 77, 79],
    ], Vector2(-312, -96))

func _build_trees() -> void:
    var tree_specs := [
        [4, Vector2(-520, 184)],
        [3, Vector2(-472, 184)],
        [16, Vector2(-96, -24)],
        [28, Vector2(-112, 208)],
        [4, Vector2(288, -184)],
        [3, Vector2(432, 176)],
        [16, Vector2(520, -232)],
        [28, Vector2(552, 224)],
    ]

    for spec in tree_specs:
        _add_tile(trees, spec[0], spec[1])

func _build_stones() -> void:
    var stone_specs := [
        [92, Vector2(-96, 160)],
        [105, Vector2(160, 136)],
        [106, Vector2(272, 112)],
        [107, Vector2(360, 168)],
        [29, Vector2(168, -48)],
    ]

    for spec in stone_specs:
        _add_tile(stones, spec[0], spec[1])

func _build_branch_anchors() -> void:
    _build_library_anchor()
    _build_blacksmith_anchor()
    _build_garden_anchor()

func _build_library_anchor() -> void:
    _add_dungeon_tile(branch_anchors, 75, Vector2(-312, 24))
    _add_dungeon_tile(branch_anchors, 63, Vector2(-264, 24))
    _add_dungeon_tile(branch_anchors, 72, Vector2(-288, 72))

func _build_blacksmith_anchor() -> void:
    _add_dungeon_tile(branch_anchors, 103, Vector2(-560, 120))
    _add_dungeon_tile(branch_anchors, 102, Vector2(-520, 128))
    _add_tile(branch_anchors, 115, Vector2(-548, 72))

func _build_garden_anchor() -> void:
    _add_tile(branch_anchors, 131, Vector2(240, 24))
    _add_tile(branch_anchors, 2, Vector2(336, 16))
    _add_tile(branch_anchors, 2, Vector2(304, 64))
    _add_dungeon_tile(branch_anchors, 114, Vector2(376, 56))

func _build_signpost() -> void:
    _add_tile(signpost, 83, Vector2(432, 0))
    var label := Label.new()
    label.text = "Forest"
    label.position = Vector2(396, -42)
    label.size = Vector2(96, 24)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 14)
    label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.52))
    signpost.add_child(label)

func _build_gate() -> void:
    _add_tile(gate_visual, 44, Vector2(-48, -48))
    _add_tile(gate_visual, 45, Vector2(0, -48))
    _add_tile(gate_visual, 46, Vector2(48, -48))
    _add_tile(gate_visual, 47, Vector2(-72, 0))
    _add_tile(gate_visual, 47, Vector2(72, 0))
    _add_tile(gate_visual, 68, Vector2(-48, 48))
    _add_tile(gate_visual, 69, Vector2(0, 48))
    _add_tile(gate_visual, 70, Vector2(48, 48))

func _add_tile(parent: Node2D, tile_id: int, position: Vector2) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.texture = _textures[tile_id]
    sprite.position = position
    sprite.scale = Vector2.ONE * TILE_SCALE
    parent.add_child(sprite)
    return sprite

func _add_dungeon_tile(parent: Node2D, tile_id: int, position: Vector2) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.texture = _dungeon_textures[tile_id]
    sprite.position = position
    sprite.scale = Vector2.ONE * TILE_SCALE
    parent.add_child(sprite)
    return sprite

func _add_tile_group(parent: Node2D, tile_ids: Array, origin: Vector2) -> void:
    for row in range(tile_ids.size()):
        for col in range(tile_ids[row].size()):
            _add_tile(parent, tile_ids[row][col], origin + Vector2(col * WORLD_TILE, row * WORLD_TILE))
