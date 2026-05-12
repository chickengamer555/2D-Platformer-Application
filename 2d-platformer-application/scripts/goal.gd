extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("You Win!")
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
