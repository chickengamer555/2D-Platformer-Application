shader_type canvas_item;

void fragment() {
	vec2 c = UV - vec2(0.5);
	if (dot(c, c) > 0.25) {
		discard;
	}
}
