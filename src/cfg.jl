

"""
Grammar

Represents a grammar and its production rules.
Use the @grammar macro to create a Grammar object.
"""
struct ContextFreeGrammar <: Grammar
	rules::Vector{Any}    # list of RHS of rules (subexpressions)
	types::Vector{Symbol} # list of LHS of rules (types, all symbols)
	isterminal::BitVector # whether rule i is terminal
	iseval::BitVector     # whether rule i is an eval rule
	bytype::Dict{Symbol,Vector{Int}}   # maps type to all rules of said type
	childtypes::Vector{Vector{Symbol}} # list of types of the children for each rule. Empty if terminal
end
"""
@grammar

Define a grammar and return it as a Grammar. For example:
```julia-repl
grammar = @grammar begin
R = x
R = 1 | 2
R = R + R
end
```
"""
macro cfgrammar(ex)
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
	return ContextFreeGrammar(rules, types, is_terminal, is_eval, bytype, childtypes)
end

_parse_rule!(v::Vector{Any}, r) = push!(v, r)

function _parse_rule!(v::Vector{Any}, ex::Expr)
	if ex.head == :call && ex.args[1] == :|
		terms = length(ex.args) == 2 ?
		collect(interpret(ex.args[2])) :    #|(a:c) case
		ex.args[2:end]                      #a|b|c case
		for t in terms
			_parse_rule!(v, t)
		end
	else
		push!(v, ex)
	end
end


function Base.display(rulenode::RuleNode, grammar::ContextFreeGrammar)
	root = get_executable(rulenode, grammar)
	if isa(root, Expr)
	    walk_tree(root)
	else
	    root
	end
end


function _next_state!(node::RuleNode, grammar::Grammar, max_depth::Int)

	if max_depth < 1
	    return (node, false) # did not work
	elseif isterminal(grammar, node)
	    # do nothing
	    if iseval(grammar, node.ind) && (node._val === nothing)  # evaluate the rule
		node._val = eval(grammar.rules[node.ind].args[2])
	    end
	    return (node, false) # cannot change leaves
	else # !isterminal
	    # if node is not terminal and doesn't have children, expand every child
	    if isempty(node.children)  
		if max_depth ≤ 1
		    return (node,false) # cannot expand
		end
    
		# build out the node
		for c in child_types(grammar, node)
    
		    worked = false
		    i = 0
		    child = RuleNode(0)
		    child_rules = grammar[c]
		    while !worked && i < length(child_rules)
			i += 1
			child = RuleNode(child_rules[i])
    
			if iseval(grammar, child.ind) # if rule needs to be evaluated (_())
			    child._val = eval(grammar.rules[child.ind].args[2])
			end
			worked = true
			if !isterminal(grammar, child)
			    child, worked = _next_state!(child, grammar, max_depth-1)
			end
		    end
		    if !worked
			return (node, false) # did not work
		    end
		    push!(node.children, child)
		end
    
		return (node, true)
	    else # not empty
		# make one change, starting with rightmost child
		worked = false
		child_index = length(node.children) + 1
		while !worked && child_index > 1
		    child_index -= 1
		    child = node.children[child_index]
    
		    child, child_worked = _next_state!(child, grammar, max_depth-1)
		    while !child_worked
			child_type = return_type(grammar, child)
			child_rules = grammar[child_type]
			i = something(findfirst(isequal(child.ind), child_rules), 0)
			if i < length(child_rules)
			    child_worked = true
			    child = RuleNode(child_rules[i+1])
    
			    # node needs to be evaluated
			    if iseval(grammar, child.ind)
				child._val = eval(grammar.rules[child.ind].args[2])
			    end
    
			    if !isterminal(grammar, child)
				child, child_worked = _next_state!(child, grammar, max_depth-1)
			    end
			    node.children[child_index] = child
			else
			    break
			end
		    end
    
		    if child_worked
			worked = true
    
			# reset remaining children
			for child_index2 in child_index+1 : length(node.children)
			    c = child_types(grammar, node)[child_index2]
			    worked = false
			    i = 0
			    child = RuleNode(0)
			    child_rules = grammar[c]
			    while !worked && i < length(child_rules)
				i += 1
				child = RuleNode(child_rules[i])
    
				if iseval(grammar, child.ind)
				    child._val = eval(grammar.rules[child.ind].args[2])
				end
    
				worked = true
				if !isterminal(grammar, child)
				    child, worked = _next_state!(child, grammar, max_depth-1)
				end
			    end
			    if !worked
				break
			    end
			    node.children[child_index2] = child
			end
		    end
		end
    
		return (node, worked)
	    end
	end
    end