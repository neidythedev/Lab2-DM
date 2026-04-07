# File: tests/run_length_impact.jl
using Pkg; Pkg.activate(".")
include("../src/structures.jl")
include("../src/algorithm/eclat_optimized.jl")

using .Structures, .EclatOptimized
using Printf, Random

function get_data(n, m, l)
    return [sort(Random.shuffle(1:m)[1:l]) for _ in 1:n]
end

function run_length_experiment()
    n_trans = 1000
    n_items = 50
    lengths = [5, 10, 15, 20, 25, 30] 
    minsup_rel = 0.05
    ms_abs = round(Int, minsup_rel * n_trans)

    w_trans = get_data(500, 50, 15)
    w_tidsets = Dict(i => BitArray(zeros(500)) for i in 1:50)
    for (tid, items) in enumerate(w_trans), item in items; w_tidsets[item][tid] = 1; end
    w_P = [ItemsetOptimized([i], w_tidsets[i]) for i in 1:50]
    filter!(x -> x.support >= 25, w_P)
    run_eclat_optimized(w_P, 25, Vector{ItemsetOptimized}())
    println("--- Khởi động xong. Bắt đầu đo đạc chính xác. ---")

    println("="^65)
    @printf("%-12s | %-10s | %-12s | %-12s\n", "Độ dài TB", "Số FI", "RAM (MB)", "Thời gian (s)")
    println("-"^65)

    results = []

    for len in lengths
        # 1. Tạo dữ liệu
        transactions = get_data(n_trans, n_items, len)
        
        # 2. Chuyển dọc
        item_tidsets = Dict(i => BitArray(zeros(n_trans)) for i in 1:n_items)
        for (tid, items) in enumerate(transactions), item in items; item_tidsets[item][tid] = 1; end

        # 3. Chuẩn bị
        P = [ItemsetOptimized([i], item_tidsets[i]) for i in 1:n_items]
        filter!(x -> x.support >= ms_abs, P)

        # 4. Đo đạc
        F = Vector{ItemsetOptimized}()
        GC.gc()
        stats = @timed run_eclat_optimized(P, ms_abs, F)

        @printf("%-12d | %-10d | %-12.2f | %-12.4f\n", len, length(F), stats.bytes/1024^2, stats.time)
        push!(results, (len, stats.time))
    end
    
    open("results_length.csv", "w") do f
        println(f, "Length,Time_s")
        for r in results; println(f, "$(r[1]),$(r[2])"); end
    end
    println("-"^65)
    println("✅ THÀNH CÔNG. Kết quả đã lưu vào: results_length.csv")
end

run_length_experiment()