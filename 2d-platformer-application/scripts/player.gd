extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -380.0
const GRAVITY := 900.0

@onready var sprite: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		velocity.x = dir * SPEED
		sprite.flip_h = dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()
