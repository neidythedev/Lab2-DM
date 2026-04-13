using Test
include("../src/structures.jl")
include("../src/utils.jl")
include("../src/algorithm/eclat_optimized.jl")

using .Structures, .Utils, .EclatOptimized

# HÀM QUAN TRỌNG: Sắp xếp cả Item bên trong và các dòng trong file
function get_canonical_results(path)
    if !isfile(path)
        return String[]
    end

    standardized_lines = String[]
    for line in readlines(path)
        line = strip(line)
        isempty(line) && continue

        # Chia dòng thành phần Itemset và phần Support
        parts = split(line, "#SUP:")
        length(parts) < 2 && continue

        # 1. Sắp xếp các con số trong Itemset (ví dụ: "1 16 12" -> "1 12 16")
        items = parse.(Int, split(strip(parts[1])))
        sort!(items)

        # 2. Lấy giá trị support
        support = strip(parts[2])

        # 3. Tạo lại dòng chuẩn để so sánh
        push!(standardized_lines, join(items, " ") * " #SUP: " * support)
    end

    # 4. Sắp xếp toàn bộ các dòng theo thứ tự bảng chữ cái
    return sort(standardized_lines)
end

@testset "Eclat Optimized vs SPMF Reference" begin

    test_cases = [
        ("data/toy/toy_data.txt", 3, "data/spmf/toy_spmf.txt"),
        ("data/benchmark/chess.txt", 2500, "data/spmf/chess_spmf.txt"),
        ("data/benchmark/retail.txt", 997, "data/spmf/retail_spmf.txt"),
        ("data/benchmark/accident.txt", 199994, "data/spmf/accident_spmf.txt")
    ]

    for (input_p, min_sup, spmf_p) in test_cases
        input_path = joinpath(@__DIR__, "..", input_p)
        spmf_path = joinpath(@__DIR__, "..", spmf_p)

        @testset "Dataset: $(basename(input_p))" begin
            if !isfile(input_path) || !isfile(spmf_path)
                @warn "⚠️ Bỏ qua $(basename(input_p)): Thiếu file input hoặc file mẫu."
                continue
            end

            # 1. Chạy thuật toán của bạn
            tidsets, _ = read_spmf(input_path)
            P = [ItemsetOptimized([item], tidsets[item]) for item in sort(collect(keys(tidsets)))]
            filter!(x -> x.support >= min_sup, P)

            my_results = Vector{ItemsetOptimized}()
            run_eclat_optimized(P, min_sup, my_results)

            # 2. Ghi ra file tạm
            temp_out = "temp_test_res.txt"
            write_results(my_results, temp_out)

            # 3. CHUẨN HÓA CẢ HAI FILE TRƯỚC KHI SO SÁNH
            my_lines = get_canonical_results(temp_out)
            spmf_lines = get_canonical_results(spmf_path)

            # 4. Kiểm tra
            @test length(my_lines) == length(spmf_lines)
            @test my_lines == spmf_lines

            if my_lines == spmf_lines
                println("   ✅ $(basename(input_p)): Khớp 100% ($(length(my_lines)) tập).")
            end

            rm(temp_out, force=true)
        end
    end
end