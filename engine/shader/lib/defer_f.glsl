#version 130
//the '2' postfix is inserted for ATI compatibility
//otherwise, you'll get Vertex Shader not supported by HW message

//---	TRANSFORMATIONS		--//
struct Spatial	{ vec4 pos,rot; };

vec3 trans_for2(vec3 v, Spatial s)	{
	return qrot2(s.rot, v*s.pos.w) + s.pos.xyz;
}
vec3 trans_inv2(vec3 v, Spatial s)	{
	return qrot2( vec4(-s.rot.xyz, s.rot.w), (v-s.pos.xyz)/s.pos.w );
}

//---	PROJECTIONS	---//

vec4 project2(vec3 v, vec4 pr)	{
	return vec4( v.xy * pr.xy, v.z*pr.z + pr.w, -v.z);
}
vec3 unproject(vec3 v, vec4 pr)	{
	vec3 ndc = 2.0*v - vec3(1.0);
	float z = -pr.w / (ndc.z + pr.z);
	return z * vec3(-ndc.xy / pr.xy, 1.0);
}

//---	LIGHT ATTENUATION	--//
uniform vec4 lit_attenu;

float get_attenuation2(float d)	{
	vec3 a = vec3(1.0) + lit_attenu.wyz * vec3(-d,d,d*d);
	//x: spherical, y :linear, z: quadratic
	return a.x * lit_attenu.x / (a.y*a.z);
}
