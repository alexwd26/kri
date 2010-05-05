﻿namespace kri.load

import System
import System.Collections.Generic
import OpenTK

#------		LOAD ATOM		------#

public class Atom:
	public final scene		as kri.Scene
	public final nodes		= Dictionary[of string,kri.Node]()
	public final mats		= Dictionary[of string,kri.Material]()
	
	public def constructor(name as string):
		scene = kri.Scene(name)
		nodes[''] = null

public partial class Settings:
	public final skipChunks = List[of string]()

#------		CHUNK LOADER		------#

public partial class Native:
	public struct ResNode:
		public name as string
		public fun	as callable(kri.Node)

	public final con	= Context()
	public final dict	= Dictionary[of string,callable() as bool]()
	public final skipt	= Dictionary[of string,uint]()
	public final sets	= Settings()
	private final rep	= []
	private final nResList	= List[of ResNode]()
	private br	as IO.BinaryReader	= null
	private at	as Atom	= null
	
	public def addResolve(fun as callable(kri.Node)) as void:
		nResList.Add( ResNode( name:getString(), fun:fun ))
	
	public def constructor():
		initAnimations()
		initMaterials()
		# Fill chunk dictionary
		dict['kri']		= p_sign
		dict['grav']	= p_grav
		# objects
		dict['node']	= p_node
		dict['entity']	= p_entity
		dict['skel']	= p_skel
		dict['cam']		= p_cam
		dict['lamp']	= p_lamp
		# material
		dict['mat']		= p_mat
		dict['m_hair']	= pm_hair
		dict['m_halo']	= pm_halo
		dict['m_surf']	= pm_surf
		dict['m_diff']	= pm_diff
		dict['m_spec']	= pm_spec
		dict['unit']	= pm_unit
		dict['tex']		= pm_tex
		# animations
		dict['action']	= p_action
		dict['curve']	= p_curve
		# mesh
		dict['mesh']	= p_mesh
		dict['v_pos']	= pv_pos
		dict['v_quat']	= pv_quat
		dict['v_uv']	= pv_uv
		dict['v_skin']	= pv_skin
		dict['v_ind']	= pv_ind
		# particles
		dict['part']	= p_part
		dict['p_dist']	= pp_dist
		dict['p_life']	= pp_life
		dict['p_hair']	= pp_hair
		dict['p_vel']	= pp_vel
		dict['p_rot']	= pp_rot
		dict['p_phys']	= pp_phys
		# particle render
		dict['pr_inst']	= ppr_inst
		# physics
		dict['collide']	= p_collide
		dict['b_stat']	= pb_stat
		dict['b_rigid'] = pb_rigid
	
	public def read(path as string) as Atom:
		kri.res.check(path)
		rep.Clear()
		br = IO.BinaryReader( IO.File.OpenRead(path) )
		at = Atom(path)
		bs = br.BaseStream
		while bs.Position != bs.Length:
			name = getString(8)
			size = br.ReadUInt32()
			size += bs.Position
			assert size <= bs.Length
			if name in sets.skipChunks:
				bs.Seek(size, IO.SeekOrigin.Begin)
				continue
			p as callable() as bool = null
			if dict.TryGetValue(name,p) and p():
				assert bs.Position == size
			else:
				skipt[name] = size
				bs.Seek(size, IO.SeekOrigin.Begin)
		br.Close()
		# resolve node links
		for nr in nResList:
			nr.fun( at.nodes[nr.name] )
		nResList.Clear()
		# finish subsystems
		finishMaterials()
		finishParticles()
		return at

	protected def geData[of T]() as T:
		#return rep.Find(predicate) as T
		for ob in rep:
			t = ob as T
			return t	if t
		return null as T
	protected def puData[of T](r as T) as void:
		#rep.RemoveAll(predicate)
		rep.Remove( geData[of T] )
		rep.Insert(0,r)
	
	protected def getReal() as single:
		return br.ReadSingle()
	protected def getScale() as single:
		return getVector().LengthSquared / 3f
	protected def getColor() as Color4:
		return Color4( getReal(), getReal(), getReal(), 1f )
	protected def getColorByte() as Color4:
		c = br.ReadBytes(3)	#rbg
		a as byte = 0xFF
		return Color4(c[0],c[1],c[2],a)
	protected def getColorFull() as Color4:
		c = getColorByte()
		c.A = getReal()	# alpha
		v = getReal()	# intensity
		c.R *= v
		c.G *= v
		c.B *= v
		return c

	protected def getString(size as byte) as string:
		return string( br.ReadChars(size) ).TrimEnd( char(0) )
	protected def getString() as string:
		return getString( br.ReadByte() )
	protected def getVector() as Vector3:
		return Vector3( X:getReal(), Y:getReal(), Z:getReal() )
	protected def getVec2() as Vector2:
		return Vector2( X:getReal(), Y:getReal() )
	protected def getVec4() as Vector4:
		return Vector4( Xyz:getVector(), W:getReal() )
	protected def getQuat() as Quaternion:
		return Quaternion( Xyz:getVector(), W:getReal() )
	protected def getQuatRev() as Quaternion:
		return Quaternion( W:getReal(), Xyz:getVector() )
	protected def getQuatEuler() as Quaternion:
		return kri.Spatial.EulerQuat( getVector() )
	protected def getSpatial() as kri.Spatial:
		return kri.Spatial( pos:getVector(), scale:getReal(), rot:getQuat() )
	
	public def p_sign() as bool:
		ver = br.ReadByte()
		assert ver == 3 and not rep.Count
		return true
	public def p_grav() as bool:
		at.scene.pGravity = pg = kri.shade.par.Value[of Vector4]('gravity')
		pg.Value = Vector4( getVector() )
		return true
