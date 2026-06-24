extends Node

const SFX_PATHS := {
    "ui_confirm": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/misc_01.ogg",
    "book": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/book_01.ogg",
    "blade": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/blade_01.ogg",
    "enemy_hurt": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/creature_hurt_01.ogg",
    "enemy_defeated": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/creature_die_01.ogg",
    "coin_reward": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/item_coins_01.ogg",
    "quest_reward": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/item_misc_01.ogg",
    "spell": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/spell_01.ogg",
    "unlock": "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/lock_01.ogg",
}
const PROLOGUE_BGM_PATH: String = "res://assets/audio/bgm/prologue_magic_book_draft_01.ogg"

func _ready() -> void:
    if not AudioManager.has_method("play_sfx_path"):
        _fail("AudioManager should expose play_sfx_path for asset-backed SFX")
        return

    if not AudioManager.has_method("get_last_sfx_stream_path"):
        _fail("AudioManager should expose get_last_sfx_stream_path for testable SFX state")
        return

    if not FileAccess.file_exists(PROLOGUE_BGM_PATH):
        _fail("Missing prologue BGM asset: %s" % PROLOGUE_BGM_PATH)
        return

    var prologue_stream := AudioManager._load_audio_stream(PROLOGUE_BGM_PATH)
    if not prologue_stream is AudioStream:
        _fail("Prologue BGM should load as AudioStream through AudioManager fallback")
        return

    for label in SFX_PATHS:
        var path: String = SFX_PATHS[label]
        if not FileAccess.file_exists(path):
            _fail("Missing SFX asset for %s: %s" % [label, path])
            return

        var stream := load(path)
        if not stream is AudioStream:
            _fail("SFX asset should load as AudioStream for %s: %s" % [label, path])
            return

    AudioManager.play_sfx_path(SFX_PATHS["coin_reward"])
    if AudioManager.get_last_sfx_stream_path() != SFX_PATHS["coin_reward"]:
        _fail("AudioManager should remember the last requested SFX path")
        return

    print("Audio asset regression test PASSED")
    get_tree().quit()

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
