shader_type canvas_item;

uniform float percentage: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 main_tx = texture(TEXTURE, UV);
    //float avg = (main_tx.r + main_tx.g + main_tx.b) / 4.0;
    float avg = (main_tx.r + main_tx.g + main_tx.b) / 4.0;
	COLOR.a = main_tx.a;
	COLOR.rgb = main_tx.rgb * step(UV.y, percentage) + (vec3(avg) * step(percentage, UV.y));
}