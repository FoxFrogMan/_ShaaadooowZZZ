shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.6, 0.7, 1.0, 1.0);     // السماء العليا (أزرق شروق)
uniform vec4 bottom_color : source_color = vec4(1.0, 0.5, 0.3, 1.0); // الأفق (برتقالي وردي)
uniform float horizon : hint_range(0.0, 1.0) = 0.5;                  // ارتفاع الأفق

void fragment() {
    float t = smoothstep(horizon - 0.2, 1.0, UV.y);
    vec4 color = mix(bottom_color, top_color, t);
    COLOR = color;
}
