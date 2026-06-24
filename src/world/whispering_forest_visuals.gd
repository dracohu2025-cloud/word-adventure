extends Node2D

const TILE_SIZE: int = 16
const TILE_SCALE: float = 3.0
const WORLD_TILE: int = int(TILE_SIZE * TILE_SCALE)
const TINY_SWORDS_BASE_PATH: String = "res://assets/licensed/tiny_swords"
const TINY_TERRAIN_PATH: String = TINY_SWORDS_BASE_PATH + "/terrain/Tilemap_Flat.png"
const TINY_TREE_PATH: String = TINY_SWORDS_BASE_PATH + "/resources/trees/Tree.png"
const TINY_STONE_SMALL_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/stone_small.png"
const TINY_STONE_STACK_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/stone_stack.png"
const TINY_PUMPKIN_A_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/pumpkin_a.png"
const TINY_PUMPKIN_B_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/pumpkin_b.png"
const TINY_WOOD_SIGN_PATH: String = TINY_SWORDS_BASE_PATH + "/deco/wood_sign.png"
const TINY_FENCE_PATH: String = TINY_SWORDS_BASE_PATH + "/fences/Wooden_Fence_64x64_tile.png"
const TINY_TILE_SIZE: int = 64
const TINY_TILE_SCALE: float = 0.75
const TINY_HORIZONTAL_ROAD_REGION: Rect2 = Rect2(Vector2(384, 80), Vector2(64, 32))
const TINY_VERTICAL_ROAD_REGION: Rect2 = Rect2(Vector2(400, 64), Vector2(32, 64))
const TINY_GRASS_REGION: Rect2 = Rect2(Vector2(64, 64), Vector2(64, 64))

var _tiny_textures: Dictionary = {}
var _using_tiny_swords_assets: bool = false

@onready var ground: Node2D = $Ground
@onready var road: Node2D = $Road
@onready var trees: Node2D = $Trees
@onready var props: Node2D = $Props
@onready var signpost: Node2D = $Signpost
@onready var deep_gate: Node2D = $DeepGate

func _ready() -> void:
    _load_textures()
    _build_ground()
    _build_roads()
    _build_trees()
    _build_props()
    _build_signpost()
    _build_deep_gate()

func _load_textures() -> void:
    _tiny_textures["terrain"] = _load_runtime_texture(TINY_TERRAIN_PATH)
    _tiny_textures["tree"] = _load_runtime_texture(TINY_TREE_PATH)
    _tiny_textures["stone_small"] = _load_runtime_texture(TINY_STONE_SMALL_PATH)
    _tiny_textures["stone_stack"] = _load_runtime_texture(TINY_STONE_STACK_PATH)
    _tiny_textures["pumpkin_a"] = _load_runtime_texture(TINY_PUMPKIN_A_PATH)
    _tiny_textures["pumpkin_b"] = _load_runtime_texture(TINY_PUMPKIN_B_PATH)
    _tiny_textures["wood_sign"] = _load_runtime_texture(TINY_WOOD_SIGN_PATH)
    _tiny_textures["fence"] = _load_runtime_texture(TINY_FENCE_PATH)
    _using_tiny_swords_assets = (
        _tiny_textures["terrain"] != null
        and _tiny_textures["tree"] != null
        and _tiny_textures["stone_small"] != null
        and _tiny_textures["stone_stack"] != null
        and _tiny_textures["pumpkin_a"] != null
        and _tiny_textures["pumpkin_b"] != null
        and _tiny_textures["wood_sign"] != null
        and _tiny_textures["fence"] != null
    )

func _build_ground() -> void:
    for x in range(-13, 14):
        for y in range(-7, 8):
            _add_tiny_atlas_sprite(
                ground,
                "terrain",
                Vector2(x * WORLD_TILE, y * WORLD_TILE),
                TINY_GRASS_REGION,
                TINY_TILE_SCALE
            )

func _build_roads() -> void:
    var main_points: Array[Vector2] = []
    for x in range(-11, 12):
        main_points.append(Vector2(x * WORLD_TILE, 96))
    _add_tiny_horizontal_road_tiles(road, main_points)

    _add_tiny_vertical_road_tiles(road, [
        Vector2(-480, 48),
        Vector2(-192, -48),
        Vector2(-192, 0),
        Vector2(-192, 48),
        Vector2(144, 144),
        Vector2(144, 192),
        Vector2(480, -96),
        Vector2(480, -48),
        Vector2(480, 0),
        Vector2(480, 48),
    ])

func _build_trees() -> void:
    var tree_specs := [
        [Vector2(-552, -168), Rect2(0, 0, 192, 256), 0.34],
        [Vector2(-420, -216), Rect2(192, 0, 192, 256), 0.34],
        [Vector2(-430, -88), Rect2(384, 0, 192, 256), 0.30],
        [Vector2(-336, 208), Rect2(384, 0, 192, 256), 0.32],
        [Vector2(-96, -196), Rect2(576, 0, 192, 256), 0.34],
        [Vector2(-42, -82), Rect2(0, 256, 192, 256), 0.30],
        [Vector2(42, 214), Rect2(0, 256, 192, 256), 0.34],
        [Vector2(250, -178), Rect2(192, 256, 192, 256), 0.34],
        [Vector2(230, -48), Rect2(384, 0, 192, 256), 0.30],
        [Vector2(318, 202), Rect2(384, 0, 192, 256), 0.32],
        [Vector2(420, 214), Rect2(576, 0, 192, 256), 0.30],
        [Vector2(550, -210), Rect2(0, 0, 192, 256), 0.34],
        [Vector2(552, 190), Rect2(192, 0, 192, 256), 0.34],
    ]

    for spec in tree_specs:
        _add_tiny_atlas_sprite(trees, "tree", spec[0], spec[1], spec[2])

func _build_props() -> void:
    _add_tiny_sprite(props, "pumpkin_a", Vector2(-500, -28), 0.75)
    _add_tiny_sprite(props, "stone_stack", Vector2(-420, 154), 0.75)
    _add_tiny_sprite(props, "stone_small", Vector2(-352, 48), 0.75)
    _add_tiny_sprite(props, "pumpkin_b", Vector2(-250, -116), 0.75)
    _add_tiny_sprite(props, "stone_stack", Vector2(72, 158), 0.75)
    _add_tiny_sprite(props, "pumpkin_a", Vector2(252, 44), 0.75)
    _add_tiny_sprite(props, "pumpkin_b", Vector2(320, 112), 0.75)
    _add_tiny_sprite(props, "stone_small", Vector2(390, -34), 0.75)
    _add_tiny_sprite(props, "stone_stack", Vector2(502, 166), 0.75)

func _build_signpost() -> void:
    _add_tiny_sprite(signpost, "wood_sign", Vector2(-520, 36), 0.75)

    var label := Label.new()
    label.text = "低语森林"
    label.position = Vector2(-586, -12)
    label.size = Vector2(132, 24)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 14)
    label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.52))
    signpost.add_child(label)

func _build_deep_gate() -> void:
    _add_tiny_atlas_sprite(deep_gate, "fence", Vector2(432, -96), Rect2(0, 0, 64, 64), 0.75)
    _add_tiny_atlas_sprite(deep_gate, "fence", Vector2(480, -96), Rect2(64, 0, 64, 64), 0.75)
    _add_tiny_atlas_sprite(deep_gate, "fence", Vector2(528, -96), Rect2(128, 0, 64, 64), 0.75)

func _add_tiny_horizontal_road_tiles(parent: Node2D, center_points: Array[Vector2]) -> void:
    for point in center_points:
        _add_tiny_atlas_sprite(parent, "terrain", point, TINY_HORIZONTAL_ROAD_REGION, TINY_TILE_SCALE)

func _add_tiny_vertical_road_tiles(parent: Node2D, center_points: Array[Vector2]) -> void:
    for point in center_points:
        _add_tiny_atlas_sprite(parent, "terrain", point, TINY_VERTICAL_ROAD_REGION, TINY_TILE_SCALE)

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
