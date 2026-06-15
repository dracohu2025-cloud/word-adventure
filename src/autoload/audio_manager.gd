extends Node

func _ready() -> void:
    print("AudioManager initialized")

func play_sfx(stream: AudioStream) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.finished.connect(player.queue_free)
    add_child(player)
    player.play()
