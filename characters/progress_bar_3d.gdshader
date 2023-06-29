shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_lambert,specular_disabled,unshaded;

uniform vec4 albedoFrom : source_color;
uniform vec4 albedoTo : source_color;
uniform vec4 albedoBG : source_color;

uniform float progress;

void vertex() {
	UV=UV;
	// billboard the mesh
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
}

void fragment() {
	vec2 base_uv = UV;
	
	float pr=smoothstep(0.0+progress,0.0 +progress + 0.01,UV.x);
	ALBEDO = mix(mix(albedoFrom.rgb,albedoTo.rgb,progress),albedoBG.rgb,pr);
}