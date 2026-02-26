shader_type canvas_item;

uniform float SMOOTH : hint_range(0.0, 1.0) = 0.6;
uniform float MIN : hint_range(0.0, 1.0) = 0.6;
uniform float MAX : hint_range(0.0, 1.0) = 0.6;
uniform float STRETCH : hint_range(0.0, 2.0) = 0.6;
uniform float MULTIPLIER : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec2 uv = UV;
	vec2 deriv = fwidth(uv); // not available with compatibility renderer
	float aspect_ratio = deriv.y / deriv.x;

	float dist = distance(vec2(UV.x , UV.y* aspect_ratio * STRETCH), vec2(0.5 , 0.5  * aspect_ratio * STRETCH));
	dist = dist / MULTIPLIER;
	float vignette = smoothstep((dist+MIN), (dist-MAX), (1.0 - SMOOTH) + SMOOTH);

	COLOR = vec4(COLOR.rgb , vignette);
}
