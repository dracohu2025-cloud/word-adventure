extends CanvasLayer

@onready var page_label: Label = $Panel/PageLabel
@onready var reward_label: Label = $Panel/RewardLabel

func _ready() -> void:
    QuestManager.book_pages_changed.connect(_on_book_pages_changed)
    QuestManager.branch_completed.connect(_on_branch_completed)
    _on_book_pages_changed(QuestManager.get_book_page_count(), QuestManager.REQUIRED_BOOK_PAGES)

func _on_book_pages_changed(count: int, total: int) -> void:
    page_label.text = "Book Pages: %d/%d" % [count, total]

func _on_branch_completed(branch_id: String) -> void:
    reward_label.text = _reward_text(branch_id)

func _reward_text(branch_id: String) -> String:
    match branch_id:
        "library":
            return "Book Page restored"
        "blacksmith":
            return "Beginner Charm obtained"
        "garden":
            return "Potion obtained"
    return ""
