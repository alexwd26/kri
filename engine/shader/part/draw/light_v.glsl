#version 130

uniform samplerBuffer unit_part;

uniform struct Spatial	{
	vec4 pos,rot;
}s_cam;
uniform vec4 proj_cam,halo_data;


vec3 trans_inv(vec3,Spatial);
vec4 get_projection(vec3,vec4);

in vec2 at_part_sys;
in vec3 at_part_pos;
in vec4 at_vertex;
out Spatial s_light;

void main()	{
	if( at_part_sys.x>=0.0 )	{
		s_light = Spatial( vec4(at_part_pos,1.0), vec4(0.0) );
		vec3 v = at_part_pos + 1.5*halo_data.x * at_vertex.xyz;
		vec3 vc = trans_inv(v,s_cam);
		gl_Position = get_projection(vc, proj_cam);
	}else	gl_Position = vec4(0.0,0.0,-2.0,1.0);
}