extends Node

func _ready() -> void:
    QuestManager.reset_chapter()

    assert(QuestManager.get_book_page_count() == 0, "Chapter should start with zero pages")
    assert(not QuestManager.is_branch_completed("library"), "Library branch should start incomplete")
    assert(not QuestManager.is_forest_gate_ready(), "Forest gate should start locked")

    QuestManager.complete_branch("library")
    assert(QuestManager.is_branch_completed("library"), "Library branch should be completed")
    assert(QuestManager.get_book_page_count() == 1, "One branch should grant one page")
    if AudioManager.get_last_sfx_stream_path() != AudioManager.SFX_QUEST_REWARD:
        _fail("Completing a branch should play quest reward SFX")
        return

    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")
    assert(QuestManager.get_book_page_count() == 3, "Three branches should grant three pages")
    assert(QuestManager.is_forest_gate_ready(), "Forest gate should unlock at three pages")

    QuestManager.complete_branch("garden")
    assert(QuestManager.get_book_page_count() == 3, "Completing the same branch twice should be idempotent")

    print("Quest manager regression test PASSED")
    get_tree().quit()

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
