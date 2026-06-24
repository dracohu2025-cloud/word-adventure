extends Node

const VILLAGE_SCENE_PATH: String = "res://scenes/world/village.tscn"
const FOREST_SCENE_PATH: String = "res://scenes/world/whispering_forest.tscn"

func _ready() -> void:
    QuestManager.reset_chapter()
    var village = load(VILLAGE_SCENE_PATH).instantiate()
    add_child(village)
    await get_tree().process_frame

    var chapter_exit = village.get_node("ChapterExit")
    assert(not chapter_exit.is_available(), "Chapter exit should start disabled")

    QuestManager.complete_branch("library")
    QuestManager.complete_branch("blacksmith")
    QuestManager.complete_branch("garden")
    await get_tree().process_frame
    assert(not chapter_exit.is_available(), "Chapter exit should stay disabled before boss victory")

    var boss = village.get_node("WordImpBoss")
    assert(boss.is_available(), "Word Imp should be available after three village branches")
    boss.start_interaction()
    var steps := 0
    while CombatManager.is_battle_active() and steps < 120:
        CombatManager.advance_battle(0.5)
        steps += 1

    await get_tree().process_frame
    assert(steps < 120, "Word Imp battle should resolve within the test budget")
    assert(QuestManager.is_boss_defeated(), "Boss victory should be recorded")
    assert(chapter_exit.is_available(), "Chapter exit should become available after boss victory")
    assert(chapter_exit.get_target_scene_path() == FOREST_SCENE_PATH, "Chapter exit should target the forest scene")

    village.queue_free()
    await get_tree().process_frame

    var forest = load(FOREST_SCENE_PATH).instantiate()
    add_child(forest)
    await get_tree().process_frame

    var visuals: Node2D = forest.get_node("Visuals")
    assert(visuals.has_method("is_using_tiny_swords_assets") and visuals.is_using_tiny_swords_assets(), "Forest visuals should use Tiny Swords assets")
    assert(_all_visual_sprites_are_tiny_swords(visuals), "All forest visual sprites should come from Tiny Swords")

    var forest_player: CharacterBody2D = forest.get_node("Player")
    assert(forest.can_player_stand_at_position(forest_player.global_position), "Forest player should spawn on a walkable tile")
    assert(not forest.build_player_path(forest_player.global_position, Vector2(480, 96)).is_empty(), "Forest main route should be pathfindable")
    assert(forest.get_node("ForestGuideNPC") != null, "Forest should contain a guide NPC")
    assert(forest.get_node("LeafImp") != null, "Forest should contain a first enemy encounter")
    assert(forest.get_node("ForestSupplyCache") != null, "Forest should contain a supply cache")

    var guide = forest.get_node("ForestGuideNPC")
    assert(guide.puzzle_word == "tree", "Forest guide should teach the first forest word")

    var cache = forest.get_node("ForestSupplyCache")
    assert(cache.get_collectable_texture_path().ends_with("supply_chest_closed.png"), "Forest supply cache should use a Tiny Swords compatible chest sprite")
    assert(cache.get_collectable_asset_source() == "generated_tiny_swords_compatible", "Forest supply cache asset source should be documented")
    assert(cache.get_node("Sprite2D").get_meta("asset_source", "") == "generated_tiny_swords_compatible", "Supply cache sprite should record its generated asset source")
    var gold_before := PlayerData.gold
    cache.start_interaction()
    await get_tree().process_frame
    assert(cache.is_collected(), "Forest supply cache should be collectable")
    assert(PlayerData.gold == gold_before + 4, "Forest supply cache should grant gold")
    assert(not cache.is_collectable_visible(), "Collected supply cache should not leave a ghost sprite on the map")
    assert(not cache.get_node("InteractionMarker").visible, "Collected supply cache should hide its interaction marker")
    assert(not cache.monitoring, "Collected supply cache should stop monitoring player proximity")
    assert(cache.get_node("CollisionShape2D").disabled, "Collected supply cache should disable its collision shape")

    var leaf_imp = forest.get_node("LeafImp")
    assert(leaf_imp.is_available(), "Forest enemy should start available")
    leaf_imp.start_interaction()
    assert(CombatManager.is_battle_active(), "Forest enemy should start combat")
    CombatManager.end_battle()
    await get_tree().process_frame

    print("Chapter transition regression test PASSED")
    AudioManager.stop_music()
    forest.queue_free()
    await get_tree().process_frame
    get_tree().quit()

func _all_visual_sprites_are_tiny_swords(root: Node) -> bool:
    for child in root.get_children():
        if child is Sprite2D and child.texture != null and child.get_meta("asset_source", "") != "tiny_swords":
            return false
        if not _all_visual_sprites_are_tiny_swords(child):
            return false
    return true
