
function _next_state! end


abstract type ExpressionIterator end


"""
    ExpressionIterator(grammar::Grammar, max_depth::Int, sym::Symbol)

An iterator over all possible expressions of a grammar up to max_depth with start symbol sym.

Types of search depends on the order of production rules in the given grammar: BFS - terminals come first; DFS: nonterminals come first
"""
mutable struct ContextFreeIterator <: ExpressionIterator
    grammar::Grammar
    max_depth::Int
    sym::Symbol
end

Base.IteratorSize(::ExpressionIterator) = Base.SizeUnknown()

Base.eltype(::ExpressionIterator) = RuleNode

function Base.iterate(iter::ExpressionIterator)
    grammar, sym, max_depth = iter.grammar, iter.sym, iter.max_depth
    node = RuleNode(grammar[sym][1])
    if isterminal(grammar, node)
        return (deepcopy(node), node)
    else
        node, worked =  _next_state!(node, grammar, max_depth)
        while !worked
            # increment root's rule
            rules = grammar[sym]
            i = something(findfirst(isequal(node.ind), rules), 0)
            if i < length(rules)
                node, worked = RuleNode(rules[i+1]), true
                if !isterminal(grammar, node)
                    node, worked = _next_state!(node, grammar, max_depth)
                end
            else
                break
            end
        end
        return worked ? (deepcopy(node), node) : nothing
    end
end

function Base.iterate(iter::ExpressionIterator, state::RuleNode)
    grammar, max_depth = iter.grammar, iter.max_depth
    node, worked = _next_state!(state, grammar, max_depth)

    while !worked
        # increment root's rule
        rules = grammar[iter.sym]
        i = something(findfirst(isequal(node.ind), rules), 0)
        if i < length(rules)
            node, worked = RuleNode(rules[i+1]), true
            if !isterminal(grammar, node)
                node, worked = _next_state!(node, grammar, max_depth)
            end
        else
            break
        end
    end
    return worked ? (deepcopy(node), node) : nothing
end

"""
    count_expressions(grammar::Grammar, max_depth::Int, sym::Symbol)

Count the number of possible expressions of a grammar up to max_depth with start symbol sym.
"""
function count_expressions(grammar::Grammar, max_depth::Int, sym::Symbol)
    retval = 0
    for root_rule in grammar[sym]
        node = RuleNode(root_rule)
        if isterminal(grammar, node)
            retval += 1
        else
            node, worked = _next_state!(node, grammar, max_depth)
            while worked
                retval += 1
                node, worked = _next_state!(node, grammar, max_depth)
            end
        end
    end
    return retval
end

"""
    count_expressions(iter::ExpressionIterator)

Count the number of possible expressions in the expression iterator.
"""
count_expressions(iter::ExpressionIterator) = count_expressions(iter.grammar, iter.max_depth, iter.sym)