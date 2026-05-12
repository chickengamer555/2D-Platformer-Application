extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var spawn := get_tree().get_first_node_in_group("spawn_point") as Marker2D
	if spawn:
		body.global_position = spawn.global_position
		(body as CharacterBody2D).velocity = Vector2.ZERO
