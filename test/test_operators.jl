@testset "Rules left of" begin
	grammar = @csgrammar begin
		Real = 1 | 2 | 3
		Real = Real + Real
		Real = Real * Real
	end

	iter = ContextSensitiveIterator(grammar, 3, :Real)
	elems = collect(iter)

	focus_node = elems[50]

	path = Vector{Int}([1])
	@test rulesonleft(focus_node, path) == Set([4])

	path = Vector{Int}([2,1])
	@test rulesonleft(focus_node, path) == Set([4,3])

	path = Vector{Int}([2,2])
	@test rulesonleft(focus_node, path) == Set([4,3,1])
	
end