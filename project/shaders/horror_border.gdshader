shader_type canvas_item;
const float UPDATE_INTERVAL = .163;
uniform float STATIC_GRANULARITY = .004;
uniform float EDGE_BLUR = 1.1;
uniform float BORDER_SIZE = .3;
uniform float OPACITY = 0.7;

global uniform float insanity = 0.0;

float generate_random_static (in float size, in float interval, in vec2 uv){
	float time_step = TIME - mod(TIME,interval);
	vec2 uv_step = uv - mod(uv, size);
	return fract(sin(dot(uv_step,vec2(12.0278*sin(time_step),15.0905)))*43758.5453);
}

vec2 get_polar_coords (vec2 center, vec2 uv){
	vec2 pos = uv-center;
	float r = length(pos);
	float theta = atan(pos.y,pos.x);
	return vec2(r,theta);
}

vec4 layer (in vec4 front_color, in vec4 back_color){
	return vec4(mix(back_color.rgb,front_color.rgb,front_color.a),front_color.a+back_color.a);
}

void fragment() {

	float insanity_edge_blur = EDGE_BLUR - (insanity * 0.95);
	float insanity_border_size = BORDER_SIZE - (insanity * 0.25);

	vec3 static_plot = vec3(generate_random_static(STATIC_GRANULARITY,UPDATE_INTERVAL,UV));

	vec2 c1 = vec2(0.5,0.6);
	vec2 pv1 = get_polar_coords(c1,UV);
	float func = insanity_border_size-.015*cos(10.0*pv1.y);
	float border_plot = smoothstep(func,func+insanity_edge_blur, pv1.x);
	vec4 border_color = vec4(vec3(0.0),1.0)*border_plot;
	COLOR = vec4(static_plot,0.1);
	float opacity_shift = OPACITY + 0.1 * sin(4.0*TIME);
	COLOR = layer(COLOR,border_color * opacity_shift);
}