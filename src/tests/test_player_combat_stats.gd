extends Node

var _signal_count: int = 0

func _ready() -> void:
    PlayerData.stats_changed.connect(_on_stats_changed)
    PlayerData.reset_runtime_state()

    assert(PlayerData.level == 1, "Player should start at level 1")
    assert(PlayerData.max_hp == 120, "Player should start with baseline max HP")
    assert(PlayerData.hp == PlayerData.max_hp, "Player HP should start full")
    assert(PlayerData.max_mp == 40, "Player should start with baseline max MP")
    assert(PlayerData.mp == PlayerData.max_mp, "Player MP should start full")
    assert(PlayerData.gold == 0, "Player should start without gold")
    assert(PlayerData.attack_power == 18, "Player should start with baseline attack power")
    assert(PlayerData.defense == 8, "Player should start with baseline defense")
    assert(is_equal_approx(PlayerData.attack_speed, 1.3), "Player should start with baseline attack speed")

    PlayerData.apply_damage(35)
    assert(PlayerData.hp == 85, "Damage should reduce HP")
    PlayerData.apply_damage(999)
    assert(PlayerData.hp == 0, "Damage should clamp HP at zero")

    PlayerData.restore_full_resources()
    assert(PlayerData.hp == PlayerData.max_hp, "Restoring resources should refill HP")
    assert(PlayerData.mp == PlayerData.max_mp, "Restoring resources should refill MP")

    PlayerData.add_gold(7)
    assert(PlayerData.gold == 7, "Gold reward should accumulate")
    assert(_signal_count >= 4, "PlayerData should notify UI when combat stats change")

    var stats: Dictionary = PlayerData.get_combat_stats()
    assert(stats.get("max_hp", 0) == PlayerData.max_hp, "Combat stats should expose max HP")
    assert(stats.get("attack_power", 0) == PlayerData.attack_power, "Combat stats should expose attack power")
    assert(is_equal_approx(float(stats.get("crit_multiplier", 0.0)), PlayerData.crit_multiplier), "Combat stats should expose crit multiplier")

    print("Player combat stats regression test PASSED")
    get_tree().quit()

func _on_stats_changed() -> void:
    _signal_count += 1
