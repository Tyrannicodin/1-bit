shader_type canvas_item;

void fragment() {
	vec4 col = vec4(0.0, 0.0, 0.0, 0.0);
	
	if (COLOR.r == 0.0) {
		col = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		col = vec4(1.0, 0.7450980392156863, 0.4980392156862745, 1.0);
	}
	COLOR = col;
}