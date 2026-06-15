extends Node

func _ready() -> void:
    WordBank.load_pack("res://data/vocabulary/village_a1.json")

    var meaning := WordBank.build_challenge("forest", "meaning")
    assert(meaning.get("challenge_type") == "meaning", "Meaning challenge type should be set")
    assert(meaning.get("answer") == "forest", "Meaning answer should be the English word")
    assert(meaning.get("options", []).size() >= 3, "Meaning challenge should provide options")

    var spelling := WordBank.build_challenge("sword", "spelling")
    assert(spelling.get("challenge_type") == "spelling", "Spelling challenge type should be set")
    assert(spelling.get("answer") == "sword", "Spelling answer should be the English word")

    var context := WordBank.build_challenge("water", "context")
    assert(context.get("challenge_type") == "context", "Context challenge type should be set")
    assert(context.get("question", "").contains("____"), "Context challenge should include a blank")

    print("Vocabulary challenge type regression test PASSED")
    get_tree().quit()
