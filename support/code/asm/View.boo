﻿namespace support.asm


public class View( kri.ViewBase ):
	public	ren		as kri.rend.Basic	= null
	public	scene	as Scene			= null
	public	cam		as kri.Camera		= null
	public	final	link	= kri.rend.link.Screen()
	
	public override def resize(wid as int, het as int) as bool:
		pl = link.screen.plane
		pl.wid	= wid
		pl.het	= het
		return ren!=null and ren.setup(pl)

	public override def update() as void:
		Scene.current = scene
		if cam and link:
			cam.aspect = link.Frame.getInfo().Aspect
			kri.Ant.Inst.params.activate(cam)
		if ren and ren.active:
			ren.process(link)
		elif link:
			link.activate(false)
			link.ClearColor()
		kri.vb.Array.Default.bind()
		Scene.current = null
