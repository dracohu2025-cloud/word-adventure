extends Control

const DESIGN_SIZE := Vector2(720, 1280)
const SAFE_MARGIN := 24.0

const PANEL_TEXTURE := preload("res://assets/licensed/tiny_swords/ui/panels/Button_Disable_9Slides.png")
const CARVED_TEXTURE := preload("res://assets/licensed/tiny_swords/ui/banners/Carved_9Slides.png")
const BUTTON_TEXTURE := preload("res://assets/licensed/tiny_swords/ui/buttons/Button_Hover_3Slides.png")
const AVATAR_TEXTURE := preload("res://assets/licensed/tiny_swords/ui/avatars/Avatars_01.png")
const GOLD_ICON_TEXTURE := preload("res://assets/licensed/tiny_swords/ui/icons/Icon_03.png")
const PAGE_ICON_TEXTURE := preload("res://assets/licensed/tiny_swords/ui/icons/Icon_02.png")
const DUNGEON_VOID_TEXTURE := preload("res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_0000.png")
const DUNGEON_FLOOR_TEXTURE := preload("res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_0038.png")
const DUNGEON_FLOOR_DETAIL_TEXTURE := preload("res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_0036.png")
const DUNGEON_WALL_TEXTURE := preload("res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_0040.png")
const DUNGEON_DOOR_TEXTURE := preload("res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_0021.png")
const DUNGEON_CRATE_TEXTURE := preload("res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_0063.png")
const CHEST_TEXTURE := preload("res://assets/generated/tiny_swords_compatible/props/supply_chest_closed.png")

const PLAYER_SHEET := "res://assets/licensed/tiny_swords/units/warrior/Warrior_Idle.png"
const NPC_SHEET := "res://assets/licensed/tiny_swords/units/monk/Idle.png"
const ENEMY_SHEET := "res://assets/licensed/tiny_swords/enemies/skull/Skull_Idle.png"

const PANEL_TINT := Color(0.12, 0.16, 0.10, 0.96)
const PANEL_DARK_TINT := Color(0.08, 0.11, 0.08, 0.98)
const TEXT_MAIN := Color(0.94, 0.91, 0.78, 1.0)
const TEXT_GOLD := Color(1.0, 0.86, 0.36, 1.0)
const TEXT_MUTED := Color(0.72, 0.70, 0.62, 1.0)
const ACCENT := Color(0.92, 0.73, 0.39, 1.0)
const HIGHLIGHT := Color(0.42, 0.90, 0.74, 1.0)

var _room_index := 0
var _active_target := "图书管理员"
var _interaction_text := "交谈"
var _ui_buttons: Array[Button] = []
var _asset_frames: Array[NinePatchRect] = []
var _world_map_size := Vector2.ZERO

@onready var root: Control = $Root
@onready var hud: Control = $Root/Hud
@onready var room_view: Control = $Root/RoomView
@onready var bottom_bar: Control = $Root/BottomBar
@onready var overlays: Control = $Root/Overlays

func _ready() -> void:
    custom_minimum_size = DESIGN_SIZE
    set_anchors_preset(Control.PRESET_FULL_RECT)
    _build_scene()

func get_design_size() -> Vector2:
    return DESIGN_SIZE

func get_current_room_name() -> String:
    return "第 %d 层 · 旧书回廊" % (_room_index + 1)

func get_active_target() -> String:
    return _active_target

func get_environment_mode() -> String:
    return "castle_room_maze"

func get_layout_report() -> Dictionary:
    return {
        "hud_inside": _is_rect_inside(hud.get_rect(), Rect2(Vector2.ZERO, DESIGN_SIZE)),
        "room_inside": _is_rect_inside(room_view.get_rect(), Rect2(Vector2.ZERO, DESIGN_SIZE)),
        "bottom_inside": _is_rect_inside(bottom_bar.get_rect(), Rect2(Vector2.ZERO, DESIGN_SIZE)),
        "map_fills_screen": room_view.position == Vector2.ZERO and room_view.size == DESIGN_SIZE,
        "visible_area_is_partial_map": _world_map_size.x > room_view.size.x and _world_map_size.y > room_view.size.y,
        "hud_overlays_map": hud.position.y <= room_view.position.y + 24.0,
        "quickbar_overlays_map": bottom_bar.position.y + bottom_bar.size.y >= room_view.position.y + room_view.size.y - 24.0,
        "buttons_have_minimum_height": _buttons_have_minimum_height(56.0),
        "quickbar_items_aligned": _quickbar_items_aligned(),
        "asset_backed_frames": _asset_frames.size() >= 8,
        "castle_room_maze": room_view.get_node_or_null("WorldViewport/WorldMap/CastleGrid") != null,
        "no_outdoor_placeholders": room_view.find_child("LibraryHouse", true, false) == null \
            and room_view.find_child("TreeA", true, false) == null \
            and room_view.find_child("TreeB", true, false) == null,
    }

func trigger_action(action_name: String) -> void:
    match action_name:
        "talk":
            _show_dialogue_challenge()
        "inventory":
            _show_named_overlay("InventoryOverlay")
        "map":
            _show_named_overlay("MapOverlay")
        "enter":
            _room_index += 1
            _update_room_title()
        _:
            pass

func is_overlay_visible(overlay_name: String) -> bool:
    var overlay := overlays.get_node_or_null(overlay_name)
    return overlay is Control and overlay.visible

func _build_scene() -> void:
    for container in [hud, room_view, bottom_bar, overlays]:
        for child in container.get_children():
            child.queue_free()
    _ui_buttons.clear()
    _asset_frames.clear()

    _build_background()
    _build_room_view()
    _build_hud()
    _build_bottom_bar()
    _build_overlays()

func _build_background() -> void:
    var existing_bg := root.get_node_or_null("Background")
    if existing_bg != null:
        return
    var bg := ColorRect.new()
    bg.name = "Background"
    bg.color = Color(0.035, 0.04, 0.055, 1.0)
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    root.add_child(bg)
    root.move_child(bg, 0)

func _build_hud() -> void:
    hud.name = "Hud"
    hud.position = Vector2(18, 24)
    hud.size = Vector2(462, 132)
    hud.z_index = 30
    _add_ninepatch(hud, "HudFrame", PANEL_TEXTURE, Rect2(Vector2.ZERO, hud.size), PANEL_TINT)

    _add_sprite(hud, "Avatar", AVATAR_TEXTURE, Rect2(Vector2(22, 26), Vector2(80, 80)))
    _add_sprite(hud, "GoldIcon", GOLD_ICON_TEXTURE, Rect2(Vector2(310, 18), Vector2(32, 32)))

    _add_bar(hud, "HpBar", Rect2(Vector2(256, 58), Vector2(168, 28)), Color(0.82, 0.07, 0.08, 1.0), 1.0)
    _add_bar(hud, "MpBar", Rect2(Vector2(256, 92), Vector2(168, 28)), Color(0.18, 0.42, 0.92, 1.0), 1.0)

    _add_hud_text(hud, "LevelLabel", "Lv.1", Rect2(Vector2(122, 20), Vector2(92, 28)), 22, TEXT_MAIN)
    _add_hud_text(hud, "GoldLabel", "12", Rect2(Vector2(350, 20), Vector2(70, 28)), 22, TEXT_GOLD)
    _add_hud_text(hud, "HpText", "HP 120/120", Rect2(Vector2(122, 60), Vector2(124, 24)), 18, TEXT_MAIN)
    _add_hud_text(hud, "MpText", "MP 40/40", Rect2(Vector2(122, 94), Vector2(124, 24)), 18, TEXT_MAIN)

    _build_minimap()

func _build_minimap() -> void:
    var minimap := Control.new()
    minimap.name = "MiniMap"
    minimap.position = Vector2(500, 24)
    minimap.size = Vector2(190, 162)
    minimap.z_index = 30
    root.add_child(minimap)

    _add_ninepatch(minimap, "MiniMapFrame", PANEL_TEXTURE, Rect2(Vector2.ZERO, minimap.size), Color(0.13, 0.13, 0.12, 0.98))
    _add_ninepatch(minimap, "MiniMapPaper", CARVED_TEXTURE, Rect2(Vector2(18, 16), Vector2(154, 104)), Color(0.92, 0.80, 0.62, 0.95))
    _add_minimap_line(minimap, Vector2(42, 62), Vector2(148, 62))
    _add_minimap_line(minimap, Vector2(72, 38), Vector2(72, 98))
    _add_minimap_line(minimap, Vector2(118, 38), Vector2(118, 98))
    _add_minimap_marker(minimap, Vector2(74, 64), Color(0.35, 0.62, 1.0, 1.0))
    _add_minimap_marker(minimap, Vector2(118, 64), Color(0.95, 0.25, 0.22, 1.0))
    _add_label(minimap, "FloorLabel", "第 1 层", Rect2(Vector2(36, 124), Vector2(118, 28)), 18, TEXT_MAIN)

func _build_room_view() -> void:
    room_view.name = "RoomView"
    room_view.position = Vector2.ZERO
    room_view.size = DESIGN_SIZE
    room_view.clip_contents = true
    room_view.z_index = 1

    var viewport := Control.new()
    viewport.name = "WorldViewport"
    viewport.position = Vector2.ZERO
    viewport.size = DESIGN_SIZE
    viewport.clip_contents = true
    room_view.add_child(viewport)

    var world_map := Control.new()
    world_map.name = "WorldMap"
    world_map.position = Vector2(-216, -86)
    world_map.size = Vector2(1152, 1536)
    world_map.clip_contents = true
    viewport.add_child(world_map)
    _world_map_size = world_map.size

    _build_castle_room_maze(world_map)

    _add_sprite(world_map, "DoorNorth", DUNGEON_DOOR_TEXTURE, Rect2(Vector2(528, 260), Vector2(56, 76)))
    _add_sprite(world_map, "ArchiveCrate", DUNGEON_CRATE_TEXTURE, Rect2(Vector2(416, 470), Vector2(48, 48)))
    _add_sprite(world_map, "Chest", CHEST_TEXTURE, Rect2(Vector2(710, 742), Vector2(78, 78)))

    _add_actor(world_map, "PlayerAvatar", PLAYER_SHEET, Rect2(Vector2(520, 640), Vector2(130, 130)))
    _add_actor(world_map, "NpcAvatar", NPC_SHEET, Rect2(Vector2(374, 502), Vector2(112, 112)))
    _add_actor(world_map, "EnemyAvatar", ENEMY_SHEET, Rect2(Vector2(686, 530), Vector2(112, 112)))

    _add_interaction_prompt(world_map, Vector2(380, 466), "交谈")
    _add_interaction_prompt(world_map, Vector2(684, 492), "挑战")

func _build_castle_room_maze(parent: Control) -> void:
    var grid := Control.new()
    grid.name = "CastleGrid"
    grid.position = Vector2.ZERO
    grid.size = parent.size
    parent.add_child(grid)

    var layout := [
        "##################",
        "#......#.........#",
        "#......#.........#",
        "#......#....###..#",
        "###.####....#....#",
        "#......#....#....#",
        "#......######....#",
        "#................#",
        "#....####.########",
        "#....#...........#",
        "#....#...........#",
        "#....#######.#####",
        "#............#...#",
        "########.#####...#",
        "#........#.......#",
        "#........#.......#",
        "#....#####...#####",
        "#................#",
        "#..######.########",
        "#................#",
        "##################",
    ]
    var tile_size := 64.0
    for row in range(layout.size()):
        var line: String = layout[row]
        for column in range(line.length()):
            var cell := line[column]
            var tile_texture := DUNGEON_WALL_TEXTURE if cell == "#" else DUNGEON_FLOOR_TEXTURE
            if cell != "#" and (row + column) % 7 == 0:
                tile_texture = DUNGEON_FLOOR_DETAIL_TEXTURE
            var tint := Color(0.36, 0.39, 0.45, 1.0) if cell == "#" else Color(0.56, 0.59, 0.66, 1.0)
            var tile := _add_texture(
                grid,
                "WallTile" if cell == "#" else "FloorTile",
                tile_texture,
                Rect2(Vector2(column, row) * tile_size, Vector2(tile_size, tile_size)),
                tint
            )
            tile.stretch_mode = TextureRect.STRETCH_SCALE

    var vignette := ColorRect.new()
    vignette.name = "DungeonShade"
    vignette.color = Color(0.0, 0.0, 0.0, 0.18)
    vignette.position = Vector2.ZERO
    vignette.size = parent.size
    vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(vignette)

func _build_bottom_bar() -> void:
    bottom_bar.name = "BottomBar"
    bottom_bar.position = Vector2(18, 1138)
    bottom_bar.size = Vector2(684, 118)
    bottom_bar.z_index = 30
    _add_ninepatch(bottom_bar, "BottomFrame", PANEL_TEXTURE, Rect2(Vector2.ZERO, bottom_bar.size), PANEL_DARK_TINT)

    _add_asset_button(bottom_bar, "DescendButton", "↓", Rect2(Vector2(20, 22), Vector2(86, 74)), func() -> void: trigger_action("enter"), 26)
    _add_asset_button(bottom_bar, "PotionButton", "药水", Rect2(Vector2(124, 22), Vector2(100, 74)), func() -> void: pass, 18)
    _add_asset_button(bottom_bar, "FoodButton", "食物", Rect2(Vector2(242, 22), Vector2(100, 74)), func() -> void: pass, 18)
    _add_asset_button(bottom_bar, "SkillButton", "技能", Rect2(Vector2(360, 22), Vector2(100, 74)), func() -> void: pass, 18)
    _add_asset_button(bottom_bar, "MapButton", "地图", Rect2(Vector2(478, 22), Vector2(86, 74)), func() -> void: trigger_action("map"), 18)
    _add_asset_button(bottom_bar, "InventoryButton", "背包", Rect2(Vector2(582, 22), Vector2(82, 74)), func() -> void: trigger_action("inventory"), 18)

func _build_overlays() -> void:
    overlays.name = "Overlays"
    overlays.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlays.z_index = 50
    overlays.mouse_filter = Control.MOUSE_FILTER_IGNORE

    _build_map_overlay()
    _build_inventory_overlay()
    _build_dialogue_overlay()

func _build_dialogue_overlay() -> void:
    var dialogue_overlay := Control.new()
    dialogue_overlay.name = "DialogueOverlay"
    dialogue_overlay.visible = false
    dialogue_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlays.add_child(dialogue_overlay)

    _add_ninepatch(dialogue_overlay, "DialoguePanel", PANEL_TEXTURE, Rect2(Vector2(36, 810), Vector2(648, 244)), PANEL_DARK_TINT)

    var dialogue := RichTextLabel.new()
    dialogue.name = "DialogueText"
    dialogue.bbcode_enabled = true
    dialogue.fit_content = false
    dialogue.scroll_active = false
    dialogue.clip_contents = true
    dialogue.position = Vector2(76, 846)
    dialogue.size = Vector2(568, 74)
    dialogue.add_theme_font_size_override("normal_font_size", 24)
    dialogue.add_theme_color_override("default_color", TEXT_MAIN)
    dialogue.text = "《万语之书》正在发光。告诉它，[color=#6be6bd]“书”[/color] 的英文是什么？"
    dialogue_overlay.add_child(dialogue)

    _add_asset_button(dialogue_overlay, "ChoiceBookButton", "book", Rect2(Vector2(76, 940), Vector2(172, 62)), func() -> void: _answer_choice("book"))
    _add_asset_button(dialogue_overlay, "ChoiceFireButton", "fire", Rect2(Vector2(274, 940), Vector2(172, 62)), func() -> void: _answer_choice("fire"))
    _add_asset_button(dialogue_overlay, "ChoiceTreeButton", "tree", Rect2(Vector2(472, 940), Vector2(172, 62)), func() -> void: _answer_choice("tree"))

func _build_map_overlay() -> void:
    var map_overlay := Control.new()
    map_overlay.name = "MapOverlay"
    map_overlay.visible = false
    map_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlays.add_child(map_overlay)

    _add_ninepatch(map_overlay, "MapPanel", PANEL_TEXTURE, Rect2(Vector2(64, 220), Vector2(592, 620)), PANEL_DARK_TINT)
    _add_label(map_overlay, "MapTitle", "第 1 层地图", Rect2(Vector2(104, 250), Vector2(512, 40)), 28, TEXT_GOLD)
    _add_label(map_overlay, "MapBody", "旧书回廊、抄写室、封印门组成一条清晰路线。房间之间只通过门相连，移动边界和视觉边界保持一致。", Rect2(Vector2(104, 320), Vector2(512, 170)), 22, TEXT_MAIN, HORIZONTAL_ALIGNMENT_LEFT)
    _add_asset_button(map_overlay, "MapCloseButton", "返回", Rect2(Vector2(244, 720), Vector2(232, 62)), func() -> void: map_overlay.visible = false)

func _build_inventory_overlay() -> void:
    var inventory_overlay := Control.new()
    inventory_overlay.name = "InventoryOverlay"
    inventory_overlay.visible = false
    inventory_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlays.add_child(inventory_overlay)

    _add_ninepatch(inventory_overlay, "InventoryPanel", PANEL_TEXTURE, Rect2(Vector2(48, 180), Vector2(624, 760)), PANEL_DARK_TINT)
    _add_label(inventory_overlay, "InventoryTitle", "背包", Rect2(Vector2(88, 214), Vector2(250, 44)), 34, TEXT_GOLD, HORIZONTAL_ALIGNMENT_LEFT)
    for index in range(20):
        var col := index % 4
        var row := index / 4
        _add_ninepatch(inventory_overlay, "Slot%d" % index, CARVED_TEXTURE, Rect2(Vector2(92 + col * 132, 306 + row * 96), Vector2(86, 76)), Color(0.12, 0.15, 0.10, 0.95))
    _add_asset_button(inventory_overlay, "InventoryCloseButton", "返回", Rect2(Vector2(244, 830), Vector2(232, 62)), func() -> void: inventory_overlay.visible = false)

func _show_dialogue_challenge() -> void:
    var dialogue_overlay := overlays.get_node("DialogueOverlay") as Control
    dialogue_overlay.visible = true
    var text_node := dialogue_overlay.get_node("DialogueText") as RichTextLabel
    text_node.text = "《万语之书》正在发光。告诉它，[color=#6be6bd]“书”[/color] 的英文是什么？"

func _answer_choice(answer: String) -> void:
    var dialogue_overlay := overlays.get_node("DialogueOverlay") as Control
    var text_node := dialogue_overlay.get_node("DialogueText") as RichTextLabel
    if answer == "book":
        text_node.text = "答对了。[color=#6be6bd]book[/color] 就是“书”。你帮这一页找回了名字。"
    else:
        text_node.text = "《万语之书》摇了摇书页：再想想，[color=#6be6bd]“书”[/color] 是哪一个英文？"

func _show_named_overlay(overlay_name: String) -> void:
    var overlay := overlays.get_node_or_null(overlay_name)
    if overlay is Control:
        overlay.visible = true

func _update_room_title() -> void:
    var title := root.get_node_or_null("MiniMap/FloorLabel")
    if title is Label:
        title.text = "第 %d 层" % (_room_index + 1)

func _add_minimap_line(parent: Control, start: Vector2, end: Vector2) -> void:
    var line := Line2D.new()
    line.name = "MiniMapLine"
    line.points = PackedVector2Array([start, end])
    line.width = 8.0
    line.default_color = Color(0.22, 0.16, 0.10, 0.95)
    line.z_index = 4
    parent.add_child(line)

func _add_minimap_marker(parent: Control, position: Vector2, marker_color: Color) -> void:
    var marker := ColorRect.new()
    marker.name = "MiniMapMarker"
    marker.position = position - Vector2(5, 5)
    marker.size = Vector2(10, 10)
    marker.color = marker_color
    marker.z_index = 6
    marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(marker)

func _add_interaction_prompt(parent: Control, prompt_position: Vector2, action_text: String) -> void:
    var prompt := Control.new()
    prompt.name = "%sPrompt" % action_text
    prompt.position = prompt_position
    prompt.size = Vector2(122, 54)
    prompt.z_index = 12
    parent.add_child(prompt)

    _add_ninepatch(prompt, "ActionFrame", BUTTON_TEXTURE, Rect2(Vector2.ZERO, prompt.size), Color(1.0, 1.0, 1.0, 1.0))
    _add_label(prompt, "ActionLabel", action_text, Rect2(Vector2(8, 10), Vector2(106, 30)), 20, Color(0.10, 0.12, 0.09, 1.0))

func _add_bar(parent: Control, node_name: String, rect: Rect2, fill_color: Color, ratio: float) -> Control:
    var holder := Control.new()
    holder.name = node_name
    holder.position = rect.position
    holder.size = rect.size
    parent.add_child(holder)

    var fill := ColorRect.new()
    fill.name = "Fill"
    fill.color = fill_color
    fill.position = Vector2(8, 7)
    fill.size = Vector2((rect.size.x - 16.0) * ratio, rect.size.y - 14.0)
    fill.z_index = 3
    holder.add_child(fill)

    var frame := _add_ninepatch(holder, "Frame", CARVED_TEXTURE, Rect2(Vector2.ZERO, rect.size), Color(1.0, 1.0, 1.0, 0.95))
    frame.z_index = 2
    return holder

func _add_actor(parent: Control, node_name: String, sheet_path: String, rect: Rect2) -> TextureRect:
    var texture := _atlas(sheet_path, Vector2(192, 192), 0, 0)
    var actor := _add_texture(parent, node_name, texture, rect)
    actor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    return actor

func _add_asset_button(parent: Control, node_name: String, text: String, rect: Rect2, callback: Callable, font_size: int = 22) -> Control:
    var holder := Control.new()
    holder.name = node_name
    holder.position = rect.position
    holder.size = rect.size
    holder.clip_contents = true
    parent.add_child(holder)

    _add_ninepatch(holder, "Frame", BUTTON_TEXTURE, Rect2(Vector2.ZERO, rect.size), Color(1, 1, 1, 1))

    var button := Button.new()
    button.name = "Button"
    button.text = text
    button.flat = true
    button.position = Vector2.ZERO
    button.size = rect.size
    button.clip_text = true
    button.alignment = HORIZONTAL_ALIGNMENT_CENTER
    button.add_theme_font_size_override("font_size", font_size)
    button.add_theme_color_override("font_color", Color(0.12, 0.13, 0.10, 1.0))
    button.add_theme_color_override("font_hover_color", Color(0.04, 0.05, 0.04, 1.0))
    button.pressed.connect(callback)
    holder.add_child(button)
    _ui_buttons.append(button)
    return holder

func _add_label(
    parent: Control,
    node_name: String,
    text: String,
    rect: Rect2,
    font_size: int,
    color: Color,
    h_align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER,
    v_align: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER
) -> Label:
    var label := Label.new()
    label.name = node_name
    label.text = text
    label.position = rect.position
    label.size = rect.size
    label.horizontal_alignment = h_align
    label.vertical_alignment = v_align
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.clip_text = true
    label.z_index = 40
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", color)
    parent.add_child(label)
    return label

func _add_hud_text(parent: Control, node_name: String, text: String, rect: Rect2, font_size: int, color: Color) -> RichTextLabel:
    var label := RichTextLabel.new()
    label.name = node_name
    label.text = text
    label.position = rect.position
    label.size = rect.size
    label.fit_content = false
    label.scroll_active = false
    label.clip_contents = true
    label.z_index = 20
    label.add_theme_font_size_override("normal_font_size", font_size)
    label.add_theme_color_override("default_color", color)
    parent.add_child(label)
    return label

func _add_texture(parent: Control, node_name: String, texture: Texture2D, rect: Rect2, modulate_color: Color = Color.WHITE) -> TextureRect:
    var texture_rect := TextureRect.new()
    texture_rect.name = node_name
    texture_rect.texture = texture
    texture_rect.position = rect.position
    texture_rect.size = rect.size
    texture_rect.modulate = modulate_color
    texture_rect.clip_contents = true
    texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
    texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(texture_rect)
    return texture_rect

func _add_sprite(parent: Control, node_name: String, texture: Texture2D, rect: Rect2, modulate_color: Color = Color.WHITE) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.name = node_name
    sprite.texture = texture
    sprite.centered = false
    sprite.position = rect.position
    sprite.modulate = modulate_color
    sprite.z_index = 2
    var texture_size := texture.get_size()
    sprite.scale = Vector2(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
    parent.add_child(sprite)
    return sprite

func _add_ninepatch(parent: Control, node_name: String, texture: Texture2D, rect: Rect2, modulate_color: Color = Color.WHITE) -> NinePatchRect:
    var frame := NinePatchRect.new()
    frame.name = node_name
    frame.texture = texture
    frame.position = rect.position
    frame.size = rect.size
    frame.patch_margin_left = 18
    frame.patch_margin_top = 18
    frame.patch_margin_right = 18
    frame.patch_margin_bottom = 18
    frame.modulate = modulate_color
    frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(frame)
    _asset_frames.append(frame)
    return frame

func _atlas(path: String, frame_size: Vector2, column: int, row: int) -> AtlasTexture:
    var atlas := AtlasTexture.new()
    atlas.atlas = load(path)
    atlas.region = Rect2(Vector2(column, row) * frame_size, frame_size)
    return atlas

func _is_rect_inside(inner: Rect2, outer: Rect2) -> bool:
    return inner.position.x >= outer.position.x \
        and inner.position.y >= outer.position.y \
        and inner.end.x <= outer.end.x \
        and inner.end.y <= outer.end.y

func _buttons_have_minimum_height(min_height: float) -> bool:
    for button in _ui_buttons:
        if button.size.y < min_height and not button.name.contains("Close"):
            return false
    return true

func _quickbar_items_aligned() -> bool:
    var names := ["DescendButton", "PotionButton", "FoodButton", "SkillButton", "MapButton", "InventoryButton"]
    var first := bottom_bar.get_node(names[0]) as Control
    for node_name in names:
        var button := bottom_bar.get_node(node_name) as Control
        if not is_equal_approx(button.position.y, first.position.y):
            return false
        if not is_equal_approx(button.size.y, first.size.y):
            return false
    return true
