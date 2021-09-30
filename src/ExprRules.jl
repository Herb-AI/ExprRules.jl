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
include("rulenode_operators.jl")

include("cfg.jl")

include("csgrammar/context.jl")
include("csgrammar/constraints.jl")
include("csgrammar/propagators.jl")
include("csgrammar/csg.jl")
include("csgrammar/iterators.jl")
include("csgrammar/sampling.jl")




export
        Grammar,
        ContextFreeGrammar,
        RuleNode,
        NodeLoc,

        ExpressionIterator,
        ContextFreeIterator,

        @cfgrammar,
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

        containedin,
        subsequenceof,
        accumulate_if!,

        change_expr,
	swap_node,
	get_rulesequence,
	rulesoftype,
	rulesonleft,

        NodeRecycler,
        recycle!,

        GrammarContext,
	addparent!,
        copy_and_insert,

        Constraint,
        ValidatorConstraint,
        PropagatorConstraint,
        ComesAfter,
        Ordered,
        Forbidden,

        propagate,
        propagate_index,

        ContextSensitiveGrammar,
        @csgrammar,
        addconstraint!,

        ContextSensitiveIterator,
        propagate_contraints





end # module
