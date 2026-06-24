extends Node

const QUALITY_POOR: int = 0
const QUALITY_COMMON: int = 1
const QUALITY_UNCOMMON: int = 2
const QUALITY_RARE: int = 3
const QUALITY_EPIC: int = 4
const QUALITY_LEGENDARY: int = 5
const QUALITY_ARTIFACT: int = 6
const QUALITY_HEIRLOOM: int = 7
const QUALITY_WOW_TOKEN: int = 8

const TYPE_EQUIPMENT: String = "equipment"
const TYPE_CONSUMABLE: String = "consumable"

const SLOT_WEAPON: String = "weapon"
const SLOT_OFFHAND: String = "offhand"
const SLOT_HEAD: String = "head"
const SLOT_CHEST: String = "chest"
const SLOT_HANDS: String = "hands"
const SLOT_LEGS: String = "legs"
const SLOT_FEET: String = "feet"
const SLOT_AMULET: String = "amulet"
const SLOT_RING: String = "ring"
const SLOT_CLOAK: String = "cloak"
const SLOT_TRINKET: String = "trinket"
const SLOT_RELIC: String = "relic"

const OPEN_EQUIPMENT_SLOTS: Array[String] = [
    SLOT_WEAPON,
    SLOT_OFFHAND,
    SLOT_HEAD,
    SLOT_CHEST,
    SLOT_HANDS,
    SLOT_LEGS,
    SLOT_FEET,
    SLOT_AMULET,
]

const LOCKED_EQUIPMENT_SLOTS: Array[String] = [
    SLOT_RING,
    SLOT_CLOAK,
    SLOT_TRINKET,
    SLOT_RELIC,
]

const QUALITY_DEFINITIONS: Dictionary = {
    QUALITY_POOR: {
        "id": QUALITY_POOR,
        "english": "Poor",
        "name": "粗糙",
        "color": Color("#9d9d9d"),
    },
    QUALITY_COMMON: {
        "id": QUALITY_COMMON,
        "english": "Common",
        "name": "普通",
        "color": Color("#ffffff"),
    },
    QUALITY_UNCOMMON: {
        "id": QUALITY_UNCOMMON,
        "english": "Uncommon",
        "name": "优秀",
        "color": Color("#1eff00"),
    },
    QUALITY_RARE: {
        "id": QUALITY_RARE,
        "english": "Rare",
        "name": "精良",
        "color": Color("#0070dd"),
    },
    QUALITY_EPIC: {
        "id": QUALITY_EPIC,
        "english": "Epic",
        "name": "史诗",
        "color": Color("#a335ee"),
    },
    QUALITY_LEGENDARY: {
        "id": QUALITY_LEGENDARY,
        "english": "Legendary",
        "name": "传说",
        "color": Color("#ff8000"),
    },
    QUALITY_ARTIFACT: {
        "id": QUALITY_ARTIFACT,
        "english": "Artifact",
        "name": "神器",
        "color": Color("#e6cc80"),
    },
    QUALITY_HEIRLOOM: {
        "id": QUALITY_HEIRLOOM,
        "english": "Heirloom",
        "name": "传家宝",
        "color": Color("#00ccff"),
    },
    QUALITY_WOW_TOKEN: {
        "id": QUALITY_WOW_TOKEN,
        "english": "WoW Token",
        "name": "特殊",
        "color": Color("#00ccff"),
    },
}

const ITEMS: Dictionary = {
    "training_sword": {
        "id": "training_sword",
        "name": "训练木剑",
        "type": TYPE_EQUIPMENT,
        "slot": SLOT_WEAPON,
        "quality": QUALITY_COMMON,
        "icon_path": "res://assets/licensed/tiny_swords/ui/icons/Icon_05.png",
        "equipment_type": "单手剑",
        "weapon_damage_min": 4,
        "weapon_damage_max": 7,
        "weapon_speed": 1.8,
        "attributes": {
            "strength": 2,
            "stamina": 1,
        },
        "description": "铁匠送给新手的练习武器。",
    },
    "beginner_shield": {
        "id": "beginner_shield",
        "name": "旧木盾",
        "type": TYPE_EQUIPMENT,
        "slot": SLOT_OFFHAND,
        "quality": QUALITY_COMMON,
        "icon_path": "res://assets/licensed/tiny_swords/ui/icons/Icon_06.png",
        "equipment_type": "盾牌",
        "armor": 9,
        "attributes": {
            "stamina": 1,
        },
        "description": "能挡住最初几次笨拙攻击的木盾。",
    },
    "worn_leather_cap": {
        "id": "worn_leather_cap",
        "name": "旧皮帽",
        "type": TYPE_EQUIPMENT,
        "slot": SLOT_HEAD,
        "quality": QUALITY_POOR,
        "icon_path": "res://assets/licensed/tiny_swords/ui/item_icons/worn_leather_cap.png",
        "equipment_type": "头部",
        "armor": 3,
        "attributes": {
            "stamina": 1,
        },
        "description": "有些磨损，但比什么都没有强。",
    },
    "cloth_tunic": {
        "id": "cloth_tunic",
        "name": "旅行布衣",
        "type": TYPE_EQUIPMENT,
        "slot": SLOT_CHEST,
        "quality": QUALITY_COMMON,
        "icon_path": "res://assets/licensed/tiny_swords/ui/item_icons/cloth_tunic.png",
        "equipment_type": "胸甲",
        "armor": 6,
        "attributes": {
            "stamina": 1,
        },
        "description": "适合第一次离开村庄的轻便衣物。",
    },
    "worn_leather_gloves": {
        "id": "worn_leather_gloves",
        "name": "旧皮手套",
        "type": TYPE_EQUIPMENT,
        "slot": SLOT_HANDS,
        "quality": QUALITY_UNCOMMON,
        "icon_path": "res://assets/licensed/tiny_swords/ui/item_icons/worn_leather_gloves.png",
        "equipment_type": "手套",
        "armor": 4,
        "attributes": {
            "strength": 1,
            "agility": 1,
        },
        "description": "握剑时更稳一些。",
    },
    "patched_trousers": {
        "id": "patched_trousers",
        "name": "补丁长裤",
        "type": TYPE_EQUIPMENT,
        "slot": SLOT_LEGS,
        "quality": QUALITY_COMMON,
        "icon_path": "res://assets/licensed/tiny_swords/ui/item_icons/patched_trousers.png",
        "equipment_type": "腿甲",
        "armor": 5,
        "attributes": {
            "stamina": 1,
        },
        "description": "结实的村民长裤。",
    },
    "scout_boots": {
        "id": "scout_boots",
        "name": "侦察短靴",
        "type": TYPE_EQUIPMENT,
        "slot": SLOT_FEET,
        "quality": QUALITY_UNCOMMON,
        "icon_path": "res://assets/licensed/tiny_swords/ui/item_icons/scout_boots.png",
        "equipment_type": "鞋子",
        "armor": 4,
        "attributes": {
            "agility": 2,
        },
        "description": "走小路时脚步更轻。",
    },
    "apprentice_guard_charm": {
        "id": "apprentice_guard_charm",
        "name": "初心护符",
        "type": TYPE_EQUIPMENT,
        "slot": SLOT_AMULET,
        "quality": QUALITY_RARE,
        "icon_path": "res://assets/licensed/tiny_swords/ui/icons/Icon_11.png",
        "equipment_type": "护符",
        "attributes": {
            "strength": 2,
            "stamina": 2,
        },
        "description": "守护新手勇者的第一枚护符。",
    },
    "minor_healing_potion": {
        "id": "minor_healing_potion",
        "name": "小瓶治疗药水",
        "type": TYPE_CONSUMABLE,
        "quality": QUALITY_COMMON,
        "icon_path": "res://assets/licensed/tiny_swords/ui/icons/Icon_07.png",
        "max_stack": 10,
        "use_effect": {
            "heal": 30,
        },
        "description": "恢复 30 点生命值。",
    },
}

func has_item(item_id: String) -> bool:
    return ITEMS.has(item_id)

func get_item(item_id: String) -> Dictionary:
    if not ITEMS.has(item_id):
        return {}

    return Dictionary(ITEMS[item_id]).duplicate(true)

func get_quality(quality_id: int) -> Dictionary:
    return Dictionary(QUALITY_DEFINITIONS.get(quality_id, QUALITY_DEFINITIONS[QUALITY_COMMON])).duplicate(true)

func get_quality_name(quality_id: int) -> String:
    return String(get_quality(quality_id).get("name", "普通"))

func get_quality_color(quality_id: int) -> Color:
    var value = get_quality(quality_id).get("color", Color.WHITE)
    if value is Color:
        return value

    return Color(String(value))

func get_open_equipment_slots() -> Array[String]:
    return OPEN_EQUIPMENT_SLOTS.duplicate()

func get_locked_equipment_slots() -> Array[String]:
    return LOCKED_EQUIPMENT_SLOTS.duplicate()

func is_equipment(item_id: String) -> bool:
    return String(get_item(item_id).get("type", "")) == TYPE_EQUIPMENT

func is_consumable(item_id: String) -> bool:
    return String(get_item(item_id).get("type", "")) == TYPE_CONSUMABLE

func is_stackable(item_id: String) -> bool:
    return get_stack_limit(item_id) > 1

func get_stack_limit(item_id: String) -> int:
    var item := get_item(item_id)
    if item.is_empty():
        return 0

    if String(item.get("type", "")) == TYPE_CONSUMABLE:
        return max(int(item.get("max_stack", 1)), 1)

    return 1

func get_item_slot(item_id: String) -> String:
    return String(get_item(item_id).get("slot", ""))
