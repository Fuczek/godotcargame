shader_type spatial;

uniform sampler2D DitherMap;
uniform float DitherStrength = 0.1;
uniform float ColorDepth = 3.0;

void light() {
	float light = max(0.0, dot(NORMAL, LIGHT)) * ATTENUATION.r;
	vec2 ts = vec2(textureSize(DitherMap, 0));
	vec2 uv = mod(floor(FRAGCOORD.xy), ts) / ts;
	light += (texture(DitherMap, uv).r - 0.5) * DitherStrength;
	light = round(light * ColorDepth) / ColorDepth;
	DIFFUSE_LIGHT += light * ALBEDO * LIGHT_COLOR;
}