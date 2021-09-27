abstract type Constraint end
abstract type ValidatorConstraint <: Constraint end
abstract type PropagatorConstraint <: Constraint end

"""
	Derivation rule can only appear in a derivation tree if the predecessors are in the path to the current node (in order)
"""
struct ComesAfter <: PropagatorConstraint
	rule::Int 
	predecessors::Vector{Int}
end

ComesAfter(rule::Int, predecessor::Int) = ComesAfter(rule, [predecessor])




"""
	Rules have to be used in the specified order.
	That is, rule at index K can only be used if rules at indices [1...K-1] are used in the left subtree of the current exrepssion
"""
struct Ordered <: PropagatorConstraint
	order::Vector{Int}
end