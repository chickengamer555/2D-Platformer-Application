extends Area2D

@export var speed: float = 80.0
@export var orbit_margin: float = 16.0
@export var spin_speed_deg: float = 360.0

var _perim_d: float = 0.0
var _orbit_w: float = 0.0
var _orbit_h: float = 0.0
var _perimeter: float = 0.0

func _ready() -> void:
	_setup_orbit()
	body_entered.connect(_on_body_entered)

func _setup_orbit() -> void:
	var s := _detect_size_from_parent()
	if s == Vector2.ZERO:
		s = Vector2(64, 64)
	var clearance := orbit_margin + _get_visual_radius()
	_orbit_w = s.x + clearance * 2.0
	_orbit_h = s.y + clearance * 2.0
	_perimeter = 2.0 * (_orbit_w + _orbit_h)
	_perim_d = _project_to_perim(position)

func _detect_size_from_parent() -> Vector2:
	var parent := get_parent()
	if parent == null:
		return Vector2.ZERO
	var shape_node := parent.find_child("CollisionShape2D", true, false) as CollisionShape2D
	if shape_node and shape_node.shape is RectangleShape2D:
		return (shape_node.shape as RectangleShape2D).size
	return Vector2.ZERO

func _get_visual_radius() -> float:
	var sprite := find_child("Sprite2D", true, false) as Sprite2D
	if sprite and sprite.texture:
		var sz: Vector2 = sprite.texture.get_size() * sprite.scale.abs()
		return maxf(sz.x, sz.y) * 0.5
	return 0.0

func _project_to_perim(p: Vector2) -> float:
	var hw := _orbit_w * 0.5
	var hh := _orbit_h * 0.5
	var top_pt := Vector2(clampf(p.x, -hw, hw), -hh)
	var right_pt := Vector2(hw, clampf(p.y, -hh, hh))
	var bottom_pt := Vector2(clampf(p.x, -hw, hw), hh)
	var left_pt := Vector2(-hw, clampf(p.y, -hh, hh))
	var d_top := p.distance_squared_to(top_pt)
	var d_right := p.distance_squared_to(right_pt)
	var d_bottom := p.distance_squared_to(bottom_pt)
	var d_left := p.distance_squared_to(left_pt)
	var m := minf(minf(d_top, d_right), minf(d_bottom, d_left))
	if m == d_top:
		return top_pt.x + hw
	elif m == d_right:
		return _orbit_w + (right_pt.y + hh)
	elif m == d_bottom:
		return _orbit_w + _orbit_h + (hw - bottom_pt.x)
	else:
		return 2.0 * _orbit_w + _orbit_h + (hh - left_pt.y)

func _perim_to_pos(d: float) -> Vector2:
	var hw := _orbit_w * 0.5
	var hh := _orbit_h * 0.5
	d = fposmod(d, _perimeter)
	if d < _orbit_w:
		return Vector2(-hw + d, -hh)
	elif d < _orbit_w + _orbit_h:
		return Vector2(hw, -hh + (d - _orbit_w))
	elif d < 2.0 * _orbit_w + _orbit_h:
		return Vector2(hw - (d - _orbit_w - _orbit_h), hh)
	else:
		return Vector2(-hw, hh - (d - 2.0 * _orbit_w - _orbit_h))

func _process(delta: float) -> void:
	rotation += deg_to_rad(spin_speed_deg) * delta
	if _perimeter <= 0.001:
		return
	_perim_d += speed * delta
	position = _perim_to_pos(_perim_d)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var spawn := get_tree().get_first_node_in_group("spawn_point") as Marker2D
	if spawn:
		body.global_position = spawn.global_position
		(body as CharacterBody2D).velocity = Vector2.ZERO
