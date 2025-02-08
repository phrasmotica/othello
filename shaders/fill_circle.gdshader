shader_type canvas_item;

uniform vec3 colour:source_color;
uniform vec2 circle_centre;
uniform float circle_radius:hint_range(0.0, 6.0);

void fragment() {
	if (distance(UV, circle_centre) < circle_radius) {
		COLOR.rgb = colour;
	}
	else {
		COLOR.a = 0.0;
	}
}
