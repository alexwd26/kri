#version 130

uniform vec4 halo_data, cur_time;

in vec2 at_sys;
in vec3 at_pos;
out float part_age;

void make_tex_coords();
void part_draw(vec3,float);

void main()	{
	make_tex_coords();
	gl_ClipDistance[0] = at_sys.x;
	part_age = cur_time.y - at_sys.x;
	part_draw( at_pos, halo_data.x );
}