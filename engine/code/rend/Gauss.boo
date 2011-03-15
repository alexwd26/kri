﻿namespace kri.rend.gauss

import OpenTK
import kri.buf
import kri.shade

#---------	GAUSS FILTER	--------#

public class Simple( kri.rend.Basic ):
	protected	final pu	= Bundle()
	protected	final pv	= Bundle()
	protected	final texIn	= par.Texture('input')
	public		final va	as kri.vb.Array
	public		fbo		as Holder	= null

	public def constructor():
		dict = rep.Dict()
		dict.unit(texIn)
		pu.shader.add('/copy_v','/filter/gauss_hor_f')
		pu.dicts.Add(dict)
		pv.shader.add('/copy_v','/filter/gauss_ver_f')
		pv.dicts.Add(dict)
		va = kri.Ant.inst.quad.renderTest(pu)

	public override def process(con as kri.rend.link.Basic) as void:
		return	if not fbo
		assert fbo.at.color[0] and fbo.at.color[1]
		for i in range(2):
			texIn.Value = fbo.at.color[i] as Texture
			fbo.mask = 3 ^ (1<<i)
			fbo.bind()
			kri.Ant.inst.quad.render(va, (pu,pv)[i], null, 1)


public class Advanced( kri.rend.Basic ):
	public	final	bu		= Bundle()
	public	final	pTex	= par.Texture('input')
	public	final	pDir	= par.Value[of Vector4]('dir')
	public	final	va		as kri.vb.Array
	public	fbo		as Holder = null
	
	public def constructor():
		d = rep.Dict()
		d.unit(pTex)
		d.var(pDir)
		bu.shader.add('/copy_v','/filter/gauss_bi_f')
		bu.dicts.Add(d)
		va = kri.Ant.inst.quad.renderTest(bu)
	
	public def spawn() as (kri.rend.Basic):
		return ( Axis(self,Vector4.UnitX), Axis(self,Vector4.UnitY) )
	
	public override def process(con as kri.rend.link.Basic) as void:
		return	if not fbo
		assert fbo.at.color[0] and fbo.at.color[1]
		for i in range(2):
			pTex.Value = fbo.at.color[i] as Texture
			pDir.Value = (Vector4.UnitX,Vector4.UnitY)[i]
			fbo.mask = 3 ^ (1<<i)
			fbo.bind()
			kri.Ant.inst.quad.render(va,bu,null,1)


public class Axis( kri.rend.Basic ):
	public final parent	as Advanced
	public final dir	as Vector4
	
	
	public def constructor(par as Advanced, axis as Vector4):
		parent = par
		dir = axis
	
	public override def process(con as kri.rend.link.Basic) as void:
		parent.pTex.Value = con.Input
		parent.pDir.Value = dir
		con.activate(true)
		kri.Ant.inst.quad.render( parent.va, parent.bu, null, 1 )
