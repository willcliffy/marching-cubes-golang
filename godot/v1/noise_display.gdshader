shader_type spatial;

uniform sampler3D noise_texture : hint_default_black;

void fragment() {
    // Sample the 3D noise texture
    vec4 noise = texture(noise_texture, VERTEX);
	if (noise.r > 0.5) {
		// Use the red channel of the noise texture as transparency
    	ALPHA *= 0.25;
	}


	ALBEDO = vec3(0, 0, 0);
}