extends CharacterBody2D

@export var speed: float = 160.0

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(_delta: float) -> void:
    if not GameManager.is_world_active():
        velocity = Vector2.ZERO
        return

    var input := Vector2.ZERO
    input.x = Input.get_axis("move_left", "move_right")
    input.y = Input.get_axis("move_up", "move_down")

    if input.length() > 1.0:
        input = input.normalized()

    velocity = input * speed

    if input.x != 0:
        sprite.flip_h = input.x < 0

    move_and_slide()
