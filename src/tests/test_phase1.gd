extends Node
## Regression test for Phase 1: dialogue -> choice puzzle -> open gate loop.

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame
    assert(GameManager.current_state == GameManager.GameState.WORLD, "Village should enter world state")

    var npc = village.get_node("NPC")
    assert(npc != null, "NPC not found")

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
    await get_tree().create_timer(0.1).timeout

    var gate_collision = village.get_node("ExitGate/CollisionShape2D")
    assert(gate_collision.disabled, "Exit gate should open after correct answer")
    assert(GameManager.current_state == GameManager.GameState.WORLD, "Should return to world state")

    print("✅ Phase 1 regression test PASSED")
    get_tree().quit()
