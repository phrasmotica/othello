shader_type canvas_item;

uniform float border_width:hint_range(0.01, 0.05) = 0.01;
uniform vec3 border_colour:source_color;

bool should_shade(vec2 coords) {
	return coords.x < border_width 
		|| coords.x > (1.0 - border_width)
		|| coords.y < border_width 
		|| coords.y > (1.0 - border_width);
}

void fragment() {
	if (should_shade(UV)) {
		COLOR.rgb = border_colour;
	}
}
