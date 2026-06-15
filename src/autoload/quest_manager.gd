extends Node

signal branch_completed(branch_id: String)
signal book_pages_changed(count: int, total: int)
signal forest_gate_ready

const REQUIRED_BOOK_PAGES: int = 3
const BRANCH_IDS: Array[String] = ["library", "blacksmith", "garden"]

var _completed_branches: Dictionary = {}
var _book_pages: int = 0
var _boss_defeated: bool = false

func reset_chapter() -> void:
    _completed_branches.clear()
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
    _book_pages = min(_book_pages + 1, REQUIRED_BOOK_PAGES)
    branch_completed.emit(branch_id)
    book_pages_changed.emit(_book_pages, REQUIRED_BOOK_PAGES)

    if is_forest_gate_ready():
        forest_gate_ready.emit()

func is_branch_completed(branch_id: String) -> bool:
    return _completed_branches.has(branch_id)

func get_book_page_count() -> int:
    return _book_pages

func is_forest_gate_ready() -> bool:
    return _book_pages >= REQUIRED_BOOK_PAGES

func mark_boss_defeated() -> void:
    _boss_defeated = true

func is_boss_defeated() -> bool:
    return _boss_defeated
