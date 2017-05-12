using MyInterpolations
using Base.Test

const _lin_interp = my_lin_interp

@testset "Testing linear interporation" begin
    @testset "case with two grid points" begin
        grid = [1, 2]
        vals = [2, 0]
        itp = _lin_interp(grid, vals)

        @testset "scalar input" begin
            x, y = 1.25, 1.5
            @test isapprox(itp(x), y)
        end

        @testset "end points" begin
            for (x, y) in [(grid[1], grid[end]), (vals[1], vals[end])]
                @test itp(x) == y
            end
        end

        @testset "array inputs" begin
            xys = [
                ([4/3, 1.8], [4/3, 0.4]),
                (linspace(1, 2, 5), [2.0 - 0.5*i for i in 0:4])
            ]
            for (x, y) in xys
                @test isapprox(itp.(x), y)
            end
        end
    end
end
