﻿namespace kri.shade

import System.Collections.Generic

#-------------------------------#
#	SHADER LINKER CHACHE		#
#-------------------------------#

public class Linker:
	private final attribs	as kri.lib.Slot
	public final samap = Dictionary[of string,int]()
	public onLink	as callable(kri.shade.Smart)	= null
	
	public def constructor(ats as kri.lib.Slot):
		attribs = ats
	
	public def link(sl as kri.shade.Object*, dc as kri.shade.rep.Dict*) as kri.shade.Smart:
		key = join( (x.id.ToString() for x in sl), ',' )
		sid = -1
		if samap.TryGetValue(key,sid):
			sa = kri.shade.Smart( sid )
			# yes, we will just fill the parameters for this program ID again
			# it's not obvious, but texture units will be assigned to the old values,
			# because the meta-data sets already matched (kri.load.meta.MakeTexCoords)
		else:
			sa = kri.shade.Smart()
			samap.Add( key, sa.id )
			sa.add( *array(sl) )
			sa.attribs( attribs )
			onLink(sa)	if onLink
			sa.link()
		sa.fillPar( *array(dc) ) 
		return sa