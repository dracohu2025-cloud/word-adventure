extends Node

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var expected_npcs := [
        "LibraryNPC",
        "BlacksmithNPC",
        "GardenNPC",
    ]

    for npc_name in expected_npcs:
        assert(village.has_node(npc_name), "Village should include branch NPC: " + npc_name)
        var npc: Node = village.get_node(npc_name)
        assert(npc.get("quest_id") != "", npc_name + " should have a quest id")

    assert(QuestManager.get_book_page_count() == 0, "Village should start with zero book pages")

    await _complete_choice_branch(village.get_node("GardenNPC"), "shield")
    assert(QuestManager.is_branch_completed("garden"), "Garden branch should complete")

    await _complete_spelling_branch(village.get_node("BlacksmithNPC"), "sword")
    assert(QuestManager.is_branch_completed("blacksmith"), "Blacksmith branch should complete")

    await _complete_choice_branch(village.get_node("LibraryNPC"), "book")
    assert(QuestManager.is_branch_completed("library"), "Library branch should complete")
    assert(QuestManager.get_book_page_count() == 3, "Three completed branches should restore three pages")
    assert(QuestManager.is_forest_gate_ready(), "Three completed branches should ready the forest gate")
    var boss = village.get_node("WordImpBoss")
    assert(boss.is_available(), "Completing three branches should reveal the Word Imp boss")
    assert(not CombatManager.is_battle_active(), "Completing three branches should not auto-start the boss")

    boss.start_interaction()
    assert(CombatManager.is_battle_active(), "Interacting with Word Imp should start the boss")
    assert(CombatManager.get_enemy_name() == "Word Imp", "Forest gate encounter should be the Word Imp boss")
    CombatManager.end_battle()

    print("Village three-branch regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _complete_choice_branch(npc: Node, answer: String) -> void:
    npc.start_interaction()
    await _advance_dialogue_lines(3)
    assert(GameManager.current_state == GameManager.GameState.PUZZLE, "Branch should request a puzzle")
    ChoicePuzzle._on_option_selected(answer)
    await get_tree().create_timer(1.6).timeout

func _complete_spelling_branch(npc: Node, answer: String) -> void:
    npc.start_interaction()
    await _advance_dialogue_lines(3)
    assert(GameManager.current_state == GameManager.GameState.PUZZLE, "Branch should request a spelling puzzle")
    ChoicePuzzle.spelling_input.text = answer
    ChoicePuzzle._on_submit_pressed()
    await get_tree().create_timer(1.6).timeout

func _advance_dialogue_lines(count: int) -> void:
    for i in range(count):
        DialogueManager.advance()
        await get_tree().create_timer(0.05).timeout
