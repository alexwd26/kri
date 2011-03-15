﻿namespace kri.shade

import OpenTK.Graphics.OpenGL

#-----------------------#
#	SMART SHADER 		#
#-----------------------#

public class Smart2(Program):
	private final repList	= List[of rep.Base]()
	private sourceList		as (par.IBaseRoot)
	private static activeProgram		as Smart2	= null
	public static final prefixAttrib	as string	= 'at_'
	public static final prefixGhost		as string	= 'ghost_'
	public static final ghostSym		as string	= '@'
	public static final prefixUnit		as string	= 'unit_'
	
	public static final Fixed = Smart2(0)
	
	public def constructor():
		super()
	private def constructor(xid as int):
		super(xid)
	public def constructor(sa as Smart2):
		super( sa.handle )	# cloning
		repList.Extend( sa.repList )
		sourceList = array[of par.IBaseRoot]( sa.sourceList.Length )
		sa.sourceList.CopyTo( sourceList, 0 )
	
	public def attribs(sl as kri.lib.Slot, *ats as (int)) as void:
		for a in ats:
			name = sl.Name[a]
			continue if string.IsNullOrEmpty(name)
			if name.StartsWith(ghostSym):
				attrib( a, prefixGhost + name.Substring(ghostSym.Length) )
			else: attrib( a, prefixAttrib+name )
	public def attribs(sl as kri.lib.Slot) as void:
		attribs(sl, *List[of int](range(sl.Size)).ToArray() )
	
	public def useBare() as void:
		activeProgram = self
		bind()
	
	public def use() as void:
		useBare()
		UpdatePar()
	
	# link with attributes
	public def link(sl as kri.lib.Slot, *dicts as (rep.Dict)) as void:
		attribs(sl)
		link()
		checkAttribs(sl)
		fillPar(true,*dicts)
	
	# clear objects
	public override def clear() as void:
		repList.Clear()
		sourceList = null
		super()
	
	# collect used attributes
	public def gatherAttribs(sl as kri.lib.Slot, ghost as bool) as int*:
		for i in range(sl.Size):
			name = sl.Name[i]
			continue	if string.IsNullOrEmpty(name)
			if name.StartsWith(ghostSym):
				if not ghost: continue
				name = prefixGhost + name.Substring( ghostSym.Length )
			else: name = prefixAttrib+name
			yield i	if i == GL.GetAttribLocation(handle,name)

	# check used attributes
	public def checkAttribs(sl as kri.lib.Slot) as void:
		num = getAttribNum()
		name = System.Text.StringBuilder()
		aux0,aux1,size = 100,0,0
		type as ActiveAttribType
		for i in range(num):
			GL.GetActiveAttrib(handle,i, aux0,aux1,size,type, name)
			str = name.ToString()
			continue	if str.StartsWith('gl_')	#workaround
			pre,ps = '',''
			for ps in (prefixAttrib,prefixGhost,''):
				break	if str.StartsWith(ps)
			pre = ghostSym	if ps == prefixGhost
			assert sl.find( pre + str.Substring(ps.Length) ) >= 0
	
	# re-upload parameters
	public static def UpdatePar() as void:
		for rp in activeProgram.repList:
			iv = activeProgram.sourceList[ rp.loc ]
			rp.upload(iv)
	
	# setup units & gather uniforms
	public def fillPar( reset as bool, *dicts as (rep.Dict) ) as void:
		num,tun = -1,0
		GL.GetProgram(handle, ProgramParameter.ActiveUniforms, num)
		if reset:
			GL.UseProgram(handle)	# for texture units
			sourceList = array[of par.IBaseRoot](num+5)	#todo: fix number
			repList.Clear()
		nar = ( GL.GetActiveUniformName(handle,i) for i in range(num) )
		for name in nar:
			# todo: add support for arrays
			# need to unwrap the array into separate cells
			iv	as par.IBaseRoot = null
			for d in dicts:
				d.TryGetValue(name,iv)
				break	if iv
			if iv or reset:
				loc = getLocation(name)
				assert iv and loc >= 0
				sourceList[loc] = iv
			continue	if not reset
			rp as rep.Base	= null
			if name.StartsWith(prefixUnit):
				rp = rep.Unit(loc,tun)
				++tun
			else: rp = rep.Base.Create(iv,loc)
			assert rp
			repList.Add(rp)


	public def getAttribNum() as int:
		assert Ready
		num = -1
		GL.GetProgram(handle, ProgramParameter.ActiveAttributes, num)
		return num

	# gather total attrib size
	public def getAttribSize() as int:
		assert Ready
		num,total,size = -1,0,0
		GL.GetProgram(handle, ProgramParameter.ActiveAttributes, num)
		for i in range(num):
			tip as ActiveAttribType
			GL.GetActiveAttrib(handle, i, size, tip)
			total += size
		return total
