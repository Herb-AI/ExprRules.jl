@testset "Utils - containedIn" begin
	@test containedin([5], [5])
	@test containedin([1,2,3], [1,2,3])
	@test containedin([1,2,3], [1,5,2,5,3,5])
end

@testset "Utils - accumulate_if" begin
	init_coll = Vector{Int}()
	@test length(accumulate_if!(init_coll, 3, x -> x%2==0)) == 0
	@test length(accumulate_if!(init_coll, 2, x -> x%2==0)) == 1

	f_to_use(acc, e) = accumulate_if!(acc, e, x -> x[1]%2==0, x -> x[2])
	result = reduce(f_to_use, enumerate(["a", "b", "c", "d"]); init=Vector())
	@test length(result) == 2
	@test result[1] == "b"


end