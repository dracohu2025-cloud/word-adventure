extends CanvasLayer

const PixelUIStyle := preload("res://src/ui/pixel_ui_style.gd")

const PLAYER_IDLE_PATH: String = "res://assets/licensed/tiny_swords/units/warrior/Warrior_Idle.png"
const PLAYER_ATTACK_PATH: String = "res://assets/licensed/tiny_swords/units/warrior/Warrior_Attack1.png"
const ENEMY_IDLE_PATH: String = "res://assets/licensed/tiny_swords/enemies/skull/Skull_Idle.png"
const ENEMY_ATTACK_PATH: String = "res://assets/licensed/tiny_swords/enemies/skull/Skull_Attack.png"
const UI_FRAME_PATH: String = "res://assets/licensed/tiny_swords/ui/banners/Carved_9Slides.png"

const PLAYER_IDLE_FRAMES: int = 8
const PLAYER_ATTACK_FRAMES: int = 4
const ENEMY_IDLE_FRAMES: int = 8
const ENEMY_ATTACK_FRAMES: int = 7
const ANIMATION_FPS: float = 10.0

@onready var focus_panel: Panel = $FocusPanel
@onready var frame_texture: NinePatchRect = $FocusPanel/FrameTexture
@onready var title_label: Label = $FocusPanel/TitleLabel
@onready var player_sprite: AnimatedSprite2D = $FocusPanel/PlayerAnchor/PlayerSprite
@onready var enemy_sprite: AnimatedSprite2D = $FocusPanel/EnemyAnchor/EnemySprite
@onready var player_name_label: Label = $FocusPanel/PlayerStatus/PlayerNameLabel
@onready var player_hp_label: Label = $FocusPanel/PlayerStatus/PlayerHPLabel
@onready var player_hp_bar: Control = $FocusPanel/PlayerStatus/PlayerHPBar
@onready var player_hp_fill: ColorRect = $FocusPanel/PlayerStatus/PlayerHPBar/Fill
@onready var player_hp_frame: Panel = $FocusPanel/PlayerStatus/PlayerHPBar/Frame
@onready var enemy_name_label: Label = $FocusPanel/EnemyStatus/EnemyNameLabel
@onready var enemy_hp_label: Label = $FocusPanel/EnemyStatus/EnemyHPLabel
@onready var enemy_hp_bar: Control = $FocusPanel/EnemyStatus/EnemyHPBar
@onready var enemy_hp_fill: ColorRect = $FocusPanel/EnemyStatus/EnemyHPBar/Fill
@onready var enemy_hp_frame: Panel = $FocusPanel/EnemyStatus/EnemyHPBar/Frame
@onready var damage_text_layer: Control = $FocusPanel/DamageTextLayer
@onready var settlement_panel: Control = $SettlementPanel
@onready var settlement_title_label: Label = $SettlementPanel/TitleLabel
@onready var settlement_result_label: Label = $SettlementPanel/ResultLabel
@onready var settlement_reward_label: Label = $SettlementPanel/RewardLabel
@onready var settlement_continue_button: Button = $SettlementPanel/ContinueButton
@onready var settlement_continue_button_texture: NinePatchRect = $SettlementPanel/ContinueButton/ButtonTexture
@onready var settlement_continue_button_label: Label = $SettlementPanel/ContinueButton/ButtonLabel

var _player_origin: Vector2
var _enemy_origin: Vector2
var _settlement_active: bool = false

func _ready() -> void:
    _load_pixel_assets()
    PixelUIStyle.apply_combat_panel(focus_panel)
    PixelUIStyle.apply_label(title_label, 22, Color(0.96, 0.86, 0.46, 1.0))
    PixelUIStyle.apply_label(player_name_label, 18)
    PixelUIStyle.apply_label(player_hp_label, 16)
    PixelUIStyle.apply_label(enemy_name_label, 18)
    PixelUIStyle.apply_label(enemy_hp_label, 16)
    PixelUIStyle.apply_label(settlement_title_label, 24, Color(0.96, 0.86, 0.46, 1.0))
    PixelUIStyle.apply_label(settlement_result_label, 24, Color(0.96, 0.86, 0.46, 1.0))
    PixelUIStyle.apply_label(settlement_reward_label, 18)
    PixelUIStyle.apply_bar_frame(player_hp_frame)
    PixelUIStyle.apply_bar_frame(enemy_hp_frame)
    _apply_asset_button(settlement_continue_button, settlement_continue_button_texture, settlement_continue_button_label)
    settlement_continue_button.pressed.connect(confirm_settlement)
    _setup_sprite(player_sprite, PLAYER_IDLE_PATH, PLAYER_IDLE_FRAMES, PLAYER_ATTACK_PATH, PLAYER_ATTACK_FRAMES, false)
    _setup_sprite(enemy_sprite, ENEMY_IDLE_PATH, ENEMY_IDLE_FRAMES, ENEMY_ATTACK_PATH, ENEMY_ATTACK_FRAMES, true)
    _player_origin = player_sprite.position
    _enemy_origin = enemy_sprite.position
    CombatManager.battle_started.connect(_on_battle_started)
    CombatManager.combatant_changed.connect(_sync_status)
    CombatManager.damage_dealt.connect(_on_damage_dealt)
    CombatManager.battle_finished.connect(_on_battle_finished)
    visible = false

func _input(event: InputEvent) -> void:
    if not _settlement_active:
        return
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
        confirm_settlement()

func _load_pixel_assets() -> void:
    frame_texture.texture = _load_runtime_texture(UI_FRAME_PATH)
    frame_texture.modulate = Color(0.12, 0.15, 0.10, 1.0)

func _apply_asset_button(button: Button, texture: NinePatchRect, label: Label) -> void:
    var empty_style := StyleBoxEmpty.new()
    for style_name in ["normal", "hover", "pressed", "disabled", "focus"]:
        button.add_theme_stylebox_override(style_name, empty_style)
    button.flat = true
    button.text = ""
    PixelUIStyle.apply_label(label, 20, Color(0.08, 0.11, 0.08, 1.0))
    texture.modulate = Color.WHITE
    button.mouse_entered.connect(func() -> void:
        texture.modulate = Color(1.10, 1.06, 0.92, 1.0)
    )
    button.mouse_exited.connect(func() -> void:
        texture.modulate = Color.WHITE
    )
    button.button_down.connect(func() -> void:
        texture.modulate = Color(0.86, 0.82, 0.72, 1.0)
    )
    button.button_up.connect(func() -> void:
        texture.modulate = Color(1.10, 1.06, 0.92, 1.0) if button.is_hovered() else Color.WHITE
    )

func _on_battle_started(enemy_data: Dictionary) -> void:
    focus_panel.visible = true
    title_label.text = "战斗开始"
    enemy_name_label.text = String(enemy_data.get("enemy_name", "Enemy"))
    player_name_label.text = "你"
    visible = true
    _settlement_active = false
    settlement_panel.visible = false
    focus_panel.modulate.a = 0.0
    _sync_status()
    _play_idle()
    create_tween().tween_property(focus_panel, "modulate:a", 1.0, 0.12)

func _sync_status() -> void:
    if not CombatManager.is_battle_active() and not visible:
        return

    _set_bar_fill(player_hp_bar, player_hp_fill, CombatManager.get_player_hp(), CombatManager.get_player_max_hp())
    player_hp_label.text = "%d/%d" % [CombatManager.get_player_hp(), CombatManager.get_player_max_hp()]
    _set_bar_fill(enemy_hp_bar, enemy_hp_fill, CombatManager.get_enemy_hp(), CombatManager.get_enemy_max_hp())
    enemy_hp_label.text = "%d/%d" % [CombatManager.get_enemy_hp(), CombatManager.get_enemy_max_hp()]

func _on_damage_dealt(event: Dictionary) -> void:
    _sync_status()
    var from_player := String(event.get("source", "")) == CombatManager.COMBATANT_PLAYER
    title_label.text = "你发动攻击" if from_player else "%s 反击" % enemy_name_label.text
    _play_attack(from_player)
    _spawn_damage_text(event, from_player)

func _on_battle_finished(victory: bool) -> void:
    visible = true
    focus_panel.modulate.a = 1.0
    focus_panel.visible = false
    _settlement_active = true
    _clear_damage_text()
    _show_settlement(victory)
    GameManager.change_state(GameManager.GameState.COMBAT)

func confirm_settlement() -> void:
    if not _settlement_active:
        return

    _settlement_active = false
    settlement_panel.visible = false
    visible = false
    focus_panel.visible = true
    focus_panel.modulate.a = 1.0
    _clear_damage_text()
    GameManager.change_state(GameManager.GameState.WORLD)

func _play_idle() -> void:
    player_sprite.position = _player_origin
    enemy_sprite.position = _enemy_origin
    if player_sprite.sprite_frames != null:
        player_sprite.play("idle")
    if enemy_sprite.sprite_frames != null:
        enemy_sprite.play("idle")

func _play_attack(from_player: bool) -> void:
    var attacker := player_sprite if from_player else enemy_sprite
    var defender := enemy_sprite if from_player else player_sprite
    var origin := _player_origin if from_player else _enemy_origin
    var lunge := Vector2(58, 0) if from_player else Vector2(-58, 0)

    if attacker.sprite_frames != null:
        attacker.play("attack")

    var attack_tween := create_tween()
    attack_tween.tween_property(attacker, "position", origin + lunge, 0.08)
    attack_tween.tween_property(attacker, "position", origin, 0.12)
    attack_tween.tween_callback(func() -> void:
        if attacker.sprite_frames != null:
            attacker.play("idle")
    )

    defender.modulate = Color(1.0, 0.64, 0.64, 1.0)
    create_tween().tween_property(defender, "modulate", Color.WHITE, 0.16)

func _spawn_damage_text(event: Dictionary, from_player: bool) -> void:
    var label := Label.new()
    var amount := int(event.get("amount", 0))
    label.text = ("暴击 " if bool(event.get("is_critical", false)) else "") + str(amount)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 34 if bool(event.get("is_critical", false)) else 28)
    label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.28, 1.0) if from_player else Color(1.0, 0.24, 0.18, 1.0))
    label.custom_minimum_size = Vector2(160, 44)
    label.size = label.custom_minimum_size
    label.position = Vector2(334, 76) if from_player else Vector2(86, 76)
    damage_text_layer.add_child(label)

    var tween := create_tween()
    tween.tween_property(label, "position:y", label.position.y - 46.0, 0.55)
    tween.parallel().tween_property(label, "modulate:a", 0.0, 0.55)
    tween.tween_callback(label.queue_free)

func _show_settlement(victory: bool) -> void:
    var result := CombatManager.get_last_battle_result()
    var enemy_name := String(result.get("enemy_name", enemy_name_label.text))
    settlement_title_label.text = "战斗结算"
    settlement_panel.visible = true
    if victory:
        settlement_result_label.text = "你获得了胜利，击败了 %s。" % enemy_name
        settlement_reward_label.text = _format_reward_text(result)
    else:
        settlement_result_label.text = "战斗失败，%s 获得了胜利。" % enemy_name
        settlement_reward_label.text = "玩家倒下了。\n没有获得奖励。"

func _format_reward_text(result: Dictionary) -> String:
    var lines: Array[String] = []
    var gold_reward := int(result.get("gold_reward", 0))
    var experience_reward := int(result.get("experience_reward", 0))
    var item_rewards := Array(result.get("item_rewards", []))
    if gold_reward > 0:
        lines.append("金币 +%d" % gold_reward)
    if experience_reward > 0:
        lines.append("经验 +%d" % experience_reward)
    for reward in item_rewards:
        lines.append(_format_item_reward(Dictionary(reward)))
    if lines.is_empty():
        lines.append("没有额外奖励。")
    return "\n".join(lines)

func _format_item_reward(reward: Dictionary) -> String:
    var item_name := String(reward.get("item_name", reward.get("item_id", "物品")))
    var added := int(reward.get("added", 0))
    var remaining := int(reward.get("remaining", 0))
    if added > 0 and remaining > 0:
        return "物品 +%s x%d（背包满，剩余 %d 未获得）" % [item_name, added, remaining]
    if added > 0:
        return "物品 +%s%s" % [item_name, " x%d" % added if added > 1 else ""]
    if remaining > 0:
        return "背包已满：%s 未获得" % item_name

    return "%s 未获得" % item_name

func _clear_damage_text() -> void:
    for child in damage_text_layer.get_children():
        child.queue_free()

func _setup_sprite(sprite: AnimatedSprite2D, idle_path: String, idle_frames: int, attack_path: String, attack_frames: int, flip_h: bool) -> void:
    var frames := SpriteFrames.new()
    _add_strip_animation(frames, "idle", idle_path, idle_frames, true)
    _add_strip_animation(frames, "attack", attack_path, attack_frames, false)
    sprite.sprite_frames = frames
    sprite.flip_h = flip_h
    sprite.play("idle")

func _add_strip_animation(frames: SpriteFrames, animation_name: StringName, path: String, frame_count: int, loop: bool) -> void:
    var texture := _load_runtime_texture(path)
    if texture == null:
        return

    var frame_size := Vector2(texture.get_height(), texture.get_height())
    frames.add_animation(animation_name)
    frames.set_animation_speed(animation_name, ANIMATION_FPS)
    frames.set_animation_loop(animation_name, loop)

    for frame_index in range(frame_count):
        var frame := AtlasTexture.new()
        frame.atlas = texture
        frame.region = Rect2(Vector2(frame_index * frame_size.x, 0), frame_size)
        frames.add_frame(animation_name, frame)

func _load_runtime_texture(path: String) -> Texture2D:
    var image := Image.new()
    var error := image.load(ProjectSettings.globalize_path(path))
    if error != OK:
        return null

    return ImageTexture.create_from_image(image)

func _set_bar_fill(bar: Control, fill: ColorRect, current: int, maximum: int) -> void:
    var ratio: float = clamp(float(current) / float(max(maximum, 1)), 0.0, 1.0)
    fill.position = Vector2(5, 5)
    fill.size = Vector2(max((bar.size.x - 10.0) * ratio, 0.0), max(bar.size.y - 10.0, 1.0))
