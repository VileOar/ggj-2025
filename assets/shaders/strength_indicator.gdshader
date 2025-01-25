shader_type canvas_item;

// percentage of image at full opacity
uniform float percent : hint_range(0.0, 1.0, 0.1) = 1.0;
// lower opacity value
uniform float low_alpha : hint_range(0.0, 1.0, 0.1) = 0.3;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 colour = texture(TEXTURE, UV);
	
	if (UV.x > percent) {
		colour.a = low_alpha;
	}
	else {
		colour.a = 1.0;
	}
	
	COLOR = colour;
}
