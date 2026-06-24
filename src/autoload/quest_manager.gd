extends Node

signal branch_completed(branch_id: String)
signal book_pages_changed(count: int, total: int)
signal forest_gate_ready

const REQUIRED_BOOK_PAGES: int = 3
const BRANCH_IDS: Array[String] = ["library", "blacksmith", "garden"]
const BRANCH_ITEM_REWARDS: Dictionary = {
    "library": [
        {"item_id": "cloth_tunic", "quantity": 1},
    ],
    "blacksmith": [
        {"item_id": "training_sword", "quantity": 1},
    ],
    "garden": [
        {"item_id": "beginner_shield", "quantity": 1},
        {"item_id": "minor_healing_potion", "quantity": 2},
    ],
}

var _completed_branches: Dictionary = {}
var _branch_reward_results: Dictionary = {}
var _book_pages: int = 0
var _boss_defeated: bool = false

func reset_chapter() -> void:
    _completed_branches.clear()
    _branch_reward_results.clear()
    _book_pages = 0
    _boss_defeated = false
    book_pages_changed.emit(_book_pages, REQUIRED_BOOK_PAGES)

func complete_branch(branch_id: String) -> void:
    if not BRANCH_IDS.has(branch_id):
        push_warning("Unknown branch id: " + branch_id)
        return
    if _completed_branches.has(branch_id):
        return

    _completed_branches[branch_id] = true
    _branch_reward_results[branch_id] = PlayerData.add_item_rewards(get_branch_item_rewards(branch_id))
    _book_pages = min(_book_pages + 1, REQUIRED_BOOK_PAGES)
    AudioManager.play_sfx_path(AudioManager.SFX_QUEST_REWARD)
    branch_completed.emit(branch_id)
    book_pages_changed.emit(_book_pages, REQUIRED_BOOK_PAGES)

    if is_forest_gate_ready():
        forest_gate_ready.emit()

func is_branch_completed(branch_id: String) -> bool:
    return _completed_branches.has(branch_id)

func get_branch_item_rewards(branch_id: String) -> Array[Dictionary]:
    return _copy_reward_list(Array(BRANCH_ITEM_REWARDS.get(branch_id, [])))

func get_branch_reward_results(branch_id: String) -> Array[Dictionary]:
    return _copy_reward_list(Array(_branch_reward_results.get(branch_id, [])))

func get_book_page_count() -> int:
    return _book_pages

func is_forest_gate_ready() -> bool:
    return _book_pages >= REQUIRED_BOOK_PAGES

func mark_boss_defeated() -> void:
    _boss_defeated = true

func is_boss_defeated() -> bool:
    return _boss_defeated

func _copy_reward_list(source: Array) -> Array[Dictionary]:
    var rewards: Array[Dictionary] = []
    for reward in source:
        rewards.append(Dictionary(reward).duplicate(true))

    return rewards
