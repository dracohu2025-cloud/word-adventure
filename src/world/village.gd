extends Node2D

const VILLAGE_BGM_PATH: String = "res://assets/audio/bgm/village_theme_draft_01.mp3"

@onready var exit_gate: StaticBody2D = $ExitGate
@onready var exit_collision: CollisionShape2D = $ExitGate/CollisionShape2D
@onready var word_imp_boss = $WordImpBoss

func _ready() -> void:
    GameManager.change_state(GameManager.GameState.WORLD)
    AudioManager.play_music_path(VILLAGE_BGM_PATH)
    QuestManager.forest_gate_ready.connect(_on_forest_gate_ready)
    CombatManager.battle_finished.connect(_on_battle_finished)
    word_imp_boss.set_available(QuestManager.is_forest_gate_ready() and not QuestManager.is_boss_defeated())

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

func open_exit() -> void:
    exit_collision.set_deferred("disabled", true)
    exit_gate.modulate = Color(1, 1, 1, 0.3)
    print("Exit gate opened!")
