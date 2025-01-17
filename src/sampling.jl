"""
	Contains all function for sampling expressions and from expressions
"""


"""
    rand(::Type{RuleNode}, grammar::Grammar, typ::Symbol, max_depth::Int=10)

Generates a random RuleNode of return type typ and maximum depth max_depth.
"""
function Base.rand(::Type{RuleNode}, grammar::Grammar, typ::Symbol, max_depth::Int=10, 
    bin::Union{NodeRecycler,Nothing}=nothing)
    rules = grammar[typ]
    
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
            push!(rulenode.children, rand(RuleNode, grammar, ch, max_depth-1, bin))
        end
    end
    return rulenode
end
"""
    rand(::Type{RuleNode}, grammar::Grammar, typ::Symbol, dmap::AbstractVector{Int}, max_depth::Int=10)

Generates a random RuleNode of return type typ and maximum depth max_depth guided by a minimum depth map dmap.
"""
function Base.rand(::Type{RuleNode}, grammar::Grammar, typ::Symbol, dmap::AbstractVector{Int}, 
    max_depth::Int=10, bin::Union{NodeRecycler,Nothing}=nothing)
    rules = grammar[typ]
    rule_index = StatsBase.sample(filter(r->dmap[r] ≤ max_depth, rules))

    rulenode = iseval(grammar, rule_index) ?
        RuleNode(bin, rule_index, Core.eval(grammar, rule_index)) :
        RuleNode(bin, rule_index)

    if !grammar.isterminal[rule_index]
        for ch in child_types(grammar, rule_index)
            push!(rulenode.children, rand(RuleNode, grammar, ch, dmap, max_depth-1, bin))
        end
    end
    return rulenode
end

mutable struct RuleNodeAndCount
    node::RuleNode
    cnt::Int
end
"""
    sample(root::RuleNode, typ::Symbol, grammar::Grammar, maxdepth::Int=typemax(Int))

Selects a uniformly random node from the tree, limited to maxdepth.
"""
function StatsBase.sample(root::RuleNode, maxdepth::Int=typemax(Int))
    x = RuleNodeAndCount(root, 1)
    for child in root.children
        _sample(child, x, maxdepth-1)
    end
    x.node
end
function _sample(node::RuleNode, x::RuleNodeAndCount, maxdepth::Int)
    maxdepth < 1 && return
    x.cnt += 1
    if rand() <= 1/x.cnt
        x.node = node
    end
    for child in node.children
        _sample(child, x, maxdepth-1)
    end
end

"""
    sample(root::RuleNode, typ::Symbol, grammar::Grammar,
                          maxdepth::Int=typemax(Int))

Selects a uniformly random node of the given return type, typ, limited to maxdepth.
"""
function StatsBase.sample(root::RuleNode, typ::Symbol, grammar::Grammar,
                          maxdepth::Int=typemax(Int))
    x = RuleNodeAndCount(root, 0)
    if grammar.types[root.ind] == typ
        x.cnt += 1
    end
    for child in root.children
        _sample(child, typ, grammar, x, maxdepth-1)
    end
    grammar.types[x.node.ind] == typ || error("type $typ not found in RuleNode")
    x.node
end
function _sample(node::RuleNode, typ::Symbol, grammar::Grammar, x::RuleNodeAndCount,
                 maxdepth::Int)
    maxdepth < 1 && return
    if grammar.types[node.ind] == typ
        x.cnt += 1
        if rand() <= 1/x.cnt
            x.node = node
        end
    end
    for child in node.children
        _sample(child, typ, grammar, x, maxdepth-1)
    end
end




mutable struct NodeLocAndCount
	loc::NodeLoc
	cnt::Int
end


"""
	sample(::Type{NodeLoc}, root::RuleNode, maxdepth::Int=typemax(Int))
    
Selects a uniformly random node in the tree no deeper than maxdepth using reservoir sampling.
Returns a NodeLoc that specifies the location using its parent so that the subtree can be replaced.
"""
    
function StatsBase.sample(::Type{NodeLoc}, root::RuleNode, maxdepth::Int=typemax(Int))
	x = NodeLocAndCount(root_node_loc(root), 1)
	_sample(NodeLoc, root, x, maxdepth-1)
	x.loc
end


function _sample(::Type{NodeLoc}, node::RuleNode, x::NodeLocAndCount, maxdepth::Int)
	maxdepth < 1 && return
	for (j,child) in enumerate(node.children)
	    x.cnt += 1
	    if rand() <= 1/x.cnt
		x.loc = NodeLoc(node, j)
	    end
	    _sample(NodeLoc, child, x, maxdepth-1)
	end
end
    
"""
	sample(::Type{NodeLoc}, root::RuleNode, typ::Symbol, grammar::Grammar)
    
Selects a uniformly random node in the tree of a given type, specified using its parent such that the subtree can be replaced.
Returns a NodeLoc.
"""
function StatsBase.sample(::Type{NodeLoc}, root::RuleNode, typ::Symbol, grammar::Grammar,
			      maxdepth::Int=typemax(Int))
	x = NodeLocAndCount(root_node_loc(root), 0)
	if grammar.types[root.ind] == typ
	    x.cnt += 1
	end
	_sample(NodeLoc, root, typ, grammar, x, maxdepth-1)
	grammar.types[get(root,x.loc).ind] == typ || error("type $typ not found in RuleNode")
	x.loc
end
    
function _sample(::Type{NodeLoc}, node::RuleNode, typ::Symbol, grammar::Grammar,
		     x::NodeLocAndCount, maxdepth::Int)
	maxdepth < 1 && return
	for (j,child) in enumerate(node.children)
	    if grammar.types[child.ind] == typ
		x.cnt += 1
		if rand() <= 1/x.cnt
		    x.loc = NodeLoc(node, j)
		end
	    end
	    _sample(NodeLoc, child, typ, grammar, x, maxdepth-1)
	end
end