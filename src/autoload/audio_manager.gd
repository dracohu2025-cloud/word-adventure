extends Node

var _music_player: AudioStreamPlayer
var _music_stream_path: String = ""

func _ready() -> void:
    _music_player = AudioStreamPlayer.new()
    add_child(_music_player)
    print("AudioManager initialized")

func _exit_tree() -> void:
    if _music_player != null:
        stop_music()

func play_sfx(stream: AudioStream) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.finished.connect(player.queue_free)
    add_child(player)
    player.play()

func play_music_path(path: String) -> void:
    if path.is_empty():
        return

    if _music_stream_path == path and (_music_player.playing or DisplayServer.get_name() == "headless"):
        return

    _music_stream_path = path
    if DisplayServer.get_name() == "headless":
        return

    var stream := load(path)
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

func get_music_stream_path() -> String:
    return _music_stream_path

func _play_music_stream(stream: AudioStream) -> void:
    if _music_player.stream == stream and _music_player.playing:
        return

    _music_player.stop()
    _music_player.stream = stream
    _music_player.play()
