__author__ = ['Dzmitry Malyshau']
__bpydoc__ = 'Light, Camera, Skeleton & Particles export for KRI.'

from io_scene_kri.common	import *


###  LIGHT & CAMERA   ###

def save_lamp(lamp):
	out = Writer.inst
	energy_threshold = 0.1
	print("\t(i) %s type, %.1f distance" % (lamp.type, lamp.distance))
	out.begin('lamp')
	save_color( lamp.color )
	if not lamp.use_specular or not lamp.use_diffuse:
		print("\t(w)",'specular/diffuse cant be disabled')
	clip0,clip1,spotAng,spotBlend = 1.0,2.0*lamp.distance,0.0,0.0
	# attenuation
	kd = 1.0 / lamp.distance
	q0,q1,q2,qs = lamp.energy, kd, kd*kd, 0.0
	if lamp.type in ('POINT','SPOT'):
		if lamp.use_sphere:
			print("\t(i) spherical limit")
			clip1 = lamp.distance
			qs = kd
		ft = lamp.falloff_type
		if ft == 'LINEAR_QUADRATIC_WEIGHTED':
			q1 *= lamp.linear_attenuation
			q2 *= lamp.quadratic_attenuation
		elif ft == 'INVERSE_LINEAR': q2=0.0
		elif ft == 'INVERSE_SQUARE': q1=0.0
		elif ft == 'CONSTANT': q1=q2=0.0
		else: print("\t(w) custom curve is not supported")
		print("\tfalloff: %s, %.4f q1, %.4f q2" % (ft,q1,q2))
	else: q1=q2=0.0
	out.pack('4f', q0,q1,q2,qs)
	if lamp.type == 'SPOT':
		spotAng,spotBlend = lamp.spot_size,lamp.spot_blend
	out.text( lamp.type )
	out.pack('4f', clip0,clip1, spotAng,spotBlend )
	out.end()


def save_camera(cam, is_cur):
	out = Writer.inst
	if is_cur: print("\t(i) active")
	fov = cam.angle
	if cam.type == 'ORTHO':
		scale = cam.ortho_scale
		print("\t(i) ortho scale: %.2f" % (scale))
		fov = -4.0 / scale	# will be scaled by 0.5 on reading
	print("\t%s, dist: [%.2f-%.2f], fov: %.2f" % (
		('A' if is_cur else '_'),
		cam.clip_start, cam.clip_end, fov) )
	out.begin('cam')
	out.pack('B3f', is_cur,
		cam.clip_start, cam.clip_end, fov)
	out.end()


###	SKELETON:CORE		###

def save_skeleton(skel):
	out = Writer.inst
	out.begin('skel')
	nbon = len(skel.bones)
	print("\t(i)", nbon ,'bones')
	out.pack('B', nbon)
	for bone in skel.bones:
		parid,par,mx = -1, bone.parent, bone.matrix_local.copy()
		if not (bone.use_inherit_scale and bone.use_deform):
			print("\t\t(w)", 'weird bone', bone.name)
		if par: # old variant (same result)
			#pos = bone.head.copy() + par.matrix.copy().invert() * par.vector	
			parid = skel.bones.keys().index( par.name )
			mx = par.matrix_local.copy().invert() * mx
		out.text( bone.name )
		out.pack('B', parid+1 )
		save_matrix(mx)
	out.end()


###	PARTICLES	###

def save_particle(obj,part):
	out = Writer.inst
	st = part.settings
	life = (st.frame_start, st.frame_end, st.lifetime)
	mat = obj.material_slots[ st.material-1 ].material
	matname = (mat.name if mat else '')
	info = (part.name, matname, st.count)
	print("\t+particle: %s [%s], %d num" % info )
	out.begin('part')
	out.pack('L', st.count)
	out.text( part.name, matname )
	out.end()

	if st.type == 'HAIR' and not part.use_hair_dynamics:
		print("\t(w)",'hair dynamics has to be enabled')
	elif st.type == 'HAIR' and part.use_hair_dynamics:
		if not mat.strand.use_blender_units:
			print("\t(w)",'material strand size in units required')
		cset = part.cloth.settings
		print("\t\thair: %d segments" % (st.hair_step,) )
		out.begin('p_hair')
		out.pack('B3f2f', st.hair_step,
			cset.pin_stiffness, cset.mass, cset.bending_stiffness,
			cset.spring_damping, cset.air_damping )
		out.end()
	elif st.type == 'EMITTER':
		print("\t\temitter: [%d-%d] life %d" % life)
		out.begin('p_life')
		out.array('f', [x * Settings.kFrameSec for x in life] )
		out.pack('f', st.lifetime_random )
		out.end()
	
	if st.render_type == 'OBJECT':
		print("\t\t(i)", 'instanced', st.dupli_object )
		out.begin('pr_inst')
		out.text( st.dupli_object.name )
		out.end()
	elif st.render_type == 'LINE':
		out.begin('pr_line')
		out.pack('B2f', st.velocity_length,
			st.line_length_tail, st.line_length_head )
		out.end()
	elif not st.render_type in ('HALO','PATH'):
		print("\t\t(w)", 'render as unsupported:', st.ren_as )
	
	out.begin('p_vel')
	out.array('f', st.object_align_factor )
	out.pack('3f', st.normal_factor, st.tangent_factor, st.tangent_phase )
	out.pack('2f', st.object_factor, st.factor_random )
	out.end()

	if st.emit_from == 'FACE' and not len(obj.data.uv_textures):
		print("\t\t(w)",'emitter surface does not have UV')
	out.begin('p_dist')
	out.text( st.emit_from, st.distribution )
	out.pack('f', st.jitter_factor )
	out.end()
	out.begin('p_rot')
	out.text( st.angular_velocity_mode )
	out.pack('f', st.angular_velocity_factor )
	out.end()
	out.begin('p_phys')
	out.pack('2f3f', st.particle_size, st.size_random,
		st.brownian_factor, st.drag_factor, st.damping )
	out.end()