﻿namespace kri.part

import System.Collections.Generic
import OpenTK.Graphics.OpenGL
import kri.shade

#---------------------------------------#
#	PARTICLE GENERIC BEHAVIOR			#
#---------------------------------------#

public class Behavior( kri.meta.IBase, kri.meta.IShaded, kri.vb.ISemanted, Code ):
	[Getter(Semant)]
	private final semantics	as List[of kri.vb.Info]	= List[of kri.vb.Info]()
	[getter(Shader)]
	private final sh		as Object

	public def constructor():
		super( CodeNull() )
		sh = null
	public def constructor(path as string):
		super(path)
		sh = Object( ShaderType.VertexShader, path, Text )
	public def constructor(b as Behavior):
		super(b)
		semantics.AddRange( b.Semant )
		sh = b.sh
	
	public virtual def link(d as rep.Dict) as void:	#imp: kri.meta.IBase
		pass
	def System.ICloneable.Clone() as object:
		return Behavior(self)
	par.INamed.Name:
		get: return 'behavior'


#---------------------------------------#
#	PARTICLE CREATION CONTEXT			#
#---------------------------------------#

public class Context:
	# particle attribs
	public final	at_pos		= kri.Ant.Inst.slotParticles.getForced('pos')
	public final	at_rot		= kri.Ant.Inst.slotParticles.getForced('rot')
	public final	at_sys		= kri.Ant.Inst.slotParticles.getForced('sys')
	public final	at_sub		= kri.Ant.Inst.slotParticles.getForced('sub')
	public final	at_speed	= kri.Ant.Inst.slotParticles.getForced('speed')
	# particle ghost attribs
	public final	ghost_pos	= kri.Ant.Inst.slotAttributes.getForced('@pos')
	public final	ghost_rot	= kri.Ant.Inst.slotAttributes.getForced('@rot')
	public final	ghost_sys	= kri.Ant.Inst.slotAttributes.getForced('@sys')
	public final	ghost_sub	= kri.Ant.Inst.slotAttributes.getForced('@sub')
	# root shaders
	public final	sh_init	= Object.Load('/part/init_v')
	public final	sh_draw	= Object.Load('/part/draw/main_v')
	public final	sh_root	= Object.Load('/part/root_v')
	public final	sh_tool	= Object.Load('/part/tool_v')
	# fur shaders
	public final	sh_fur_init	= Object.Load('/part/fur/init_v')
	public final	sh_fur_root	= Object.Load('/part/fur/root_v')
	# born shaders
	public final	sh_born_instant	= Object.Load('/part/born/instant_v')
	public final	sh_born_static	= Object.Load('/part/born/static_v')
	public final	sh_born_time	= Object.Load('/part/born/time_v')
	public final	sh_born_loop	= Object.Load('/part/born/loop_v')
	# emit surface shaders
	public final	sh_surf_node	= Object.Load('/part/surf/node_v')
	public final	sh_surf_vertex	= Object.Load('/part/surf/vertex_v')
	public final	sh_surf_face	= Object.Load('/part/surf/face_v')
