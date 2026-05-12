extends Area2D

@export var speed: float = 220.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0

@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	lifetime_timer.wait_time = lifetime
	lifetime_timer.timeout.connect(queue_free)
	if direction.length() > 0.001:
		rotation = direction.angle()
		direction = direction.normalized()

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		return
	if body.is_in_group("player"):
		var spawn := get_tree().get_first_node_in_group("spawn_point") as Marker2D
		if spawn:
			body.global_position = spawn.global_position
			(body as CharacterBody2D).velocity = Vector2.ZERO
	queue_free()
