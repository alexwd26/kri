#version 130

float	get_shadow(vec4);


float comp_shadow(vec3 pl, float len)	{
	return get_shadow( vec4(pl,len) );
}