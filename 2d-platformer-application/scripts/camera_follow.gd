extends Camera2D

@export var target: Node2D
@export var smoothing := 8.0

func _ready() -> void:
	if not target:
		target = get_tree().get_first_node_in_group("player") as Node2D
	if target:
		global_position = target.global_position

func _process(delta: float) -> void:
	if not target:
		return
	global_position = global_position.lerp(target.global_position, clamp(smoothing * delta, 0.0, 1.0))
