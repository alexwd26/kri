#version 130

uniform	vec4	mat_diffuse;
uniform	float	mat_emissive;
uniform	vec4	mat_specular;
uniform	float	mat_glossiness;

in	vec4	normal;
out	vec4	c_diffuse;
out	vec4	c_specular;
out	vec4	c_normal;


void main()	{
	vec3 norm = vec3(0.5) + 0.5*normalize(normal.xyz);
	float glossy = 0.01 * mat_glossiness;
	
	c_diffuse	= vec4( mat_diffuse.xyz, mat_emissive );
	c_specular	= vec4( mat_specular.xyz, glossy );
	c_normal	= vec4( norm, normal.w );
}
