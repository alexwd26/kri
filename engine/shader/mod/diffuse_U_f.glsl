#version 130
precision lowp float;

uniform vec4 mat_diffuse;

vec4 get_diffuse()	{
	return mat_diffuse;
}