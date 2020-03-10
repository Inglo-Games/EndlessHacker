shader_type spatial;

uniform float glitch_amount : hint_range(0.0, 1.0) = 0.0;

float rand_float(vec2 input) {
	return fract(sin(dot(input, vec2(12.9898, 78.233))) * 43758.5453123);
}

void vertex() {
	VERTEX.x += sin(rand_float(vec2(VERTEX.y, TIME)) * 100.0) * glitch_amount;
}

void fragment() {
	ALBEDO = vec3(0.05, 0.7, 0.05);
}
