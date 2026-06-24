extends Node
## Regression test for Phase 1: dialogue -> choice puzzle -> open gate loop.

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    assert(GameManager.current_state == GameManager.GameState.WORLD, "Village should enter world state")

    var npc = village.get_node("LibraryNPC")
    assert(npc != null, "NPC not found")
    var player: CharacterBody2D = village.get_node("Player")
    var interaction_marker: CanvasItem = npc.get_node("InteractionMarker")
    var hint_panel: Control = ControlHints.get_node("Panel")
    player.global_position = npc.global_position + Vector2(260, 0)
    await get_tree().physics_frame
    await get_tree().physics_frame
    assert(not interaction_marker.visible, "NPC interaction marker should be hidden before player approaches")
    assert(not hint_panel.visible, "Contextual prompt should be hidden before player approaches")

    player.global_position = npc.global_position + Vector2(0, 48)
    await get_tree().physics_frame
    await get_tree().physics_frame
    assert(not interaction_marker.visible, "NPC exclamation marker should stay hidden when contextual prompt is available")
    assert(hint_panel.visible, "Contextual prompt should be visible before dialogue is completed")

    print("Starting Phase 1 regression test...")
    npc.start_interaction()
    assert(GameManager.current_state == GameManager.GameState.DIALOGUE, "Should enter dialogue state")

    # Advance through all 3 dialogue lines
    for i in range(3):
        assert(GameManager.current_state == GameManager.GameState.DIALOGUE, "Should stay in dialogue state during lines")
        DialogueManager.advance()
        await get_tree().create_timer(0.05).timeout

    assert(GameManager.current_state == GameManager.GameState.PUZZLE, "Should enter puzzle state after dialogue")
    print("Puzzle question: ", ChoicePuzzle.question_label.text)

    # Solve the puzzle
    ChoicePuzzle._on_option_selected(npc.puzzle_answer)
    await get_tree().process_frame

    assert(GameManager.current_state == GameManager.GameState.DIALOGUE, "Puzzle result should return to NPC dialogue")
    assert(DialogueManager.get_speaker() == npc.npc_name, "NPC should speak the puzzle result")
    assert(DialogueManager.get_body() == npc.success_line.get_slice("：", 1), "NPC should explain the correct answer")
    DialogueManager.advance()
    await get_tree().process_frame

    var gate_collision = village.get_node("ExitGate/CollisionShape2D")
    assert(not gate_collision.disabled, "Exit gate should stay closed after one branch")
    assert(GameManager.current_state == GameManager.GameState.WORLD, "Should return to world state")
    assert(npc.is_dialogue_completed(), "NPC should be marked completed after the correct answer")
    assert(QuestManager.is_branch_completed("library"), "Library branch should complete after correct answer")
    assert(QuestManager.get_book_page_count() == 1, "Completing one branch should grant one page")
    assert(not interaction_marker.visible, "NPC interaction marker should hide after dialogue is completed")
    assert(not hint_panel.visible, "Contextual prompt should hide after dialogue is completed")
    await get_tree().process_frame

    print("✅ Phase 1 regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
