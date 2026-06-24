extends Node

signal stats_changed
signal inventory_changed
signal equipment_changed

const DEFAULT_LEVEL: int = 1
const DEFAULT_EXPERIENCE: int = 0
const DEFAULT_MAX_HP: int = 120
const DEFAULT_MAX_MP: int = 40
const DEFAULT_GOLD: int = 0
const DEFAULT_ATTACK_POWER: int = 18
const DEFAULT_DEFENSE: int = 8
const DEFAULT_ATTACK_SPEED: float = 1.3
const DEFAULT_CRIT_CHANCE: float = 0.1
const DEFAULT_CRIT_MULTIPLIER: float = 1.5
const DEFAULT_STRENGTH: int = 10
const DEFAULT_AGILITY: int = 8
const DEFAULT_INTELLECT: int = 6
const DEFAULT_STAMINA: int = 12
const DEFAULT_SPIRIT: int = 8
const INVENTORY_SLOT_COUNT: int = 20

var player_name: String = "Apprentice"
var level: int = DEFAULT_LEVEL
var experience: int = DEFAULT_EXPERIENCE
var vocation: String = "warrior"
var max_hp: int = DEFAULT_MAX_HP
var hp: int = DEFAULT_MAX_HP
var max_mp: int = DEFAULT_MAX_MP
var mp: int = DEFAULT_MAX_MP
var gold: int = DEFAULT_GOLD
var attack_power: int = DEFAULT_ATTACK_POWER
var defense: int = DEFAULT_DEFENSE
var attack_speed: float = DEFAULT_ATTACK_SPEED
var crit_chance: float = DEFAULT_CRIT_CHANCE
var crit_multiplier: float = DEFAULT_CRIT_MULTIPLIER

# Primary attributes
var strength: int = DEFAULT_STRENGTH
var agility: int = DEFAULT_AGILITY
var intellect: int = DEFAULT_INTELLECT
var stamina: int = DEFAULT_STAMINA
var spirit: int = DEFAULT_SPIRIT

# Equipment & inventory
var inventory: Array[Dictionary] = []
var equipment: Dictionary = {}

# Vocabulary progress: word -> { mastery, next_review }
var vocabulary: Dictionary = {}

func _ready() -> void:
    _ensure_inventory_slots()
    _recalculate_derived_stats(true)
    print("PlayerData initialized")

func add_experience(amount: int) -> void:
    experience += amount
    # TODO: level up logic
    stats_changed.emit()

func reset_runtime_state() -> void:
    level = DEFAULT_LEVEL
    experience = DEFAULT_EXPERIENCE
    max_hp = DEFAULT_MAX_HP
    hp = DEFAULT_MAX_HP
    max_mp = DEFAULT_MAX_MP
    mp = DEFAULT_MAX_MP
    gold = DEFAULT_GOLD
    attack_power = DEFAULT_ATTACK_POWER
    defense = DEFAULT_DEFENSE
    attack_speed = DEFAULT_ATTACK_SPEED
    crit_chance = DEFAULT_CRIT_CHANCE
    crit_multiplier = DEFAULT_CRIT_MULTIPLIER
    strength = DEFAULT_STRENGTH
    agility = DEFAULT_AGILITY
    intellect = DEFAULT_INTELLECT
    stamina = DEFAULT_STAMINA
    spirit = DEFAULT_SPIRIT
    inventory.clear()
    equipment.clear()
    _ensure_inventory_slots()
    _recalculate_derived_stats(true)
    inventory_changed.emit()
    equipment_changed.emit()
    stats_changed.emit()

func restore_full_resources() -> void:
    hp = max_hp
    mp = max_mp
    stats_changed.emit()

func apply_damage(amount: int) -> void:
    hp = max(hp - max(amount, 0), 0)
    stats_changed.emit()

func add_gold(amount: int) -> void:
    gold = max(gold + amount, 0)
    stats_changed.emit()

func get_inventory_slots() -> Array[Dictionary]:
    _ensure_inventory_slots()
    return inventory.duplicate(true)

func get_equipped_item(slot: String) -> Dictionary:
    var item_id := String(equipment.get(slot, ""))
    if item_id.is_empty():
        return {}

    return ItemDatabase.get_item(item_id)

func get_total_attributes() -> Dictionary:
    var totals := {
        "strength": strength,
        "agility": agility,
        "intellect": intellect,
        "stamina": stamina,
        "spirit": spirit,
    }
    for item_id in equipment.values():
        var item := ItemDatabase.get_item(String(item_id))
        var attributes := Dictionary(item.get("attributes", {}))
        for key in totals.keys():
            totals[key] = int(totals[key]) + int(attributes.get(key, 0))

    return totals

func get_equipment_stat_bonus() -> Dictionary:
    var totals := {
        "armor": 0,
        "weapon_damage_min": 0,
        "weapon_damage_max": 0,
        "weapon_average_damage": 0.0,
    }
    for item_id in equipment.values():
        var item := ItemDatabase.get_item(String(item_id))
        totals["armor"] = int(totals["armor"]) + int(item.get("armor", 0))
        if String(item.get("slot", "")) == ItemDatabase.SLOT_WEAPON:
            var min_damage := int(item.get("weapon_damage_min", 0))
            var max_damage := int(item.get("weapon_damage_max", min_damage))
            totals["weapon_damage_min"] = min_damage
            totals["weapon_damage_max"] = max_damage
            totals["weapon_average_damage"] = (float(min_damage) + float(max_damage)) / 2.0

    return totals

func add_item(item_id: String, quantity: int = 1) -> Dictionary:
    _ensure_inventory_slots()
    if quantity <= 0:
        return _item_result(false, item_id, 0, quantity, "invalid_quantity")
    if not ItemDatabase.has_item(item_id):
        return _item_result(false, item_id, 0, quantity, "unknown_item")

    var remaining := quantity
    var added := 0
    var stack_limit := ItemDatabase.get_stack_limit(item_id)
    if stack_limit > 1:
        for index in range(inventory.size()):
            if remaining <= 0:
                break
            var entry := _slot_entry(index)
            if String(entry.get("item_id", "")) != item_id:
                continue
            var current_quantity := int(entry.get("quantity", 0))
            if current_quantity >= stack_limit:
                continue
            var to_add = min(stack_limit - current_quantity, remaining)
            entry["quantity"] = current_quantity + to_add
            inventory[index] = entry
            remaining -= to_add
            added += to_add

    while remaining > 0:
        var empty_index := _find_empty_slot()
        if empty_index == -1:
            break
        var stack_quantity = min(stack_limit, remaining) if stack_limit > 1 else 1
        inventory[empty_index] = {
            "item_id": item_id,
            "quantity": stack_quantity,
        }
        remaining -= stack_quantity
        added += stack_quantity

    if added > 0:
        inventory_changed.emit()

    return _item_result(remaining == 0, item_id, added, remaining, "inventory_full" if remaining > 0 else "")

func add_item_rewards(rewards: Array) -> Array[Dictionary]:
    var results: Array[Dictionary] = []
    for reward in rewards:
        var reward_data := Dictionary(reward)
        var item_id := String(reward_data.get("item_id", ""))
        var quantity := int(reward_data.get("quantity", 1))
        var result := add_item(item_id, quantity)
        var item := ItemDatabase.get_item(item_id)
        result["quantity"] = quantity
        result["item_name"] = String(item.get("name", item_id))
        result["quality"] = int(item.get("quality", ItemDatabase.QUALITY_COMMON))
        result["quality_name"] = ItemDatabase.get_quality_name(int(result.get("quality", ItemDatabase.QUALITY_COMMON)))
        results.append(result)

    return results

func equip_item(inventory_index: int) -> Dictionary:
    _ensure_inventory_slots()
    if inventory_index < 0 or inventory_index >= inventory.size():
        return _operation_result(false, "invalid_slot")

    var entry := _slot_entry(inventory_index)
    var item_id := String(entry.get("item_id", ""))
    if item_id.is_empty():
        return _operation_result(false, "empty_slot")
    var item := ItemDatabase.get_item(item_id)
    if String(item.get("type", "")) != ItemDatabase.TYPE_EQUIPMENT:
        return _operation_result(false, "not_equipment")

    var target_slot := String(item.get("slot", ""))
    if not ItemDatabase.OPEN_EQUIPMENT_SLOTS.has(target_slot):
        return _operation_result(false, "slot_locked")

    var old_item_id := String(equipment.get(target_slot, ""))
    equipment[target_slot] = item_id
    if old_item_id.is_empty():
        inventory[inventory_index] = {}
    else:
        inventory[inventory_index] = {
            "item_id": old_item_id,
            "quantity": 1,
        }

    _recalculate_derived_stats(false)
    inventory_changed.emit()
    equipment_changed.emit()
    stats_changed.emit()
    return {
        "success": true,
        "equipped_item_id": item_id,
        "unequipped_item_id": old_item_id,
        "slot": target_slot,
    }

func unequip_slot(slot: String) -> Dictionary:
    if not equipment.has(slot):
        return _operation_result(false, "empty_slot")

    var item_id := String(equipment.get(slot, ""))
    var add_result := add_item(item_id, 1)
    if not bool(add_result.get("success", false)):
        return _operation_result(false, "inventory_full")

    equipment.erase(slot)
    _recalculate_derived_stats(false)
    equipment_changed.emit()
    stats_changed.emit()
    return {
        "success": true,
        "item_id": item_id,
        "slot": slot,
    }

func use_item(inventory_index: int) -> Dictionary:
    _ensure_inventory_slots()
    if inventory_index < 0 or inventory_index >= inventory.size():
        return _operation_result(false, "invalid_slot")

    var entry := _slot_entry(inventory_index)
    var item_id := String(entry.get("item_id", ""))
    if item_id.is_empty():
        return _operation_result(false, "empty_slot")

    var item := ItemDatabase.get_item(item_id)
    if String(item.get("type", "")) != ItemDatabase.TYPE_CONSUMABLE:
        return _operation_result(false, "not_consumable")

    var effect := Dictionary(item.get("use_effect", {}))
    var healed := 0
    if effect.has("heal"):
        var before_hp := hp
        hp = min(hp + max(int(effect.get("heal", 0)), 0), max_hp)
        healed = hp - before_hp

    var quantity := int(entry.get("quantity", 0)) - 1
    if quantity <= 0:
        inventory[inventory_index] = {}
    else:
        entry["quantity"] = quantity
        inventory[inventory_index] = entry

    inventory_changed.emit()
    stats_changed.emit()
    return {
        "success": true,
        "item_id": item_id,
        "healed": healed,
        "remaining_quantity": max(quantity, 0),
    }

func get_combat_stats() -> Dictionary:
    _recalculate_derived_stats(false)
    return {
        "level": level,
        "max_hp": max_hp,
        "hp": hp,
        "max_mp": max_mp,
        "mp": mp,
        "attack_power": attack_power,
        "defense": defense,
        "attack_speed": attack_speed,
        "crit_chance": crit_chance,
        "crit_multiplier": crit_multiplier,
    }

func _ensure_inventory_slots() -> void:
    while inventory.size() < INVENTORY_SLOT_COUNT:
        inventory.append({})
    if inventory.size() > INVENTORY_SLOT_COUNT:
        inventory.resize(INVENTORY_SLOT_COUNT)

func _slot_entry(index: int) -> Dictionary:
    if index < 0 or index >= inventory.size():
        return {}

    return Dictionary(inventory[index])

func _find_empty_slot() -> int:
    for index in range(inventory.size()):
        if _slot_entry(index).is_empty():
            return index

    return -1

func _recalculate_derived_stats(fill_resources: bool) -> void:
    var old_max_hp := max_hp
    var old_max_mp := max_mp
    var attributes := get_total_attributes()
    var equipment_bonus := get_equipment_stat_bonus()
    var strength_delta := int(attributes.get("strength", DEFAULT_STRENGTH)) - DEFAULT_STRENGTH
    var agility_delta := int(attributes.get("agility", DEFAULT_AGILITY)) - DEFAULT_AGILITY
    var stamina_delta := int(attributes.get("stamina", DEFAULT_STAMINA)) - DEFAULT_STAMINA
    var weapon_average_damage := float(equipment_bonus.get("weapon_average_damage", 0.0))
    var armor := int(equipment_bonus.get("armor", 0))

    attack_power = max(DEFAULT_ATTACK_POWER + strength_delta * 2 + int(round(weapon_average_damage)), 1)
    max_hp = max(DEFAULT_MAX_HP + stamina_delta * 10, 1)
    max_mp = DEFAULT_MAX_MP
    defense = max(DEFAULT_DEFENSE + int(floor(float(armor) / 3.0)), 0)
    attack_speed = max(DEFAULT_ATTACK_SPEED + float(agility_delta) * 0.01, 0.1)
    crit_chance = clamp(DEFAULT_CRIT_CHANCE + float(agility_delta) * 0.002, 0.0, 1.0)
    crit_multiplier = DEFAULT_CRIT_MULTIPLIER

    if fill_resources:
        hp = max_hp
        mp = max_mp
    else:
        if old_max_hp > 0 and hp == old_max_hp and max_hp > old_max_hp:
            hp = max_hp
        else:
            hp = min(hp, max_hp)
        if old_max_mp > 0 and mp == old_max_mp and max_mp > old_max_mp:
            mp = max_mp
        else:
            mp = min(mp, max_mp)

func _item_result(success: bool, item_id: String, added: int, remaining: int, reason: String) -> Dictionary:
    return {
        "success": success,
        "item_id": item_id,
        "added": added,
        "remaining": remaining,
        "reason": reason,
    }

func _operation_result(success: bool, reason: String) -> Dictionary:
    return {
        "success": success,
        "reason": reason,
    }
