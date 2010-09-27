# coding: utf-8
__author__ = ['Dzmitry Malyshau']
__url__ = ('kvatom.com')
__version__ = '0.6'
__bpydoc__ = '''KRI scene exporter.
This script exports the whole scene to the KRI binary file.
Written against Blender v2.54
'''

''' Math notes:
 The multiplication order is Matrix * vector
 Matrix[3] is the translation component
 Only right-handed matrix should be converted to quaternion
'''

from io_scene_kri.common	import *
from io_scene_kri.scene		import *
from io_scene_kri.material	import save_mat
from io_scene_kri.action	import save_actions
from io_scene_kri.mesh		import save_mesh


###  	GAME OBJECT	###

def save_game(gob):
	out = Writer.inst
	flag = (gob.use_actor, not gob.use_ghost)
	if	gob.physics_type == 'STATIC':
		out.begin('b_stat')
		out.array('B',flag)
		out.end()
	elif	gob.physics_type == 'RIGID_BODY':
		out.begin('b_rigid')
		out.array('B',flag)
		out.pack('3f2f', gob.mass, gob.radius, gob.form_factor,
			gob.damping, gob.rotation_damping )
		out.end()
	if gob.use_collision_bounds:
		print("\t(i)", 'collision', gob.collision_bounds)
		out.begin('collide')
		out.pack('f', gob.collision_margin )
		out.text( gob.collision_bounds )
		out.end()

###  	NODE:CORE	###

def save_node(ob):
	out = Writer.inst
	print(ob.type, ob.name, ob.parent)
	# todo: parent types (bone,armature,node)
	out.begin('node')
	par_name = (ob.parent.name if ob.parent else '')
	out.text( ob.name, par_name )
	save_matrix( ob.matrix_local )
	out.end()


### 	 SCENE		###

def save_scene(filename, context, st):
	import time
	global out,file_ext,bDegrees
	timeStart = time.clock()
	print("\nExporting...")
	out = Writer.inst = Writer(filename)
	out.begin('kri')
	out.pack('B',3)
	out.end()
	
	sc = context.scene
	bDegrees = (sc.unit_settings.rotation_units == 'DEGREES')
	if not bDegrees:
		#it's easier to convert on loading than here
		print("\t(w)",'Radians are not supported')
	if sc.use_gravity:
		print("\tgravity:", sc.gravity)
		out.begin('grav')
		out.array('f', sc.gravity)
		out.end()
	
	for mat in context.blend_data.materials:
		save_mat(mat)
		save_actions( mat, 'm','t' )

	for ob in sc.objects:
		save_node( ob )
		save_actions( ob, 'n', None )
		save_game( ob.game )

		if ob.type == 'MESH':
			arm = None
			if ob.parent and ob.parent.type == 'ARMATURE':
				arm = ob.parent.data
			save_mesh( ob.data, arm, ob.vertex_groups, st )
			save_actions( ob.data.shape_keys, '','v' )
		elif ob.type == 'ARMATURE':
			save_skeleton( ob.data )
			save_actions( ob.data, None, 's' )
		elif ob.type == 'LAMP':
			save_lamp( ob.data )
			save_actions( ob.data, 'l','' )
		elif ob.type == 'CAMERA':
			save_camera( ob.data, ob == sc.camera )
			save_actions( ob.data, 'c','' )
		for p in ob.particle_systems:
			save_particle(ob,p)
	print('Done.')
	out.fx.close()
	print('Export time:', time.clock()-timeStart)
