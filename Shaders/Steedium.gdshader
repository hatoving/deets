shader_type spatial;

render_mode cull_back, unshaded;

uniform sampler2D albedo_tex : source_color;
uniform float influence : hint_range(0.0, 1.0) = 0.5;
uniform float offset_deg : hint_range(0.0, 360.0) = 0.0;
uniform float saturation_boost : hint_range(0.0, 2.0) = 1.2;
uniform float rainbow_value : hint_range(0.0, 1.0) = 0.8;

uniform vec2 uv_center = vec2(0.5, 0.5);

vec3 hsv_to_rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.x + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec4 base = texture(albedo_tex, UV);

    vec2 centered = UV - uv_center;

    float angle = atan(centered.y, centered.x) + radians(offset_deg);
    float hue = angle / (2.0 * PI) + 0.5;

    float sat = clamp(length(centered) * 2.0, 0.0, 1.0) * saturation_boost;

    vec3 rainbow = hsv_to_rgb(vec3(hue, sat, rainbow_value));

    vec3 final_rgb = mix(base.rgb, rainbow * base.rgb, influence);

    ALBEDO = final_rgb;
    ALPHA = base.a;
}