extends Node
## Regression test for adventure village visual structure.

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var expected_nodes := [
        "Visuals",
        "Visuals/Ground",
        "Visuals/MainRoad",
        "Visuals/ExitRoad",
        "Visuals/Houses",
        "Visuals/Trees",
        "Visuals/Signpost",
        "ExitGate/GateVisual",
    ]

    for node_path in expected_nodes:
        assert(village.has_node(node_path), "Missing village visual node: " + node_path)

    assert(village.get_node("Player") != null, "Player must remain in village")
    assert(village.get_node("NPC") != null, "NPC must remain in village")
    assert(village.get_node("ExitGate/CollisionShape2D") != null, "Exit gate collision must remain")

    print("✅ Village visual pass regression test PASSED")
    get_tree().quit()
