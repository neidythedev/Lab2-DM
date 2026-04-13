using Pkg; Pkg.activate(".")
include("../src/structures.jl")
include("../src/utils.jl")
include("../src/algorithm/eclat_optimized.jl")

using .Structures, .Utils, .EclatOptimized
using Printf

# Hàm chuẩn hóa kết quả từ file (giống logic bạn của bạn)
function get_canonical_dict(path)
    results = Dict{Set{Int}, Int}()
    !isfile(path) && return results
    for line in readlines(path)
        line = strip(line)
        isempty(line) && continue
        parts = split(line, "#SUP:")
        length(parts) < 2 && continue
        items = Set(parse.(Int, split(strip(parts[1]))))
        support = parse(Int, strip(parts[2]))
        results[items] = support
    end
    return results
end

function run_all_correctness_tests()
    # Cấu hình đối chiếu: Tên tập, Đường dẫn data, List (Minsup tuyệt đối, Tên file SPMF tương ứng)
    # Dựa trên đúng bảng Excel và cấu trúc thư mục của bạn
    test_suite = [
        ("Chess", "data/benchmark/chess.txt", [
            (2877, "chess/chess_0.9.txt"), (2717, "chess/chess_0.85.txt"), 
            (2557, "chess/chess_0.8.txt"), (2397, "chess/chess_0.75.txt"), (2238, "chess/chess_0.7.txt")]),
        
        ("Mushroom", "data/benchmark/mushroom.txt", [
            (4208, "mushroom/mushroom_0.5.txt"), (3788, "mushroom/mushroom_0.45.txt"), 
            (3367, "mushroom/mushroom_0.4.txt"), (2946, "mushroom/mushroom_0.35.txt"), (2525, "mushroom/mushroom_0.3.txt")]),
            
        ("Accident", "data/benchmark/accident.txt", [
            (306165, "accident/accident_0.9.txt"), (289156, "accident/accident_0.85.txt"), 
            (272147, "accident/accident_0.8.txt"), (255138, "accident/accident_0.75.txt"), (238129, "accident/accident_0.7.txt")]),
            
        ("Retail", "data/benchmark/retail.txt", [
            (882, "retail/retail_0.01.txt"), (441, "retail/retail_0.005.txt"), 
            (177, "retail/retail_0.002.txt"), (89, "retail/retail_0.001.txt"), (45, "retail/retail_0.0005.txt")])
    ]

    println("="^90)
    @printf("%-12s | %-10s | %-12s | %-12s | %-10s\n", "Dataset", "Minsup", "FI (Nhóm)", "FI (SPMF)", "Trạng thái")
    println("-"^90)

    for (name, data_p, cases) in test_suite
        if !isfile(data_p)
            println("Bỏ qua $name: Không thấy file data.")
            continue
        end
        
        # Đọc data 1 lần cho mỗi dataset
        item_tidsets, _ = read_spmf(data_p)

        for (ms, spmf_file) in cases
            spmf_path = joinpath("data", "spmf_results", spmf_file)
            
            # 1. Chạy Eclat Julia
            P = [ItemsetOptimized([item], item_tidsets[item]) for item in sort(collect(keys(item_tidsets)))]
            filter!(x -> x.support >= ms, P)
            our_res_raw = Vector{ItemsetOptimized}()
            run_eclat_optimized(P, ms, our_res_raw)
            our_results = Dict(Set(res.items) => res.support for res in our_res_raw)

            # 2. Đọc SPMF chuẩn
            spmf_results = get_canonical_dict(spmf_path)

            # 3. So sánh
            status = (our_results == spmf_results) ? "✅ Khớp 100%" : "❌ Sai lệch"
            
            @printf("%-12s | %-10d | %-12d | %-12d | %-10s\n", 
                    name, ms, length(our_results), length(spmf_results), status)
        end
        println("-"^90)
    end
end

run_all_correctness_tests()