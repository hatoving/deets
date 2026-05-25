shader_type canvas_item;

uniform float speed = 0.1;
uniform vec2 zoom = vec2(1.0, 1.0);

void vertex() {
    vec2 centered = UV - vec2(0.5);
    centered *= zoom;
    UV = centered + vec2(0.5);
    UV -= TIME * speed;
}
