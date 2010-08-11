#version 130

uniform sampler2D unit_prev, unit_kern, unit_wave;
uniform vec4 cur_time;

noperspective in vec2 tex_coord;
out float next;

vec2 delta_kern = vec2(1.0) / textureSize(unit_kern,0);
vec2 delta_wave = vec2(1.0) / textureSize(unit_wave,0);


float sample(const int k, const int l)	{
	vec2 ov = vec2(k,l);// + vec2(0.5);
	vec4 off = vec4(ov.xy,-ov.xy) * delta_wave.xyxy;
	float g = texture(unit_kern, ov*delta_kern ).x;
	float h = -2.0+	//offset by 0.5 each
		texture(unit_wave, tex_coord + off.xy ).x+
		texture(unit_wave, tex_coord + off.xw ).x+
		texture(unit_wave, tex_coord + off.zy ).x+
		texture(unit_wave, tex_coord + off.zw ).x;
	return g*h;
}


const float alpha = -0.1, grav = 9.81;

void main()	{
	float prev = texture(unit_prev, tex_coord).x - 0.5;
	float wave = texture(unit_wave, tex_coord).x - 0.5;

	const int P = 5;
	float conv = wave;
	for(int y=1; y<P; ++y)
		conv += 0.5 * (sample(0,y) + sample(y,0));
	for(int x=1; x<P; ++x)	{
		for(int y=x+1; y<P; ++y)
			conv += sample(x,y) + sample(y,x);
		conv += sample(x,x);
	}

	float dt = cur_time.y;
	float cur = wave * (2.0-alpha*dt) - prev - grav*dt*dt*conv;
	next = 0.5 + cur / (1.0 + alpha * dt);
}