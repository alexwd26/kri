#version 130

in	vec4	at_quat;
out	vec4	quaternion;
flat	out	float handness;

vec4 qmul(vec4,vec4);

void put_norm(vec4 rot, float w)	{
	handness = w;
	quat = qmul( rot, at_quat );
}