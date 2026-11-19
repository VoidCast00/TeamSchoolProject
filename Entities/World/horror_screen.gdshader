shader_type canvas_item;

// Full-screen horror post effect: vignette + film grain + chromatic aberration.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

uniform float vignette_strength : hint_range(0.0, 1.0) = 0.85;
uniform float vignette_radius : hint_range(0.0, 1.5) = 0.85;
uniform float vignette_softness : hint_range(0.01, 1.5) = 0.6;

uniform float grain_amount : hint_range(0.0, 0.3) = 0.06;
uniform float grain_fps : hint_range(1.0, 60.0) = 24.0;

uniform float aberration : hint_range(0.0, 0.03) = 0.008;

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 from_center = uv - 0.5;
	float dist = length(from_center) * 1.4142; // 0 at center, 1 at corners

	// Chromatic aberration: color channels split more toward the edges.
	vec2 offset = from_center * dist * aberration;
	vec3 col;
	col.r = texture(screen_tex, uv + offset).r;
	col.g = texture(screen_tex, uv).g;
	col.b = texture(screen_tex, uv - offset).b;

	// Film grain, refreshed at a film-like frame rate.
	float frame = floor(TIME * grain_fps);
	float noise = hash(FRAGCOORD.xy + frame * vec2(37.0, 17.0)) - 0.5;
	col += noise * grain_amount;

	// Vignette.
	float vig = smoothstep(vignette_radius, vignette_radius - vignette_softness, dist);
	col *= mix(1.0 - vignette_strength, 1.0, vig);

	COLOR = vec4(max(col, vec3(0.0)), 1.0);
}
