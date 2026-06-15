extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")

    CombatManager.start_boss_battle("word_imp")
    assert(CombatManager.is_battle_active(), "Word Imp boss battle should start")
    assert(not CombatManager.is_capture_available(), "Capture should not be available at full HP")

    var enemy_data := CombatManager.get_enemy_data()
    var skill_words: Dictionary = enemy_data.get("skill_words", {})
    assert(skill_words.get("attack", "") == "sword", "Attack should use the learned weapon word")
    assert(skill_words.get("shield", "") == "shield", "Shield should use the learned defense word")
    assert(skill_words.get("capture", "") == "book", "Capture should use the learned magic book word")

    while CombatManager.get_enemy_hp() > 4:
        CombatManager.apply_answer_result(true, "attack")

    assert(CombatManager.is_capture_available(), "Capture should become available when boss is weakened")
    CombatManager.apply_answer_result(true, "attack")
    assert(CombatManager.is_battle_active(), "Boss should require capture instead of dying to attacks")
    assert(CombatManager.get_enemy_hp() == 4, "Attacks should not reduce the boss below capture HP")

    CombatManager.apply_answer_result(true, "capture")

    assert(QuestManager.is_boss_defeated(), "Correct capture should defeat the boss")
    assert(not CombatManager.is_battle_active(), "Boss battle should end after capture")

    print("Word Imp boss regression test PASSED")
    get_tree().quit()
