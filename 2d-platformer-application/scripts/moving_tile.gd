extends StaticBody2D

enum Direction { UP_DOWN, LEFT_RIGHT }

@export var direction: Direction = Direction.LEFT_RIGHT
@export var distance: float = 200.0
@export var speed: float = 100.0

var _start_pos: Vector2
var _moving_positive := true
var _shape_node: CollisionShape2D

func _ready() -> void:
	_start_pos = position
	_shape_node = find_child("CollisionShape2D", true, false) as CollisionShape2D

func _physics_process(delta: float) -> void:
	var axis := Vector2(0, 1) if direction == Direction.UP_DOWN else Vector2(1, 0)
	var step := speed * delta * (1.0 if _moving_positive else -1.0)
	var motion := axis * step

	if _would_hit_player(motion):
		_moving_positive = not _moving_positive
		motion = -motion

	position += motion

	var offset := axis.dot(position - _start_pos)
	if offset >= distance:
		_moving_positive = false
	elif offset <= -distance:
		_moving_positive = true

func _would_hit_player(motion: Vector2) -> bool:
	if not _shape_node or not _shape_node.shape:
		return false
	var space := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _shape_node.shape
	query.transform = _shape_node.global_transform.translated(motion)
	query.collide_with_bodies = true
	query.exclude = [get_rid()]
	var hits := space.intersect_shape(query, 8)
	for h in hits:
		if h.collider and h.collider.is_in_group("player"):
			return true
	return false
