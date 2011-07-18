﻿namespace support.cull.box

import OpenTK.Graphics.OpenGL


public class Fill( kri.rend.Basic ):
	private final bu	= kri.shade.Bundle()
	public	final va	= kri.vb.Array()
	private final fbo	= kri.buf.Holder( mask:1 )
	private final model 	as (OpenTK.Vector4)
	private final con		as support.cull.Context
	
	public def constructor(ct as support.cull.Context):
		model = array[of OpenTK.Vector4]( ct.maxn*2 )
		con = ct
		bu.shader.add( '/cull/box_v', '/cull/box_g', '/color_f' )
		fbo.at.color[0] = kri.buf.Render( format:RenderbufferStorage.Rgba32f )
		fbo.resize( ct.maxn*2, 1 )
		# initialize buffers
		fbo.bind()
		kri.rend.link.Help.ClearColor()
		for i in range(2*ct.maxn):
			model[i] = OpenTK.Vector4.Zero
	
	public override def process(link as kri.rend.link.Basic) as void:
		scene = kri.Scene.Current
		if not scene:	return
		link.DepthTest = false
		fbo.bind()
		v = single.PositiveInfinity
		doUpload = con.spatial.Allocated==0
		doDownload = false
		using blend = kri.Blender(), kri.Section(EnableCap.ScissorTest):
			blend.min()
			for e in scene.entities:
				e.frameVisible.Clear()
				bv = e.findAny('vertex')
				tag = e.seTag[of Tag]()
				if not tag:	continue
				if tag.Index<0:
					tag.Index = con.genId()
				i = 2 * tag.Index
				if tag.checkNode(e.node):
					doUpload = true
					spa = kri.Node.SafeWorld( e.node )
					model[i+0] = kri.Spatial.GetPos(spa)
					model[i+1] = kri.Spatial.GetRot(spa)				
				if tag.checkBuf(bv):
					tag.fresh = doDownload = true
					GL.Scissor	( i,0, 2,1 )
					GL.ClearBuffer( ClearBuffer.Color, 0, (v,v,v,1f) )
					GL.Viewport	( i,0, 2,1 )
					e.render( va,bu, kri.TransFeedback.Dummy )
		if doUpload:	# upload spatial data array
			con.spatial.init(model,true)
		if doDownload:	# read from texture into VBO
			kri.vb.Object.Pack = con.bound
			fbo.readBuffer[of single]( PixelFormat.Rgba )
