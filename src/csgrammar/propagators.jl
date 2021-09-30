"""
Propagates the ComesAfter constraint: 
	it removes the rule from the domain if the predecessors sequence is in the ancestors
"""
function propagate(c::ComesAfter, context::GrammarContext, domain::Vector{Int})
	ancestors = get_rulesequence(context.originalExpr, context.nodeLocation[begin:end-1])  # remove the current node from the node sequence
	if c.rule in domain  # if rule is in domain, check the ancestors
		if containedin(c.predecessors, ancestors)
			return domain
		else
			return filter(e -> e != c.rule, domain)
		end
	else # if it is not in the domain, just return domain
		return domain
	end
end

function propagate_index(c::ComesAfter, context::GrammarContext, domain::Vector{Int})
	ancestors = get_rulesequence(context.originalExpr, context.nodeLocation[begin:end-1])  # remove the current node from the node sequence
	if c.rule in domain  # if rule is in domain, check the ancestors
		if containedin(c.predecessors, ancestors)
			return 1:length(domain)
		else
			filter_crit(acc::Vector{Int}, e::Int) = accumulate_if!(acc, e, x -> x[2] != c.rule, x -> x[1])
			return reduce(filter_crit, enumerate(domain); init=Vector{Int}())
		end
	else # if it is not in the domain, just return domain
		return 1:length(domain)
	end	
end


"""
	Propagates Ordered constraint:
		removes every element from domain that does not have a necessary predecessor in the left subtree
"""
function propagate(c::Ordered, context::GrammarContext, domain::Vector{Int})
	expr = context.originalExpr
	rules_on_left = rulesonleft(context.originalExpr, context.nodeLocation)
	
	last_rule_index = 0
	for r in c.order
		r in rules_on_left ? last_rule_index = r : break
	end

	rules_to_remove = Set(c.order[last_rule_index+2:end]) # +2 because the one after the last index can be used

	return filter((x) -> !(x in rules_to_remove), domain) 
end

function propagate_index(c::Ordered, context::GrammarContext, domain::Vector{Int})
	rules_on_left = rulesonleft(context.originalExpr, context.nodeLocation)
	
	last_rule_index = 0
	for r in c.order
		r in rules_on_left ? last_rule_index = r : break
	end

	rules_to_remove = Set(c.order[last_rule_index+2:end]) # +2 because the one after the last index can be used

	f_to_use(acc::Vector{Int}, e::Int) = accumulate_if!(acc, e, x -> !(x[2] in rules_to_remove), x -> x[1])
	return reduce(f_to_use, enumerate(domain); init=Vector{Int}()) 
end


"""
	Propagates Forbidden constraints:
		removes the elements from the domain that would complete the forbidden sequence
"""
function propagate(c::Forbidden, context::GrammarContext, domain::Vector{Int})
	ancestors = get_rulesequence(context.originalExpr, context.nodeLocation[begin:end-1])
	if subsequenceof(c.sequence[begin:end-1], ancestors)
		last_in_seq = c.sequence[end]
		return filter(x -> !(x == last_in_seq), domain)
	end

	return domain
end

function propagate_index(c::Forbidden, context::GrammarContext, domain::Vector{Int})
	ancestors = get_rulesequence(context.originalExpr, context.nodeLocation[begin:end-1])
	if subsequenceof(c.sequence[begin:end-1], ancestors)
		last_in_seq = c.sequence[end]
		f_to_use(acc::Vector{Int}, e::Int) = accumulate_if!(acc, e, x -> !(x[2] == last_in_seq), x -> x[1])
		return reduce(f_to_use, enumerate(domain); init=Vector{Int}())
	end

	return 1:length(domain)
end