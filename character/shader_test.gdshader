shader_type spatial;
//IMPORTANT NOTE: SHADOWS ARE DISABLED.
render_mode blend_mix,
	depth_draw_opaque,
	cull_back,
	diffuse_burley,
	specular_schlick_ggx,
	depth_prepass_alpha,
	shadows_disabled, 
	skip_vertex_transform;

varying float w_comp;

uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform sampler2D texture_emission : source_color, hint_default_black,filter_linear_mipmap,repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;

uniform ivec2 resolution = ivec2(320, 240);
uniform bool affine_mapping = true;
uniform float alpha_scissor : hint_range(0, 1) = 0.5;
uniform float jitter: hint_range(0, 1) = 0.25;


void vertex()
{	
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	w_comp = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
	VERTEX /= w_comp;
	vec2 grid_to_snap = vec2(resolution) * (1.0 - jitter);
	VERTEX.x = floor(VERTEX.x * grid_to_snap.x) / grid_to_snap.x;
	VERTEX.y = floor(VERTEX.y * grid_to_snap.y) / grid_to_snap.y;
	VERTEX *= w_comp;
	
	if(affine_mapping == true){
		UV *= w_comp;
	}
	
	//IMPORTANT NOTE: Make sure `NORMAL`s are transformed out of local space aswell.
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 base_uv = UV;
	if(affine_mapping == true){
		base_uv /= w_comp;
	}
	
	vec4 color_base = COLOR;
	vec4 texture_color = texture(texture_albedo, base_uv);
	
	ALBEDO = albedo.rgb * texture_color.rgb;
	ALPHA = texture_color.a * color_base.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	vec3 emission_tex = texture(texture_emission,base_uv).rgb;
	EMISSION = (emission.rgb+emission_tex)*emission_energy;
}
