extends Node2D

const TILE_SIZE: int = 16
const TILE_SCALE: float = 3.0
const WORLD_TILE: int = int(TILE_SIZE * TILE_SCALE)
const TILE_PATH: String = "res://assets/third_party/kenney_tiny_town/Tiles/tile_%04d.png"
const DUNGEON_TILE_PATH: String = "res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_%04d.png"
const STONE_ROAD_TILE: int = 40
const TINY_SWORDS_BASE_PATH: String = "res://assets/licensed/tiny_swords"
const TINY_TERRAIN_PATH: String = TINY_SWORDS_BASE_PATH + "/terrain/Tilemap_Flat.png"
const TINY_HOUSE_1_PATH: String = TINY_SWORDS_BASE_PATH + "/buildings/blue/House1.png"
const TINY_HOUSE_2_PATH: String = TINY_SWORDS_BASE_PATH + "/buildings/blue/House2.png"
const TINY_HOUSE_3_PATH: String = TINY_SWORDS_BASE_PATH + "/buildings/blue/House3.png"
const TINY_TREE_PATH: String = TINY_SWORDS_BASE_PATH + "/resources/trees/Tree.png"
const TINY_STONE_SMALL_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/stone_small.png"
const TINY_STONE_STACK_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/stone_stack.png"
const TINY_PUMPKIN_A_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/pumpkin_a.png"
const TINY_PUMPKIN_B_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/pumpkin_b.png"
const TINY_SCARECROW_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/scarecrow.png"
const TINY_WOOD_SIGN_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/wood_sign.png"
const TINY_FLOWER_POT_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/flower_pot.png"
const TINY_FENCE_PATH: String = TINY_SWORDS_BASE_PATH + "/fences/Wooden_Fence_64x64_tile.png"
const TINY_TILE_SIZE: int = 64
const TINY_TILE_SCALE: float = 0.75
const TINY_HORIZONTAL_ROAD_REGION: Rect2 = Rect2(Vector2(384, 80), Vector2(64, 32))
const TINY_VERTICAL_ROAD_REGION: Rect2 = Rect2(Vector2(400, 64), Vector2(32, 64))

var _textures: Dictionary = {}
var _dungeon_textures: Dictionary = {}
var _tiny_textures: Dictionary = {}
var _using_tiny_swords_assets: bool = false

@onready var ground: Node2D = $Ground
@onready var main_road: Node2D = $MainRoad
@onready var house_roads: Node2D = $HouseRoads
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
    _tiny_textures["terrain"] = _load_runtime_texture(TINY_TERRAIN_PATH)
    _tiny_textures["house_1"] = _load_runtime_texture(TINY_HOUSE_1_PATH)
    _tiny_textures["house_2"] = _load_runtime_texture(TINY_HOUSE_2_PATH)
    _tiny_textures["house_3"] = _load_runtime_texture(TINY_HOUSE_3_PATH)
    _tiny_textures["tree"] = _load_runtime_texture(TINY_TREE_PATH)
    _tiny_textures["stone_small"] = _load_runtime_texture(TINY_STONE_SMALL_PATH)
    _tiny_textures["stone_stack"] = _load_runtime_texture(TINY_STONE_STACK_PATH)
    _tiny_textures["pumpkin_a"] = _load_runtime_texture(TINY_PUMPKIN_A_PATH)
    _tiny_textures["pumpkin_b"] = _load_runtime_texture(TINY_PUMPKIN_B_PATH)
    _tiny_textures["scarecrow"] = _load_runtime_texture(TINY_SCARECROW_PATH)
    _tiny_textures["wood_sign"] = _load_runtime_texture(TINY_WOOD_SIGN_PATH)
    _tiny_textures["flower_pot"] = _load_runtime_texture(TINY_FLOWER_POT_PATH)
    _tiny_textures["fence"] = _load_runtime_texture(TINY_FENCE_PATH)
    _using_tiny_swords_assets = (
        _tiny_textures["terrain"] != null
        and _tiny_textures["house_1"] != null
        and _tiny_textures["house_2"] != null
        and _tiny_textures["house_3"] != null
        and _tiny_textures["tree"] != null
        and _tiny_textures["stone_small"] != null
        and _tiny_textures["stone_stack"] != null
        and _tiny_textures["pumpkin_a"] != null
        and _tiny_textures["pumpkin_b"] != null
        and _tiny_textures["scarecrow"] != null
        and _tiny_textures["wood_sign"] != null
        and _tiny_textures["flower_pot"] != null
        and _tiny_textures["fence"] != null
    )

    if _using_tiny_swords_assets:
        return

    var ids := [
        0, 1, 2, 3, 4, 15, 16, 17, 28, 29, 44, 45, 46, 47, 48, 49,
        50, 52, 53, 54, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
        71, 72, 73, 74, 75, 76, 77, 78, 79, 83, 84, 85, 86, 87, 88,
        89, 90, 91, 104, 105, 106, 107, 115, 130, 131
    ]

    for id in ids:
        _textures[id] = load(TILE_PATH % id)

    var dungeon_ids := [
        40, 63, 72, 75, 101, 102, 103, 104, 113, 114, 115, 116, 129,
        130, 131
    ]

    for id in dungeon_ids:
        _dungeon_textures[id] = load(DUNGEON_TILE_PATH % id)

func _build_ground() -> void:
    if _using_tiny_swords_assets:
        _build_tiny_swords_ground()
        return

    for x in range(-13, 14):
        for y in range(-7, 8):
            var tile_id := 0
            if (x + y) % 7 == 0:
                tile_id = 1
            if (x * 3 + y) % 23 == 0:
                tile_id = 2
            _add_tile(ground, tile_id, Vector2(x * WORLD_TILE, y * WORLD_TILE))

func _build_roads() -> void:
    var main_points: Array[Vector2] = []
    for x in range(-12, 13):
        main_points.append(Vector2(x * WORLD_TILE, 96))
    if _using_tiny_swords_assets:
        _add_tiny_horizontal_road_tiles(main_road, main_points)
    else:
        _add_horizontal_road(main_road, main_points)

    var house_spur_points := [
        Vector2(-504, 72),
        Vector2(-264, 72),
        Vector2(240, 72),
    ]
    if _using_tiny_swords_assets:
        _add_tiny_vertical_road_tiles(house_roads, house_spur_points)
    else:
        _add_road_tiles(house_roads, house_spur_points)

    var spur_points := [
        Vector2(480, -48),
        Vector2(480, 0),
        Vector2(480, 48),
        Vector2(528, 0),
        Vector2(528, 48),
    ]
    if _using_tiny_swords_assets:
        _add_tiny_vertical_road_tiles(exit_road, [
            Vector2(480, -48),
            Vector2(480, 0),
            Vector2(480, 48),
        ])
        _add_tiny_horizontal_road_tiles(exit_road, [
            Vector2(528, 0),
        ])
    else:
        _add_road_tiles(exit_road, spur_points)

func _build_houses() -> void:
    if _using_tiny_swords_assets:
        _add_tiny_sprite(houses, "house_1", Vector2(-504, -56), 0.75)
        _add_tiny_sprite(houses, "house_2", Vector2(-264, -80), 0.75)
        _add_tiny_sprite(houses, "house_3", Vector2(240, -80), 0.75)
        return

    _add_tile_group(houses, [
        [48, 49, 50],
        [60, 63, 62],
        [72, 74, 75],
    ], Vector2(-552, -72))

    _add_tile_group(houses, [
        [52, 53, 54],
        [64, 67, 66],
        [76, 78, 79],
    ], Vector2(-312, -96))

func _build_trees() -> void:
    if _using_tiny_swords_assets:
        var tiny_tree_specs := [
            [Vector2(-520, 184), Rect2(0, 0, 192, 256)],
            [Vector2(-472, 184), Rect2(192, 0, 192, 256)],
            [Vector2(-96, -24), Rect2(384, 0, 192, 256)],
            [Vector2(-112, 208), Rect2(576, 0, 192, 256)],
            [Vector2(288, -184), Rect2(0, 256, 192, 256)],
            [Vector2(432, 176), Rect2(192, 256, 192, 256)],
            [Vector2(520, -232), Rect2(384, 0, 192, 256)],
            [Vector2(552, 224), Rect2(0, 0, 192, 256)],
        ]
        for spec in tiny_tree_specs:
            _add_tiny_atlas_sprite(trees, "tree", spec[0], spec[1], 0.35)
        return

    var tree_specs := [
        [4, 16, Vector2(-520, 184)],
        [3, 15, Vector2(-472, 184)],
        [4, 16, Vector2(-96, -24)],
        [4, 16, Vector2(-112, 208)],
        [4, 16, Vector2(288, -184)],
        [3, 15, Vector2(432, 176)],
        [4, 16, Vector2(520, -232)],
        [4, 16, Vector2(552, 224)],
    ]

    for spec in tree_specs:
        _add_tree(trees, spec[0], spec[1], spec[2])

func _build_stones() -> void:
    if _using_tiny_swords_assets:
        _add_tiny_sprite(stones, "stone_stack", Vector2(160, 168), 0.75)
        _add_tiny_sprite(stones, "pumpkin_a", Vector2(304, 152), 0.75)
        _add_tiny_sprite(stones, "flower_pot", Vector2(360, 168), 0.75)
        _add_tiny_sprite(stones, "pumpkin_b", Vector2(168, -48), 0.75)
        return

    var stone_specs := [
        [105, Vector2(160, 168)],
        [106, Vector2(304, 152)],
        [107, Vector2(360, 168)],
        [29, Vector2(168, -48)],
    ]

    for spec in stone_specs:
        _add_tile(stones, spec[0], spec[1])

func _build_branch_anchors() -> void:
    if _using_tiny_swords_assets:
        _add_tiny_sprite(branch_anchors, "wood_sign", Vector2(-384, 24), 0.75)
        _add_tiny_sprite(branch_anchors, "stone_small", Vector2(-336, 72), 0.75)
        _add_tiny_sprite(branch_anchors, "stone_stack", Vector2(-560, 120), 0.75)
        _add_tiny_sprite(branch_anchors, "scarecrow", Vector2(-520, 128), 0.75)
        _add_tiny_sprite(branch_anchors, "flower_pot", Vector2(184, 24), 0.75)
        _add_tiny_sprite(branch_anchors, "pumpkin_a", Vector2(336, 16), 0.75)
        _add_tiny_sprite(branch_anchors, "pumpkin_b", Vector2(376, 56), 0.75)
        return

    _build_library_anchor()
    _build_blacksmith_anchor()
    _build_garden_anchor()

func _build_library_anchor() -> void:
    _add_dungeon_tile(branch_anchors, 75, Vector2(-384, 24))
    _add_dungeon_tile(branch_anchors, 63, Vector2(-336, 72))
    _add_dungeon_tile(branch_anchors, 72, Vector2(-384, 72))

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
    if _using_tiny_swords_assets:
        _add_tiny_sprite(signpost, "wood_sign", Vector2(432, 0), 0.75)
    else:
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
    if _using_tiny_swords_assets:
        _add_tiny_atlas_sprite(gate_visual, "fence", Vector2(-48, -48), Rect2(0, 0, 64, 64), 0.75)
        _add_tiny_atlas_sprite(gate_visual, "fence", Vector2(0, -48), Rect2(64, 0, 64, 64), 0.75)
        _add_tiny_atlas_sprite(gate_visual, "fence", Vector2(48, -48), Rect2(128, 0, 64, 64), 0.75)
        _add_tiny_atlas_sprite(gate_visual, "fence", Vector2(-48, 0), Rect2(0, 64, 64, 64), 0.75)
        _add_tiny_atlas_sprite(gate_visual, "fence", Vector2(48, 0), Rect2(192, 64, 64, 64), 0.75)
        _add_tiny_atlas_sprite(gate_visual, "fence", Vector2(-48, 48), Rect2(0, 128, 64, 64), 0.75)
        _add_tiny_atlas_sprite(gate_visual, "fence", Vector2(48, 48), Rect2(128, 128, 64, 64), 0.75)
        return

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

func _add_tree(parent: Node2D, top_tile_id: int, bottom_tile_id: int, bottom_position: Vector2) -> void:
    _add_tile(parent, top_tile_id, bottom_position - Vector2(0, WORLD_TILE))
    _add_tile(parent, bottom_tile_id, bottom_position)

func _add_horizontal_road(parent: Node2D, center_points: Array) -> void:
    for i in range(center_points.size()):
        _add_dungeon_tile(parent, STONE_ROAD_TILE, center_points[i])

func _add_road_tiles(parent: Node2D, center_points: Array) -> void:
    for point in center_points:
        _add_dungeon_tile(parent, STONE_ROAD_TILE, point)

func _build_tiny_swords_ground() -> void:
    for x in range(-13, 14):
        for y in range(-7, 8):
            _add_tiny_atlas_sprite(
                ground,
                "terrain",
                Vector2(x * WORLD_TILE, y * WORLD_TILE),
                Rect2(Vector2(64, 64), Vector2(TINY_TILE_SIZE, TINY_TILE_SIZE)),
                TINY_TILE_SCALE
            )

func _add_tiny_horizontal_road_tiles(parent: Node2D, center_points: Array) -> void:
    for point in center_points:
        _add_tiny_atlas_sprite(
            parent,
            "terrain",
            point,
            TINY_HORIZONTAL_ROAD_REGION,
            TINY_TILE_SCALE
        )

func _add_tiny_vertical_road_tiles(parent: Node2D, center_points: Array) -> void:
    for point in center_points:
        _add_tiny_atlas_sprite(
            parent,
            "terrain",
            point,
            TINY_VERTICAL_ROAD_REGION,
            TINY_TILE_SCALE
        )

func _add_tiny_sprite(parent: Node2D, texture_key: String, position: Vector2, scale_value: float) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.texture = _tiny_textures[texture_key]
    sprite.position = position
    sprite.scale = Vector2.ONE * scale_value
    sprite.set_meta("asset_source", "tiny_swords")
    parent.add_child(sprite)
    return sprite

func _add_tiny_atlas_sprite(parent: Node2D, texture_key: String, position: Vector2, region: Rect2, scale_value: float) -> Sprite2D:
    var atlas := AtlasTexture.new()
    atlas.atlas = _tiny_textures[texture_key]
    atlas.region = region

    var sprite := Sprite2D.new()
    sprite.texture = atlas
    sprite.position = position
    sprite.scale = Vector2.ONE * scale_value
    sprite.set_meta("asset_source", "tiny_swords")
    parent.add_child(sprite)
    return sprite

func _load_runtime_texture(path: String) -> Texture2D:
    if not FileAccess.file_exists(path):
        return null

    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    if error != OK:
        return null

    return ImageTexture.create_from_image(image)

func is_using_tiny_swords_assets() -> bool:
    return _using_tiny_swords_assets

func _add_tile_group(parent: Node2D, tile_ids: Array, origin: Vector2) -> void:
    for row in range(tile_ids.size()):
        for col in range(tile_ids[row].size()):
            _add_tile(parent, tile_ids[row][col], origin + Vector2(col * WORLD_TILE, row * WORLD_TILE))
