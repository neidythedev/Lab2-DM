using Test
include("../src/structures.jl")
include("../src/utils.jl")
include("../src/algorithm/eclat_optimized.jl")
include("../src/algorithm/eclat_basic.jl")

using .Structures, .Utils, .EclatOptimized, .EclatBasic

@testset "Eclat Project Tests" begin

    @testset "Tính đúng đắn (Correctness) - Toy Data" begin
        data_path = "../data/toy/toy_data.txt"
        min_sup = 3
        tidsets, _ = read_spmf(data_path)

        # Test bản Optimized
        P_opt = [Itemset([item], tidsets[item]) for item in sort(collect(keys(tidsets)))]
        filter!(x -> x.support >= min_sup, P_opt)
        res_opt = Vector{Itemset}()
        run_eclat(P_opt, min_sup, res_opt)

        # Kiểm tra số lượng tập phổ biến (Dựa trên ví dụ tay Chương 2)
        @test length(res_opt) == 9
        println("   ✅ Bản Optimized: Khớp 9 tập mục.")

        # Test bản Basic
        P_basic = [ItemsetBasic([item], Set(findall(tidsets[item]))) for item in sort(collect(keys(tidsets)))]
        filter!(x -> x.support >= min_sup, P_basic)
        res_basic = Vector{ItemsetBasic}()
        run_eclat_basic(P_basic, min_sup, res_basic)

        @test length(res_basic) == 9
        println("   ✅ Bản Basic: Khớp 9 tập mục.")
    end

    @testset "So khớp hai phiên bản - Benchmark Data" begin
        # Chạy trên Mushroom để đảm bảo 2 thuật toán cho ra kết quả như nhau
        data_path = "../data/benchmark/mushroom.txt"
        min_sup = 4000 # Dùng min_sup cao để test nhanh
        tidsets, _ = read_spmf(data_path)

        # Optimized
        P_opt = [Itemset([item], tidsets[item]) for item in sort(collect(keys(tidsets)))]
        filter!(x -> x.support >= min_sup, P_opt)
        res_opt = Vector{Itemset}()
        run_eclat(P_opt, min_sup, res_opt)

        # Basic
        P_basic = [ItemsetBasic([item], Set(findall(tidsets[item]))) for item in sort(collect(keys(tidsets)))]
        filter!(x -> x.support >= min_sup, P_basic)
        res_basic = Vector{ItemsetBasic}()
        run_eclat_basic(P_basic, min_sup, res_basic)

        @test length(res_opt) == length(res_basic)
        println("   ✅ Đối chiếu Mushroom: Cả hai bản đều ra $(length(res_opt)) tập.")
    end

end