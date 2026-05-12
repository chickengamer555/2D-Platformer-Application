extends StaticBody2D

enum Direction { RIGHT, LEFT, UP, DOWN }

@export var fire_interval: float = 1.5
@export var direction: Direction = Direction.RIGHT
@export var projectile_speed: float = 220.0
@export var projectile_scene: PackedScene

@onready var fire_timer: Timer = $FireTimer
@onready var sprite: Sprite2D = $Sprite2D

var _spawn_distance: float = 64.0

func _ready() -> void:
	fire_timer.wait_time = fire_interval
	fire_timer.timeout.connect(_fire)
	_spawn_distance = _compute_spawn_distance()
	_apply_direction_visual()

func _direction_vector() -> Vector2:
	match direction:
		Direction.RIGHT: return Vector2.RIGHT
		Direction.LEFT: return Vector2.LEFT
		Direction.UP: return Vector2.UP
		Direction.DOWN: return Vector2.DOWN
	return Vector2.RIGHT

func _apply_direction_visual() -> void:
	if sprite == null:
		return
	sprite.rotation = 0.0
	sprite.flip_h = (direction == Direction.LEFT)

func _compute_spawn_distance() -> float:
	var shape_node := find_child("CollisionShape2D", true, false) as CollisionShape2D
	if shape_node == null or shape_node.shape == null:
		return 64.0
	var shape := shape_node.shape
	if shape is RectangleShape2D:
		var sz: Vector2 = (shape as RectangleShape2D).size
		return maxf(sz.x, sz.y) * 0.5 + 16.0
	if shape is CircleShape2D:
		return (shape as CircleShape2D).radius + 16.0
	return 64.0

func _fire() -> void:
	if projectile_scene == null:
		return
	var p := projectile_scene.instantiate()
	var dir_vec := _direction_vector()
	p.position = position + dir_vec * _spawn_distance
	if "direction" in p:
		p.direction = dir_vec
	if "speed" in p:
		p.speed = projectile_speed
	get_parent().add_child(p)
