extends Node

const SFX_UI_CONFIRM: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/misc_01.ogg"
const SFX_BOOK: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/book_01.ogg"
const SFX_BLADE_ATTACK: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/blade_01.ogg"
const SFX_ENEMY_HURT: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/creature_hurt_01.ogg"
const SFX_ENEMY_DEFEATED: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/creature_die_01.ogg"
const SFX_COIN_REWARD: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/item_coins_01.ogg"
const SFX_QUEST_REWARD: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/item_misc_01.ogg"
const SFX_SPELL: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/spell_01.ogg"
const SFX_UNLOCK: String = "res://assets/audio/sfx/open_game_art_80_cc0_rpg_sfx/lock_01.ogg"

var _music_player: AudioStreamPlayer
var _music_stream_path: String = ""
var _last_sfx_stream_path: String = ""

func _ready() -> void:
    _music_player = AudioStreamPlayer.new()
    add_child(_music_player)
    print("AudioManager initialized")

func _exit_tree() -> void:
    if _music_player != null:
        stop_music()

func play_sfx(stream: AudioStream) -> void:
    if stream == null:
        return

    if not stream.resource_path.is_empty():
        _last_sfx_stream_path = stream.resource_path
    if DisplayServer.get_name() == "headless":
        return

    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.finished.connect(player.queue_free)
    add_child(player)
    player.play()

func play_sfx_path(path: String) -> void:
    if path.is_empty():
        return

    _last_sfx_stream_path = path
    if DisplayServer.get_name() == "headless":
        return

    var stream := _load_audio_stream(path)
    if stream is AudioStream:
        play_sfx(stream)

func play_music_path(path: String) -> void:
    if path.is_empty():
        return

    if _music_stream_path == path and (_music_player.playing or DisplayServer.get_name() == "headless"):
        return

    _music_stream_path = path
    if DisplayServer.get_name() == "headless":
        return

    var stream := _load_audio_stream(path)
    if stream is AudioStream:
        _play_music_stream(stream)

func play_music(stream: AudioStream) -> void:
    if stream == null:
        return

    _music_stream_path = stream.resource_path
    if DisplayServer.get_name() == "headless":
        return

    _play_music_stream(stream)

func stop_music() -> void:
    _music_player.stop()
    _music_player.stream = null
    _music_stream_path = ""

func stop_all_sfx() -> void:
    for child in get_children():
        if child is AudioStreamPlayer and child != _music_player:
            child.stop()
            child.queue_free()

func get_music_stream_path() -> String:
    return _music_stream_path

func get_last_sfx_stream_path() -> String:
    return _last_sfx_stream_path

func _load_audio_stream(path: String) -> AudioStream:
    if ResourceLoader.exists(path):
        var imported_stream := load(path)
        if imported_stream is AudioStream:
            return imported_stream

    if not FileAccess.file_exists(path):
        return null

    var data := FileAccess.get_file_as_bytes(path)
    if data.size() == 0:
        return null

    var lower_path := path.to_lower()
    if lower_path.ends_with(".mp3"):
        var mp3_stream := AudioStreamMP3.new()
        mp3_stream.data = data
        return mp3_stream

    if lower_path.ends_with(".ogg"):
        return AudioStreamOggVorbis.load_from_buffer(data)

    return null

func _play_music_stream(stream: AudioStream) -> void:
    if _music_player.stream == stream and _music_player.playing:
        return

    _set_loop_if_supported(stream, true)
    _music_player.stop()
    _music_player.stream = stream
    _music_player.play()

func _set_loop_if_supported(stream: AudioStream, enabled: bool) -> void:
    for property in stream.get_property_list():
        if String(property.get("name", "")) == "loop":
            stream.set("loop", enabled)
            return
