@testset "ComesAfter" begin
	
	grammar = @csgrammar begin
		Real = 1 | 2 | 3
		Real = Real + Real
		Real = Real * Real
	end

	iter = ContextSensitiveIterator(grammar, 2, :Real)
	elems = collect(iter)

	constraint = ComesAfter(3,5)
	addconstraint!(grammar, constraint)

	iter2 = ContextSensitiveIterator(grammar, 2, :Real)
	elems2 = collect(iter2)

	@test length(elems) > length(elems2)
	@test length(elems) == 21
	@test length(elems2) == 15
end

@testset "Ordered rules" begin
	grammar = @csgrammar begin
		Real = 1 | 2 | 3
		Real = Real + Real
		Real = Real * Real
	end
	
	iter = ContextSensitiveIterator(grammar, 2, :Real)
	elems = collect(iter)

	constraint = Ordered([1,2,3])
	addconstraint!(grammar, constraint)

	iter2 = ContextSensitiveIterator(grammar, 2, :Real)
	elems2 = collect(iter2)

	@test length(elems) > length(elems2)
	@test length(elems) == 21
	@test length(elems2) == 5
end


@testset "Forbidden derivation" begin
	grammar = @csgrammar begin
		Real = 1 | 2 | 3
		Real = Real + Real
		Real = Real * Real
	end
	
	iter = ContextSensitiveIterator(grammar, 2, :Real)
	elems = collect(iter)
	
	c = Forbidden([4,2])
	addconstraint!(grammar, c)
	
	iter2 = ContextSensitiveIterator(grammar, 2, :Real)
	elems2 = collect(iter2)

	@test length(elems2) < length(elems)
	@test length(elems) == 21
	@test length(elems2) == 16
end