"""
rand(::Type{RuleNode}, grammar::Grammar, typ::Symbol, max_depth::Int=10)
Generates a random RuleNode of return type typ and maximum depth max_depth.
"""
function Base.rand(::Type{RuleNode}, grammar::ContextSensitiveGrammar, typ::Symbol, max_depth::Int=10, 
	context::Union{GrammarContext,Nothing}=nothing, bin::Union{NodeRecycler,Nothing}=nothing)

	if context === nothing
		# first call, context not set yet
		init_node = RuleNode(0)
		context = GrammarContext(init_node)
	end

	rules = deepcopy(grammar[typ])
	# propagate constraints 
	rules = propagate_contraints(grammar, context, rules)

	if max_depth <= 1
	    terminals = filter(r->isterminal(grammar,r), rules)
	    rule_index = !isempty(terminals) ? StatsBase.sample(terminals) : StatsBase.sample(rules)
	else    
	    rule_index = StatsBase.sample(rules)
	end

	rulenode = iseval(grammar, rule_index) ?
	    RuleNode(bin, rule_index, Core.eval(grammar, rule_index)) :
	    RuleNode(bin, rule_index)

	if !grammar.isterminal[rule_index]
	    	for ch in child_types(grammar, rule_index)
			#create context for the child expansion
			new_context = GrammarContext(rulenode, deepcopy(context.nodeLocation))
			push!(new_context.nodeLocation, length(rulenode.children) + 1)
			push!(rulenode.children, rand(RuleNode, grammar, ch, max_depth-1, new_context, bin))
	    	end
	end

	return rulenode
end



"""
    rand(::Type{RuleNode}, grammar::Grammar, typ::Symbol, dmap::AbstractVector{Int}, max_depth::Int=10)
Generates a random RuleNode of return type typ and maximum depth max_depth guided by a minimum depth map dmap.
"""
function Base.rand(::Type{RuleNode}, grammar::ContextSensitiveGrammar, typ::Symbol, dmap::AbstractVector{Int}, 
	max_depth::Int=10, context::Union{GrammarContext,Nothing}=nothing, bin::Union{NodeRecycler,Nothing}=nothing)

	if context === nothing
		# first call, context not set yet
		init_node = RuleNode(0)
		context = GrammarContext(init_node)
	end

    	rules = grammar[typ]
	    # propagate constraints 
	rules = propagate_constraints(grammar, context, rules)
    	rule_index = StatsBase.sample(filter(r->dmap[r] ≤ max_depth, rules))

	rulenode = iseval(grammar, rule_index) ?
 		RuleNode(bin, rule_index, Core.eval(grammar, rule_index)) :
 		RuleNode(bin, rule_index)

    	if !grammar.isterminal[rule_index]
        	for ch in child_types(grammar, rule_index)
			# create context for the child expansion
			new_context = GrammarContext(rulenode, deepcopy(context.nodeLocation))
			push!(new_context.nodeLocation, length(rulenode.children) + 1)
            		push!(rulenode.children, rand(RuleNode, grammar, ch, dmap, max_depth-1, new_context, bin))
       	 	end
    	end
    return rulenode
end