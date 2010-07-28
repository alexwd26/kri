#version 130

//	Turbulence 2D	//
float snoise(vec2);

float turbulence(vec2 Point, vec3 Derivate, int steps)	{
	float rez = 0.0;
	vec3 d = vec3(1.0);
	while(--steps >= 0)	{
		rez += d.z * snoise( Point * d.xy );
		d *= Derivate;
	}
	return rez;
}

float turbulence(vec2 Point, vec3 Current, vec3 Derivate, int steps)	{
	return Current.z * turbulence( Point*Current.xy, Derivate, steps );
}


//	Turbulence 3D	//
float snoise(vec3);

float turbulence(vec3 Point, vec4 Derivate, int steps)	{
	float rez = 0.0;
	vec4 d = vec4(1.0);
	while(--steps >= 0)	{
		rez += d.w * snoise( Point * d.xyz );
		d *= Derivate;
	}
	return rez;
}

float turbulence(vec3 Point, vec4 Current, vec4 Derivate, int steps)	{
	return Current.w * turbulence( Point*Current.xyz, Derivate, steps );
}
