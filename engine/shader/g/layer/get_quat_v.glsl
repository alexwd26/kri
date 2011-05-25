#version 130

vec4 qmul(vec4,vec4);
vec3 qrot(vec4,vec3);

in	vec4	at_vertex;
in	vec4	at_quat;


vec3	make_normal(vec4 rot)	{
	vec4 quat = qmul(rot,at_quat);
	vec3 norm = qrot( quat, vec3(0.0,0.0,1.0) );
	return norm * vec3(at_vertex.w,1.0,1.0);
}
