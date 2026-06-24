extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    PlayerData.reset_runtime_state()
    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")

    CombatManager.start_boss_battle("word_imp")
    assert(CombatManager.is_battle_active(), "Word Imp boss battle should start")
    assert(CombatManager.get_turn_phase() == CombatManager.PHASE_REAL_TIME, "Boss battle should be real-time")
    assert(not CombatManager.is_capture_available(), "Real-time combat should not use capture answers")
    assert(CombatManager.get_enemy_max_hp() == 180, "Word Imp should use real-time boss HP")

    _advance_until_battle_ends()

    assert(QuestManager.is_boss_defeated(), "Defeating the Word Imp should mark boss defeated")
    assert(not CombatManager.is_battle_active(), "Boss battle should end after HP reaches zero")
    assert(PlayerData.gold >= 12, "Boss victory should grant gold")
    assert(PlayerData.experience >= 25, "Boss victory should grant experience")

    print("Word Imp boss regression test PASSED")
    get_tree().quit()

func _advance_until_battle_ends() -> void:
    var steps := 0
    while CombatManager.is_battle_active() and steps < 120:
        CombatManager.advance_battle(0.5)
        steps += 1
    assert(steps < 120, "Boss battle should resolve within the test budget")
