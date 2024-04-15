shader_type canvas_item;

uniform sampler2D noise_texture: repeat_enable;
uniform vec2 speed = vec2(0.02, 0.01);

uniform float uv_scale;
uniform float radius;
uniform float gradient;
uniform mat4 world_transform;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 uv = UV*uv_scale + speed*TIME;
	float noise = texture(noise_texture, uv).r;
	float fog = clamp(noise * 2.0 - 1.0, 0.0, 1.0);
	float strength = clamp((length(world_pos)-radius)/gradient, 0.0, 1.0);
	COLOR.a *= fog * strength;
}