#version 130

uniform struct Spatial	{
	vec4 pos,rot;
}s_cam,s_model;
uniform vec4 proj_cam;

vec3 trans_for(vec3,Spatial);
vec3 trans_inv(vec3,Spatial);
vec4 get_projection(vec3,vec4);
vec4 qinv(vec4);
vec4 qmul(vec4,vec4);
void make_tex_coords();

in vec4 at_vertex, at_quat;
out vec2 tc;
out vec4 tan2cam;
out vec4 v_cam;


void main()	{
	make_tex_coords();
	
	vec3 vw = trans_for(at_vertex.xyz, s_model);
	vec3 vc = trans_inv(vw, s_cam);
	gl_Position = get_projection(vc, proj_cam);
	tc = (gl_Position.xy / gl_Position.w)*0.5 + vec2(0.5);

	vec4 tan2w = qmul(s_model.rot, at_quat);
	tan2cam = qmul( qinv(s_cam.rot), tan2w );
	v_cam = vec4( vc, at_vertex.w );	// W=handness
}