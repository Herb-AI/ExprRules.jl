__precompile__()

module ExprRules

import TreeView: walk_tree
using StatsBase
using AbstractTrees
using DataStructures  #NodeRecycler

include("interpreter.jl")
using .Interpreter

include("rulenode.jl")
include("grammar_base.jl")
include("expreval.jl")
include("nodelocation.jl")
include("sampling.jl")
include("iterators.jl")
include("utils.jl")

include("cfg.jl")



export
        Grammar,
        ContextFreeGrammar,
        RuleNode,
        NodeLoc,

        ExprIter,
        ExpressionIterator,

        @grammar,
        max_arity,
        depth,
        node_depth,
        isterminal,
        iseval,
        return_type,
        contains_returntype,
        nchildren,
        child_types,
        get_childtypes,
        nonterminals,
        get_executable,
        sample,
        root_node_loc,
        count_expressions,
        mindepth_map,
        mindepth,

        SymbolTable,
        interpret,

        NodeRecycler,
        recycle!



end # module
