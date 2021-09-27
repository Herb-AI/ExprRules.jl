
"""
get_executable(rulenode::RuleNode, grammar::Grammar)

Returns the executable julia expression represented in the expression tree with root rulenode.  The returned expression can be evaluated using eval().
"""
function get_executable(rulenode::RuleNode, grammar::Grammar)
	root = (rulenode._val != nothing) ?
		rulenode._val : deepcopy(grammar.rules[rulenode.ind])
	if !grammar.isterminal[rulenode.ind] # not terminal
		root,j = _get_executable(root, rulenode, grammar)
	end
	return root
end


function _get_executable(expr::Expr, rulenode::RuleNode, grammar::Grammar, j=0)
	for (k,arg) in enumerate(expr.args)
		if isa(arg, Expr)
			expr.args[k],j = _get_executable(arg, rulenode, grammar, j)
		elseif haskey(grammar.bytype, arg)
			child = rulenode.children[j+=1]
			expr.args[k] = (child._val != nothing) ?
			child._val : deepcopy(grammar.rules[child.ind])
			if !isterminal(grammar, child)
				expr.args[k],_ = _get_executable(expr.args[k], child, grammar, 0)
			end
		end
	end
	return expr, j
end


function _get_executable(typ::Symbol, rulenode::RuleNode, grammar::Grammar, j=0)
	retval = typ
		if haskey(grammar.bytype, typ)
			child = rulenode.children[1]
			retval = (child._val !== nothing) ?
				child._val : deepcopy(grammar.rules[child.ind])
			if !grammar.isterminal[child.ind]
				retval,_ = _get_executable(retval, child, grammar, 0)
			end
		end
	retval, j
end

"""
Core.eval(rulenode::RuleNode, grammar::Grammar)

Evaluate the expression tree with root rulenode.
"""
Core.eval(rulenode::RuleNode, grammar::Grammar) = Core.eval(Main, get_executable(rulenode, grammar))
Core.eval(grammar::Grammar, index::Int) = Core.eval(Main, grammar.rules[index].args[2])

"""
Core.eval(tab::SymbolTable, ex::Expr) 

Evaluate the expression ex using symbol table tab 
"""
Core.eval(tab::SymbolTable, ex) = interpret(tab, ex)
