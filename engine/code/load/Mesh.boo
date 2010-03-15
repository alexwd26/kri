﻿namespace kri.load

import OpenTK
import OpenTK.Graphics.OpenGL

public partial class Native:
	protected def getArray[of T(struct)](multi as uint,
			ref ai as kri.vb.attr.Info, fun as callable) as bool:
		m = geData[of kri.Mesh]()
		return false	if not m
		ar = array[of T]( multi * m.nVert )
		for i in range( ar.Length ):
			ar[i] = fun()
		v = kri.vb.Attrib()
		v.init(ar,false)
		v.semantics.Add(ai)
		m.vbo.Add(v)
		return true

	#---	Parse mesh	---#
	public def p_mesh() as bool:
		m = kri.Mesh( BeginMode.Triangles )
		puData(m)
		m.nVert = br.ReadInt16()
		return true
	
	#---	Parse mesh vertices	---#
	public def pv_pos() as bool:
		ai = kri.vb.attr.Info(
			slot: kri.Ant.Inst.attribs.vertex, size:3,
			type: VertexAttribPointerType.Float,
			integer:false )
		return getArray[of Vector3](1,ai,getVector)
	
	#---	Parse mesh quaternions 	---#
	public def pv_quat() as bool:
		ai = kri.vb.attr.Info(
			slot: kri.Ant.Inst.attribs.quat, size:4,
			type: VertexAttribPointerType.Float,
			integer:false )
		return getArray[of Quaternion](1,ai,getQuat)
	
	#---	Parse mesh texture coordinates (UVh)	---#
	public def pv_uv() as bool:
		ai = kri.vb.attr.Info(	#warning! no multi-coord support
			slot: kri.Ant.Inst.attribs.tex, size:3,
			type: VertexAttribPointerType.Float,
			integer:false )
		return getArray[of Vector3](1,ai,getVector)
	
	#---	Parse mesh armature link with bone weights	---#
	public def pv_skin() as bool:
		ai = kri.vb.attr.Info(
			slot: kri.Ant.Inst.attribs.skin, size:4,
			type: VertexAttribPointerType.UnsignedShort,
			integer:true )
		rez = getArray[of ushort](4,ai, {return br.ReadUInt16()})
		return false	if not rez
		# link to the Armature
		kri.kit.skin.prepare(
			geData[of kri.Entity](),
			geData[of kri.Skeleton]() )
		return true
	
	#---	Parse mesh indexes	---#
	public def pv_ind() as bool:
		m = geData[of kri.Mesh]()
		return false	if not m
		m.nPoly = br.ReadUInt16()
		if m.nPoly:	# indexes
			af = array[of ushort](m.nPoly * 3)
			for i in range(af.Length):
				af[i] = br.ReadUInt16()
			m.ind = kri.vb.Index()
			m.ind.init(af,false)
		else: m.nPoly /= 3
		return true
