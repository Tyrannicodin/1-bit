shader_type spatial;
render_mode unshaded;

void fragment() {
	vec3 color;
	color.r = 0.0;
	color.g = 0.0;
	color.b = 0.0;
	ALBEDO = color;
}