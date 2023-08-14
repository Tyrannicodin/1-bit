shader_type canvas_item;

uniform vec4 ui_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 col = vec4(0.0, 0.0, 0.0, 0.0);
	
	if (COLOR.r == 0.0) {
    vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
	    for(int y = -2; y <= 2; y++)
	    for(int x = -2; x <= 2; x++)
	    {
	        vec2 pixel_off = vec2(float(x), float(y));
	        vec4 tex = texture(TEXTURE, UV + pixel_off * pixel_size);
	        if(tex.a != 0.0)
	        {
	            col = vec4(0.24313725490196078, 0.07450980392156863, 0.2196078431372549, 1.0);
	            break;
	        }
		}
	} else {
		col = ui_color;
	}
	COLOR = col;
}