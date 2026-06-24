extends Node
## Regression test for adventure village visual structure.

func _ready() -> void:
    var village = load("res://scenes/world/village.tscn").instantiate()
    add_child(village)
    await get_tree().process_frame

    var expected_nodes := [
        "Visuals",
        "VillageHUD",
        "BattlePanel",
        "WordImpBoss",
        "Visuals/Ground",
        "Visuals/MainRoad",
        "Visuals/HouseRoads",
        "Visuals/ExitRoad",
        "Visuals/Houses",
        "Visuals/Trees",
        "Visuals/BranchAnchors",
        "Visuals/Signpost",
        "ExitGate/GateVisual",
    ]

    for node_path in expected_nodes:
        assert(village.has_node(node_path), "Missing village visual node: " + node_path)

    assert(village.get_node("Player") != null, "Player must remain in village")
    assert(village.get_node("LibraryNPC") != null, "Library NPC must remain in village")
    assert(village.get_node("BlacksmithNPC") != null, "Blacksmith NPC must remain in village")
    assert(village.get_node("GardenNPC") != null, "Garden NPC must remain in village")
    assert(village.get_node("LibraryNPC/InteractionMarker") != null, "NPC interaction marker must remain")
    assert(village.get_node("ExitGate/CollisionShape2D") != null, "Exit gate collision must remain")
    assert(
        AudioManager.get_music_stream_path() == "res://assets/audio/bgm/village_theme_draft_01.mp3",
        "Village should start the draft village BGM"
    )

    print("✅ Village visual pass regression test PASSED")
    AudioManager.stop_music()
    village.queue_free()
    await get_tree().process_frame
    get_tree().quit()
