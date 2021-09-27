"""
	Structure representing context-sensitive grammar
	Extends ExprRules.Grammar with constraints
"""
struct ContextSensitiveGrammar <: Grammar
	rules::Vector{Any}
	types::Vector{Symbol}
	isterminal::BitVector
	iseval::BitVector
	bytype::Dict{Symbol, Vector{Int}}
	childtypes::Vector{Vector{Symbol}}
	constraints::Vector{Constraint}
end





macro csgrammar(ex)
	rules = Any[]
	types = Symbol[]
	bytype = Dict{Symbol,Vector{Int}}()
	for e in ex.args
	    if isa(e, Expr)
		if e.head == :(=)
		    s = e.args[1] # name of return type
		    rule = e.args[2] # expression?
		    rvec = Any[]
		    _parse_rule!(rvec, rule)
		    for r in rvec
			push!(rules, r)
			push!(types, s)
			bytype[s] = push!(get(bytype, s, Int[]), length(rules))
		    end
		end
	    end
	end
	alltypes = collect(keys(bytype))
	is_terminal = [isterminal(rule, alltypes) for rule in rules]
	is_eval = [iseval(rule) for rule in rules]
	childtypes = [get_childtypes(rule, alltypes) for rule in rules]
	return ContextSensitiveGrammar(rules, types, is_terminal, is_eval, bytype, childtypes, [])
end


"""
    Add constraint to the grammar
"""
addconstraint!(grammar::ContextSensitiveGrammar, cons::Constraint) = push!(grammar.constraints, cons)
