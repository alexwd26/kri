﻿namespace support.defer

import OpenTK.Graphics.OpenGL
import kri.shade

#---------	DEFERRED BASE APPLY		--------#

public class ApplyBase( kri.rend.Basic ):
	protected final sa		= Smart()
	protected final sphere	as kri.Mesh
	protected final dict	= rep.Dict()
	private final va		= kri.vb.Array()
	private texDepth			as par.Texture	= null
	# custom activation
	private virtual def onInit() as void:
		pass
	private virtual def onDraw() as void:
		pass
	# init
	public def constructor(qord as byte):
		# bake sphere attribs
		va.bind()	# the buffer objects are bound in creation
		sphere = kri.gen.Sphere( qord, OpenTK.Vector3.One )
		sphere.vbo[0].attrib( kri.Ant.Inst.attribs.vertex )
	# link
	protected def relink(con as Context) as void:
		texDepth = con.texDepth
		sa.add( '/lib/quat_v','/lib/tool_v','/lib/defer_f' )
		sa.add( con.sh_apply, con.sh_diff, con.sh_spec )
		sa.link( kri.Ant.Inst.slotAttributes, con.dict, kri.Ant.Inst.dict )
	# work
	public override def process(con as kri.rend.link.Basic) as void:
		texDepth.Value = con.Depth
		con.activate(false)
		onInit()
		# enable depth check
		con.activate( con.Target.Same, 0f, false )
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
	private final texLit	= par.Value[of kri.buf.Texture]('light')
	private final context	as support.light.Context
	# init
	public def constructor(con as Context, lc as support.light.Context, qord as byte):
		super(qord)
		context = lc
		sa.add('/g/apply_v')
		relink(con)
		# fill shader
		s0.add( '/copy_v', '/g/init_f' )
		s0.link( kri.Ant.Inst.slotAttributes, dict, kri.Ant.Inst.dict )
	# shadow
	private def bindShadow(t as kri.buf.Texture) as void:
		if t:
			texLit.Value = t
			t.filt(false,false)
			t.shadow(false)
		else:
			texLit.Value = context.defShadow
	# work
	private override def onInit() as void:
		s0.use()
		kri.Ant.Inst.quad.draw()
	private override def onDraw() as void:
		for l in kri.Scene.Current.lights:
			bindShadow( l.depth )
			kri.Ant.Inst.params.activate(l)
			sa.use()
			sphere.draw(1)
