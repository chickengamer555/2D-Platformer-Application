extends Area2D

enum Direction { UP_DOWN, LEFT_RIGHT }

const ROCK_AMPLITUDE_DEG := 12.0
const ROCK_PERIOD := 2.4

@export var direction: Direction = Direction.UP_DOWN
@export var distance: float = 60.0
@export var speed: float = 100.0

var _start_pos: Vector2
var _moving_positive := true

func _ready() -> void:
	_start_pos = position
	body_entered.connect(_on_body_entered)
	_start_rock()

func _start_rock() -> void:
	var sprite := find_child("Sprite2D", true, false) as Sprite2D
	if sprite == null:
		return
	var half := ROCK_PERIOD * 0.5
	sprite.rotation = deg_to_rad(-ROCK_AMPLITUDE_DEG)
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "rotation", deg_to_rad(ROCK_AMPLITUDE_DEG), half)
	tween.tween_property(sprite, "rotation", deg_to_rad(-ROCK_AMPLITUDE_DEG), half)

func _physics_process(delta: float) -> void:
	var axis := Vector2(0, 1) if direction == Direction.UP_DOWN else Vector2(1, 0)
	var step := speed * delta * (1.0 if _moving_positive else -1.0)
	position += axis * step
	var offset := axis.dot(position - _start_pos)
	if offset >= distance:
		_moving_positive = false
	elif offset <= -distance:
		_moving_positive = true

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var spawn := get_tree().get_first_node_in_group("spawn_point") as Marker2D
	if spawn:
		body.global_position = spawn.global_position
		(body as CharacterBody2D).velocity = Vector2.ZERO
