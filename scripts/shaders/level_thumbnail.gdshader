shader_type canvas_item;

uniform vec4 emission_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float emission_strength = 1.0;

void fragment() {
	// Called for every pixel the material is visible on.
}

void light() {
	vec4 base_color = texture(TEXTURE, UV);
	LIGHT = vec4(emission_color.rgb * emission_strength * base_color.a, 1.0);
}
