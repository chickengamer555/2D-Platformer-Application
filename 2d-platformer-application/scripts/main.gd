extends Node2D

@export var starter_level: PackedScene
@export var rotate_duration := 0.3

var _rotating := false
var _target_rotation := 0.0
var _player: CharacterBody2D
var _camera: Camera2D
var _current_level: Node

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_camera = get_node_or_null("Camera2D") as Camera2D
	if _camera:
		_camera.top_level = true

	if starter_level:
		load_level(starter_level)

func load_level(packed: PackedScene) -> void:
	if _current_level and is_instance_valid(_current_level):
		_current_level.queue_free()
		_current_level = null

	var level := packed.instantiate()
	add_child(level)
	_current_level = level

	rotation = 0.0
	_target_rotation = 0.0

	await get_tree().process_frame

	var spawn := get_tree().get_first_node_in_group("spawn_point") as Node2D
	if spawn and _player:
		_player.global_position = spawn.global_position
		_player.velocity = Vector2.ZERO

func _process(_delta: float) -> void:
	if _player:
		_player.global_rotation = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if _rotating:
		return
	if event.is_action_pressed("rotate_cw"):
		_start_rotation(deg_to_rad(90.0))
	elif event.is_action_pressed("rotate_ccw"):
		_start_rotation(deg_to_rad(-90.0))

func _start_rotation(delta_rad: float) -> void:
	_rotating = true
	_target_rotation += delta_rad
	if _player:
		_player.velocity = Vector2.ZERO
		_player.set_physics_process(false)
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation", _target_rotation, rotate_duration)
	tween.tween_callback(_finish_rotation)

func _finish_rotation() -> void:
	if _player:
		_player.set_physics_process(true)
	_rotating = false
