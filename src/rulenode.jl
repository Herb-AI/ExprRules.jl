
"""
RuleNode

Type for representing nodes in an expression tree.
"""
mutable struct RuleNode
	ind::Int # index in grammar
	_val::Any  #value of _() evals
	children::Vector{RuleNode}
end

RuleNode(ind::Int) = RuleNode(ind, nothing, RuleNode[])
RuleNode(ind::Int, children::Vector{RuleNode}) = RuleNode(ind, nothing, children)
RuleNode(ind::Int, _val::Any) = RuleNode(ind, _val, RuleNode[])

include("recycler.jl")

function Base.:(==)(A::RuleNode, B::RuleNode)
	(A.ind == B.ind) &&
	    (A._val == B._val) && 
	    (length(A.children) == length(B.children)) && #required because zip doesn't check lengths
	    all(isequal(a,b) for (a,b) in zip(A.children, B.children))
    end
    
function Base.hash(node::RuleNode, h::UInt=zero(UInt))
	retval = hash(node.ind, h)
	for child in node.children
		retval = hash(child, retval)
	end

	return retval
end

function Base.show(io::IO, node::RuleNode; separator=",", last_child::Bool=false)
	print(io, node.ind)
	if !isempty(node.children)
	    print(io, "{")
	    for (i,c) in enumerate(node.children)
		show(io, c, separator=separator, last_child=(i == length(node.children)))
	    end
	    print(io, "}")
	elseif !last_child
	    print(io, separator)
	end
end
    
"""
Return the number of vertices in the tree rooted at root.
"""
function Base.length(root::RuleNode)
	retval = 1
	for c in root.children
	    retval += length(c)
	end
	return retval
end
    
"""
	depth(root::RuleNode)
    
Return the depth of the expression tree rooted at root.
"""
function depth(root::RuleNode)
	retval = 1
	for c in root.children
	    retval = max(retval, depth(c)+1)
	end
	return retval
end
    
"""
	node_depth(root::RuleNode, node::RuleNode)
    
Return the depth of node for an expression tree rooted at root.  Depth is 1 when root == node.
"""
function node_depth(root::RuleNode, node::RuleNode)
	root === node && return 1
	for c in root.children
	    d = node_depth(c, node)
	    d > 0 && (return d+1)
	end
	return 0
end