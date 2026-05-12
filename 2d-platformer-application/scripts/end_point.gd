extends Area2D

@export var next_level: PackedScene
@export var fade_duration: float = 0.5

var _triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	if not next_level:
		push_warning("EndPoint: no next_level set")
		return
	_triggered = true

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var canvas := CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(overlay)
	get_tree().root.add_child(canvas)

	var fade_in := create_tween()
	fade_in.tween_property(overlay, "color:a", 1.0, fade_duration)
	await fade_in.finished

	var main := get_tree().current_scene
	if main and main.has_method("load_level"):
		main.load_level(next_level)
	else:
		get_tree().change_scene_to_packed(next_level)

	var fade_out := canvas.create_tween()
	fade_out.tween_property(overlay, "color:a", 0.0, fade_duration)
	fade_out.finished.connect(canvas.queue_free)
