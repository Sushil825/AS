shader_type canvas_item;

uniform float dash_intensity:hint_range(0.0, 1.0)=0.0;
uniform float trail_length:hint_range(0.0, 1.0)=0.5;
uniform vec4 dash_color:source_color=vec4(0.0,0.5,1.0,1.0);
uniform float flicker_speed:hint_range(0.0, 20.0)=10.0;

void fragment(){
	
	vec4 tex_color=texture(TEXTURE,UV);
	
	//create flicker
	
	float flicker=sin(TIME*flicker_speed)*0.5+0.5;
	
	vec4 dash_effect =mix(tex_color,dash_color,dash_intensity*0.7);
	dash_effect.a=tex_color.a*(1.0-dash_intensity*0.3*flicker);
	
	
	vec2 center=vec2(0.5,0.5);
	float dist=distance(UV,center);
	float glow=1.0-smoothstep(0.0,0.5,dist);
	dash_effect.rgb+=dash_color.rgb*glow*dash_intensity*0.5;
	COLOR=dash_effect;
}