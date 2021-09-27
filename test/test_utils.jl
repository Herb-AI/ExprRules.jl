@testset "Utils - containedIn" begin
	@test containedin([5], [5])
	@test containedin([1,2,3], [1,2,3])
	@test containedin([1,2,3], [1,5,2,5,3,5])
end