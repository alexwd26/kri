﻿namespace ext.spec

import System
import System.Collections.Generic
import Boo.Lang.Compiler


#---	Make class specializations with name change	---#

[AttributeUsage(AttributeTargets.Class)]
public class Class(AbstractAstAttribute):
	private final tips	= List[of Ast.SimpleTypeReference]()
	
	public def constructor(*types as (Ast.ReferenceExpression)):
		for t in types:
			st = Ast.TypeReference.Lift(t) as Ast.SimpleTypeReference
			if not st:	raise 'not a type'
			tips.Add(st)
	
	public override def Apply(node as Ast.Node) as void:
		c = node as Ast.ClassDefinition
		if len( c.GenericParameters ) != 1:
			raise 'target has to be generic with one param'
		klass = c.DeclaringType
		gename = c.GenericParameters[0].Name
		pred = getPredicate(gename)
		# generic predicate, used for constructors
		def gePred(n as Ast.Node) as bool:
			gre = n as Ast.GenericReferenceExpression
			return false	if not gre
			arg = gre.GenericArguments
			rex = gre.Target as Ast.ReferenceExpression
			return (rex.Name == c.Name) and (arg.Count!=0) and\
				(arg[0] as Ast.SimpleTypeReference).Name == gename
		razor = ParameterRazor()
		fullpar = "${c.FullName}.${gename}"
		#printXml(m,	'class-gen')
		
		for t in tips:
			sc = c.CleanClone()
			pred = getPredicate( gename, fullpar )
			sc.GenericParameters = null
			sc.Name += '_' + t.Name.Split( char('.') )[-1]
			# replace constructors of self
			sc.ReplaceNodes(gePred, Ast.ReferenceExpression( sc.Name ))
			# replace generic type by simple one
			sc.ReplaceNodes(pred,t)
			# cut out junk generic syntax
			for b in sc.BaseTypes:
				b.Accept(razor)
			# finally add the class
			klass.Members.Add(sc)
	

#---	Make method specializations with manual modifications & name change	---#

[AttributeUsage(AttributeTargets.Method)]
public class Method(AbstractAstAttribute):
	private final tips	= List[of Ast.SimpleTypeReference]()
	
	public def constructor(*types as (Ast.ReferenceExpression)):
		for t in types:
			st = Ast.TypeReference.Lift(t) as Ast.SimpleTypeReference
			if not st:	raise 'not a type'
			tips.Add(st)
			
	protected virtual def Mod(m as Ast.Method, t as Ast.SimpleTypeReference) as void:
		pass

	public override def Apply(node as Ast.Node) as void:
		m = node as Ast.Method
		if len( m.GenericParameters ) != 1:
			raise 'target has to be generic with one param'
		klass = m.DeclaringType
		pred = getPredicate( m.GenericParameters[0].Name )
		#printXml(m,	'method-gen')
		
		for t in tips:
			sm = m.CleanClone()
			pred = getPredicate( sm.GenericParameters[0].Name )
			sm.GenericParameters = null
			# rename if the target generic is not in the parameter list
			noRename = sm.Parameters.Contains() do(par as Ast.ParameterDeclaration):
				return par.ReplaceNodes(pred,t)>0
			if not noRename:
				sm.Name += '_' + t.Name.Split( char('.') )[-1]
			# replace generic type by simple one
			sm.ReplaceNodes(pred,t)
			# finally add the method
			klass.Members.Add(sm)
			Mod(sm,t)	# custom mod


#---	Make specializations with substitution, change name & cleanup	---#
[AttributeUsage(AttributeTargets.Method)]
public class ForkMethod(Method):
	protected final pred as Ast.NodePredicate
	protected final fold as Ast.ReferenceExpression
	protected final fnew as Ast.ReferenceExpression

	public def constructor(old as Ast.ReferenceExpression,
	new as Ast.ReferenceExpression, *types as (Ast.ReferenceExpression)):
		super(*types)
		fold,fnew = old,new
		pred = def(n as Ast.Node):
			exp = n as Ast.ReferenceExpression
			return false if not exp
			return exp.Name == fold.Name
		
	protected override def Mod(m as Ast.Method, t as Ast.SimpleTypeReference) as void:
		m.Body.Statements.Reject() do(st as Ast.Statement):
			sdec = st as Ast.DeclarationStatement
			if sdec:	# delete original declaration
				return sdec.Declaration.Name == fold.Name
			return false
		m.ReplaceNodes(pred,fnew)


#---	Make specializations with substitution, change name & cleanup	---#
[AttributeUsage(AttributeTargets.Method)]
public class ForkMethodEx(Method):
	protected final pred as Ast.NodePredicate
	protected final fold as Ast.ReferenceExpression
	protected final fnew = Ast.ReferenceExpression()

	public def constructor(old as Ast.ReferenceExpression, *types as (Ast.ReferenceExpression)):
		super(*types)
		fold = old
		pred = def(n as Ast.Node):
			exp = n as Ast.GenericReferenceExpression
			return false if not exp
			target = exp.Target as Ast.ReferenceExpression
			return false if not target or target.Name != fold.Name
			exp.GenericArguments = null
			return true
		
	protected override def Mod(m as Ast.Method, t as Ast.SimpleTypeReference) as void:	
		fnew.Name = fold.Name + '_' + t.Name
		m.ReplaceNodes(pred,fnew)
