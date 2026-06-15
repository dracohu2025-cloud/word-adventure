extends Node

signal battle_started(enemy_data: Dictionary)
signal battle_changed
signal battle_finished(victory: bool)

const DEFAULT_PLAYER_ATTACK_DAMAGE: int = 4
const DEFAULT_ENEMY_ATTACK_DAMAGE: int = 3
const DEFAULT_SHIELD_BLOCK: int = 3
const DEFAULT_BOSS_CAPTURE_HP: int = 4

var _active: bool = false
var _enemy: Dictionary = {}
var _enemy_hp: int = 0
var _enemy_max_hp: int = 0
var _player_hp: int = 0
var _player_max_hp: int = 0
var _enemy_attack_damage: int = DEFAULT_ENEMY_ATTACK_DAMAGE
var _boss_id: String = ""

func start_battle(enemy_data: Dictionary) -> void:
    _active = true
    _enemy = enemy_data.duplicate(true)
    _boss_id = String(enemy_data.get("enemy_id", "")) if bool(enemy_data.get("is_boss", false)) else ""
    _enemy_max_hp = int(enemy_data.get("enemy_hp", 10))
    _enemy_hp = _enemy_max_hp
    _player_max_hp = int(enemy_data.get("player_hp", 20))
    _player_hp = _player_max_hp
    _enemy_attack_damage = int(enemy_data.get("enemy_attack_damage", DEFAULT_ENEMY_ATTACK_DAMAGE))
    GameManager.change_state(GameManager.GameState.COMBAT)
    battle_started.emit(_enemy)
    battle_changed.emit()

func start_boss_battle(boss_id: String) -> void:
    if boss_id != "word_imp":
        push_warning("Unknown boss id: " + boss_id)
        return

    start_battle({
        "enemy_id": boss_id,
        "enemy_name": "Word Imp",
        "enemy_hp": 24,
        "player_hp": 24,
        "enemy_attack_damage": 3,
        "is_boss": true,
        "capture_hp": DEFAULT_BOSS_CAPTURE_HP,
        "question_word": "sword",
        "challenge_type": "meaning",
        "skill_words": {
            "attack": "sword",
            "shield": "shield",
            "capture": "book",
        },
        "skill_challenge_types": {
            "attack": "meaning",
            "shield": "meaning",
            "capture": "meaning",
        },
        "sprite_path": "res://assets/third_party/kenney_tiny_dungeon/Tiles/tile_0110.png",
    })

func apply_answer_result(correct: bool, skill_id: String) -> void:
    if not _active:
        return

    match skill_id:
        "capture":
            _apply_capture_result(correct)
        "shield":
            _apply_shield_result(correct)
        _:
            _apply_attack_result(correct)

func end_battle() -> void:
    _finish(false)

func is_capture_available() -> bool:
    return _active and bool(_enemy.get("is_boss", false)) and _enemy_hp <= _get_capture_hp()

func is_battle_active() -> bool:
    return _active

func get_enemy_hp() -> int:
    return _enemy_hp

func get_enemy_max_hp() -> int:
    return _enemy_max_hp

func get_player_hp() -> int:
    return _player_hp

func get_player_max_hp() -> int:
    return _player_max_hp

func get_enemy_data() -> Dictionary:
    return _enemy.duplicate(true)

func get_enemy_name() -> String:
    return _enemy.get("enemy_name", "Enemy")

func _apply_attack_result(correct: bool) -> void:
    if correct:
        _damage_enemy(DEFAULT_PLAYER_ATTACK_DAMAGE)
        if _enemy_hp <= 0:
            battle_changed.emit()
            _finish(true)
            return

    _apply_enemy_turn(0)
    battle_changed.emit()

    if _player_hp <= 0:
        _finish(false)

func _apply_shield_result(correct: bool) -> void:
    var block_amount := DEFAULT_SHIELD_BLOCK if correct else 0
    _apply_enemy_turn(block_amount)
    battle_changed.emit()

    if _player_hp <= 0:
        _finish(false)

func _apply_capture_result(correct: bool) -> void:
    if not is_capture_available():
        _apply_enemy_turn(0)
        battle_changed.emit()
        if _player_hp <= 0:
            _finish(false)
        return

    if correct:
        if _boss_id == "word_imp":
            QuestManager.mark_boss_defeated()
        _finish(true)
    else:
        _enemy_hp = min(_enemy_hp + DEFAULT_PLAYER_ATTACK_DAMAGE, _enemy_max_hp)
        _apply_enemy_turn(0)
        battle_changed.emit()
        if _player_hp <= 0:
            _finish(false)

func _damage_enemy(amount: int) -> void:
    if bool(_enemy.get("is_boss", false)):
        _enemy_hp = max(_enemy_hp - amount, _get_capture_hp())
    else:
        _enemy_hp = max(_enemy_hp - amount, 0)

func _apply_enemy_turn(block_amount: int) -> void:
    var damage: int = max(_enemy_attack_damage - block_amount, 0)
    _player_hp = max(_player_hp - damage, 0)

func _get_capture_hp() -> int:
    return int(_enemy.get("capture_hp", DEFAULT_BOSS_CAPTURE_HP))

func _finish(victory: bool) -> void:
    if not _active:
        return

    _active = false
    _boss_id = ""
    GameManager.change_state(GameManager.GameState.WORLD)
    battle_finished.emit(victory)
