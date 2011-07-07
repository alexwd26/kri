#version 130

uniform sampler2D unit_input;
noperspective in vec2 tex_coord;
out vec4 rez_color;


void main()	{
	rez_color =	0.4*texture(unit_input, tex_coord) + 
		0.2 * textureOffset(unit_input, tex_coord, ivec2(0,-1)) + 
		0.2 * textureOffset(unit_input, tex_coord, ivec2(0,+1)) + 
		0.1 * textureOffset(unit_input, tex_coord, ivec2(0,-2)) + 
		0.1 * textureOffset(unit_input, tex_coord, ivec2(0,+2)) ;
}
