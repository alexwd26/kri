#version 150

in vec3 mv_%v[];

out vec3 mr_%v;
out vec3 mr_%g;

vec3 mi_%g(vec3);

void emit_vert(int i, vec3 tc)	{
	mr_%v = mv_%v[i];
	
	mr_%g = mi_%g(tc);
	
	EmitVertex();
}
