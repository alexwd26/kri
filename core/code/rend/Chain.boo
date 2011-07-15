﻿namespace kri.rend

import System.Collections.Generic
import OpenTK.Graphics.OpenGL

public class QueryPool:
	private	final list	= List[of kri.Query]()
	public def push(qs as kri.Query*) as void:
		list.AddRange(qs)
	public def fetch() as kri.Query:
		if list.Count:
			q = list[0]
			list.RemoveAt(0)
			return q
		return kri.Query()


#---------	RENDER CHAIN MANAGER	--------#

public class Chain(Basic):
	public	final	renders	= List[of Basic]()		# *Render
	public	final	ln		as link.Buffer
	public	doProfile		as bool	= false
	private	final	dpro	= Dictionary[of Basic,kri.Query]()
	private final	qpool	= QueryPool()
	private	final	tun		= kri.shade.par.Texture('input')
	private final	buCopy	as kri.shade.Bundle	= null
	
	public def constructor(ns as byte, bc as byte, bd as byte):
		ln = link.Buffer(ns,bc,bd)
		if kri.Ant.Inst.gamma:
			d = kri.shade.par.Dict()
			d.unit(tun)
			buCopy = kri.shade.Bundle()
			buCopy.dicts.Add(d)
			buCopy.shader.add('/copy_v','/copy_f')

	public def constructor():
		self(0,0,0)

	public override def setup(pl as kri.buf.Plane) as bool:
		ln.resize(pl)
		return renders.TrueForAll() do(r as Basic):
			return r.setup(pl)
		
	public override def process(con as link.Basic) as void:
		if not ln.Ready:
			return
		qpool.push( dpro.Values )
		dpro.Clear()
		for r in renders:
			if not r.active:	continue
			if doProfile:
				dpro[r] = q = qpool.fetch()
				using q.catch( QueryTarget.TimeElapsed ):
					r.process(ln)
			else:	r.process(ln)
		if con:
			con.activate(false)
			if buCopy:
				tun.Value = ln.buf.at.color[0] as kri.buf.Texture
				kri.Ant.Inst.quad.draw(buCopy)
			else:	ln.blitTo(con)
				
	public def genReport() as string:
		rez = 'Profile report:'
		for p in dpro:
			name = p.Key.ToString()
			time = p.Value.result()
			rez += "\n${name}: ${time}"
		return rez