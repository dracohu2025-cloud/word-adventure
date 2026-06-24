extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var turn_label: Label = $Panel/TurnLabel
@onready var enemy_name_label: Label = $Panel/EnemyNameLabel
@onready var enemy_hp_label: Label = $Panel/EnemyHPLabel
@onready var player_hp_label: Label = $Panel/PlayerHPLabel
@onready var enemy_sprite: TextureRect = $Panel/EnemySprite
@onready var intent_label: Label = $Panel/IntentLabel
@onready var question_label: Label = $Panel/QuestionLabel
@onready var options_container: HBoxContainer = $Panel/OptionsContainer
@onready var attack_button: Button = $Panel/SkillRow/AttackButton
@onready var shield_button: Button = $Panel/SkillRow/ShieldButton
@onready var capture_button: Button = $Panel/SkillRow/CaptureButton
@onready var feedback_label: Label = $Panel/FeedbackLabel

var _selected_skill: String = "attack"
var _current_answer: String = ""
var _current_challenge: Dictionary = {}
var _current_enemy_data: Dictionary = {}

func _ready() -> void:
    panel.visible = false
    attack_button.text = "sword 攻击"
    shield_button.text = "shield 防御"
    capture_button.text = "book 收服"
    attack_button.pressed.connect(_select_skill.bind("attack"))
    shield_button.pressed.connect(_select_skill.bind("shield"))
    capture_button.pressed.connect(_select_skill.bind("capture"))
    capture_button.disabled = true
    CombatManager.battle_started.connect(_on_battle_started)
    CombatManager.battle_changed.connect(_sync_status)
    CombatManager.battle_finished.connect(_on_battle_finished)
    GameManager.state_changed.connect(_on_state_changed)

func _on_battle_started(enemy_data: Dictionary) -> void:
    if CombatManager.get_turn_phase() == CombatManager.PHASE_REAL_TIME:
        _current_answer = ""
        _current_challenge.clear()
        _current_enemy_data = enemy_data.duplicate(true)
        panel.visible = false
        return

    _selected_skill = "attack"
    _current_enemy_data = enemy_data.duplicate(true)
    feedback_label.text = CombatManager.get_last_combat_log()
    panel.visible = true
    _sync_enemy_sprite(enemy_data)
    _build_challenge_for_skill(_selected_skill)
    _sync_status()

func _on_state_changed(_state) -> void:
    panel.visible = (
        GameManager.current_state == GameManager.GameState.COMBAT
        and CombatManager.is_battle_active()
        and CombatManager.get_turn_phase() != CombatManager.PHASE_REAL_TIME
    )

func _on_battle_finished(victory: bool) -> void:
    feedback_label.text = "战斗胜利！" if victory else "战斗结束。"
    panel.visible = false

func _select_skill(skill_id: String) -> void:
    if not CombatManager.can_select_skill(skill_id):
        return

    _selected_skill = skill_id
    _build_challenge_for_skill(_selected_skill)
    _sync_status()

func _build_challenge_for_skill(skill_id: String) -> void:
    var enemy_data := CombatManager.get_enemy_data()
    if enemy_data.is_empty():
        enemy_data = _current_enemy_data

    var skill_words: Dictionary = enemy_data.get("skill_words", {})
    var skill_challenge_types: Dictionary = enemy_data.get("skill_challenge_types", {})
    var word := String(skill_words.get(skill_id, enemy_data.get("question_word", "monster")))
    var challenge_type := String(skill_challenge_types.get(skill_id, enemy_data.get("challenge_type", "meaning")))
    _current_challenge = WordBank.build_challenge(word, challenge_type)
    _current_answer = String(_current_challenge.get("answer", word))
    question_label.text = _current_challenge.get("question", "Choose the correct word.")
    _render_options(_current_challenge.get("options", [_current_answer]))

func _render_options(options: Array) -> void:
    for child in options_container.get_children():
        child.queue_free()

    for option in options:
        var button := Button.new()
        button.text = String(option)
        button.custom_minimum_size = Vector2(120, 42)
        button.pressed.connect(_on_option_selected.bind(String(option)))
        options_container.add_child(button)

func _on_option_selected(option: String) -> void:
    if not CombatManager.can_select_skill(_selected_skill):
        return

    var correct := option.strip_edges().to_lower() == _current_answer.strip_edges().to_lower()
    CombatManager.apply_answer_result(correct, _selected_skill)
    _sync_status()

    if CombatManager.is_battle_active():
        if not CombatManager.can_select_skill(_selected_skill):
            _selected_skill = "attack"
        if CombatManager.can_select_skill(_selected_skill):
            _build_challenge_for_skill(_selected_skill)

func _sync_status() -> void:
    var turn_phase := CombatManager.get_turn_phase()
    if turn_phase == CombatManager.PHASE_REAL_TIME:
        panel.visible = false
        return

    match turn_phase:
        CombatManager.PHASE_VICTORY:
            turn_label.text = "战斗胜利"
        CombatManager.PHASE_DEFEAT:
            turn_label.text = "战斗失败"
        _:
            turn_label.text = "战斗"

    enemy_name_label.text = CombatManager.get_enemy_name()
    enemy_hp_label.text = "怪物 HP：%d/%d" % [
        CombatManager.get_enemy_hp(),
        CombatManager.get_enemy_max_hp(),
    ]
    player_hp_label.text = "玩家 HP：%d/%d" % [
        CombatManager.get_player_hp(),
        CombatManager.get_player_max_hp(),
    ]
    var enemy_intent := CombatManager.get_enemy_intent()
    intent_label.text = "敌人意图：%s" % String(enemy_intent.get("label", "观察中"))
    feedback_label.text = CombatManager.get_last_combat_log()
    attack_button.disabled = not CombatManager.can_select_skill("attack")
    shield_button.disabled = not CombatManager.can_select_skill("shield")
    capture_button.disabled = not CombatManager.can_select_skill("capture")

func _sync_enemy_sprite(enemy_data: Dictionary) -> void:
    var sprite_path := String(enemy_data.get("sprite_path", ""))
    if sprite_path.is_empty():
        enemy_sprite.texture = null
        enemy_sprite.visible = false
        return

    enemy_sprite.texture = load(sprite_path)
    enemy_sprite.visible = enemy_sprite.texture != null
