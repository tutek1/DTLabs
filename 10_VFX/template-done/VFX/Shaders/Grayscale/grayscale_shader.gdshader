shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0, 0.01);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	float avg = (color.x + color.y + color.z) / 3.0f;
	vec4 grayscale = vec4(avg, avg, avg, 1.0f);
	COLOR = mix(color, grayscale, amount);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
