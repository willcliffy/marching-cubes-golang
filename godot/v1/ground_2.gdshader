shader_type spatial;
render_mode cull_disabled;

// Define shader parameters
uniform vec4 _Color : source_color = vec4(1, 1, 1, 1);
uniform sampler2D _MainTex : source_color;
uniform float _Glossiness : hint_range(0.0, 1.0) = 0.5;
uniform float _Metallic : hint_range(0.0, 1.0) = 0.0;
uniform float boundsY: hint_range(0.0, 100.0, 1.0) = 1.0;

varying vec3 pos;

void vertex() {
	pos = VERTEX;
}


void fragment() {
    // Albedo comes from a texture tinted by color
    float h = smoothstep(0, boundsY, pos.y);
    vec3 tex = texture(_MainTex, vec2(h, 0.5)).rgb;
    ALBEDO.rgb = tex * _Color.rgb;

    // Metallic and smoothness come from slider variables
    SPECULAR = _Metallic;
    ROUGHNESS = 1.0 - _Glossiness;
}
