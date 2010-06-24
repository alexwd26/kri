﻿namespace kri.rend.defer

import OpenTK.Graphics.OpenGL
import kri.shade

#---------	DEFERRED BASE APPLY		--------#

public class ApplyBase( kri.rend.Basic ):
	protected final sa		= Smart()
	protected final sphere	as kri.Mesh
	protected final dict	= rep.Dict()
	private final va		= kri.vb.Array()
	private final texDep	= par.Value[of kri.Texture]('depth')
	# custom activation
	private virtual def onInit() as void:
		pass
	private virtual def onDraw() as void:
		pass
	# init
	public def constructor(qord as byte):
		super(false)
		# bake sphere attribs
		va.bind()	# the buffer objects are bound in creation
		sphere = kri.kit.gen.Sphere( qord, OpenTK.Vector3.One )
		sphere.vbo[0].attrib( kri.Ant.Inst.attribs.vertex )
	# link
	protected def relink(con as Context) as void:
		dict.unit( texDep, con.gbuf )
		sa.add( 'quat','tool','defer' )
		sa.add( con.sh_apply, con.sh_diff, con.sh_spec )
		sa.link( kri.Ant.Inst.slotAttributes, dict, kri.Ant.Inst.dict )
	# work
	public override def process(con as kri.rend.Context) as void:
		con.activate()
		texDep.Value = con.Depth
		onInit()
		# enable depth check
		con.activate(true,0f,false)
		GL.CullFace( CullFaceMode.Front )
		GL.DepthFunc( DepthFunction.Gequal )
		va.bind()
		# add lights
		using blend = kri.Blender():
			blend.add()
			onDraw()
		GL.CullFace( CullFaceMode.Back )
		GL.DepthFunc( DepthFunction.Lequal )


#---------	DEFERRED STANDARD APPLY		--------#

public class Apply( ApplyBase ):
	private final s0		= Smart()
	private final texLit	= par.Value[of kri.Texture]('light')
	private final context	as kri.rend.light.Context
	# init
	public def constructor(con as Context, lc as kri.rend.light.Context, qord as byte):
		super(qord)
		context = lc
		sa.add('/g/apply_v')
		relink(con)
		# fill shader
		s0.add( 'copy_v', '/g/init_f' )
		s0.link( kri.Ant.Inst.slotAttributes, dict, kri.Ant.Inst.dict )
	# shadow
	private def bindShadow(t as kri.Texture) as void:
		if t:
			texLit.Value = t
			t.bind()
			kri.Texture.Filter(false,false)
			kri.Texture.Shadow(false)
		else:
			texLit.Value = context.defShadow
	# work
	private override def onInit() as void:
		s0.use()
		kri.Ant.Inst.emitQuad()
	private override def onDraw() as void:
		for l in kri.Scene.current.lights:
			bindShadow( l.depth )
			kri.Ant.Inst.params.activate(l)
			sa.use()
			sphere.draw(1)
