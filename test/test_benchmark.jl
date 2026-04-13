using Pkg;
Pkg.activate(".");
include("../src/structures.jl")
include("../src/utils.jl")
include("../src/algorithm/eclat_optimized.jl")
include("../src/algorithm/eclat_basic.jl")

using .Structures, .Utils, .EclatOptimized, .EclatBasic

function run_benchmark(file_path, min_sup)
    println("--- Đang đọc dữ liệu: $file_path ---")
    item_tidsets, _ = read_spmf(file_path)

    # Chuẩn bị dữ liệu Tối ưu
    P_opt = [ItemsetOptimized([item], item_tidsets[item]) for item in sort(collect(keys(item_tidsets)))]
    filter!(x -> x.support >= min_sup, P_opt)

    # Chuẩn bị dữ liệu Cơ bản
    P_basic = [ItemsetBasic([item], Set(findall(item_tidsets[item]))) for item in sort(collect(keys(item_tidsets)))]
    filter!(x -> x.support >= min_sup, P_basic)

    # Warm-up Julia JIT
    run_eclat_optimized(P_opt[1:min(2, end)], min_sup, Vector{ItemsetOptimized}())

    println("--- Đang đo bản Tối ưu (BitArray) ---")
    F_opt = Vector{ItemsetOptimized}()
    stats_opt = @timed run_eclat_optimized(P_opt, min_sup, F_opt)

    println("--- Đang đo bản Cơ bản (Set) ---")
    F_basic = Vector{ItemsetBasic}()
    stats_basic = @timed run_eclat_basic(P_basic, min_sup, F_basic)

    println("\n" * "="^40)
    println("       KẾT QUẢ SO SÁNH HIỆU NĂNG")
    println("="^40)

    println("1. Bản Cơ bản (Dùng Set):")
    println("   - Thời gian: $(round(stats_basic.time, digits=4)) giây")
    println("   - Bộ nhớ:    $(round(stats_basic.bytes/1024^2, digits=2)) MB")
    println("   - Số tập phổ biến (FI): $(length(F_basic))") # <-- THÊM DÒNG NÀY

    println("\n2. Bản Tối ưu (Dung BitArray):")
    println("   - Thời gian: $(round(stats_opt.time, digits=4)) giây")
    println("   - Bộ nhớ:    $(round(stats_opt.bytes/1024^2, digits=2)) MB")
    println("   - Số tập phổ biến (FI): $(length(F_opt))")   # <-- THÊM DÒNG NÀY

    println("-"^40)

    # Kiểm tra khớp kết quả
    if length(F_basic) == length(F_opt)
        println("✅ KIỂM TRA: Khớp 100% ($(length(F_opt)) tập)")
    else
        println("❌ CẢNH BÁO: Số lượng tập không khớp!")
    end

    println("=> Tối ưu nhanh gấp: $(round(stats_basic.time/stats_opt.time, digits=2)) lần.")
    println("="^40)
end

if length(ARGS) >= 2
    run_benchmark(ARGS[1], parse(Int, ARGS[2]))
else
    println("Sử dụng: julia --project=. tests/test_benchmark.jl <file> <minsup>")
end