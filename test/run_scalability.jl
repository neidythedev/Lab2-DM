# File: tests/run_scalability.jl
using Pkg; Pkg.activate(".")
include("../src/structures.jl")
include("../src/utils.jl")
include("../src/algorithm/eclat_optimized.jl")

using .Structures, .Utils, .EclatOptimized
using Printf

function build_vertical_layout(transactions_subset, sorted_items)
    n_trans = length(transactions_subset)
    item_tidsets = Dict(item => BitArray(zeros(n_trans)) for item in sorted_items)
    for (tid, items) in enumerate(transactions_subset)
        for item in items
            if haskey(item_tidsets, item)
                item_tidsets[item][tid] = 1
            end
        end
    end
    return item_tidsets
end

# HÀM MỚI: Warm-up tổng lực trước khi đo đạc
function warmup_before_measuring(all_transactions, sorted_items)
    println("--- Đang Warm-up JIT cho Scalability... ---")
    # Lấy 1000 giao dịch đầu tiên làm nháp
    subset = all_transactions[1:min(1000, end)]
    ms_abs = 800 # 80% của 1000
    
    item_tidsets = build_vertical_layout(subset, sorted_items)
    P_opt = [ItemsetOptimized([item], item_tidsets[item]) for item in sorted_items]
    filter!(x -> x.support >= ms_abs, P_opt)
    
    # Chạy thực sự để Julia biên dịch mã máy
    run_eclat_optimized(P_opt, ms_abs, Vector{ItemsetOptimized}())
    println("--- Warm-up hoàn tất. ---")
end

function run_scalability()
    file_path = "data/benchmark/accident.txt"
    relative_minsup = 0.8 

    if !isfile(file_path)
        println("Lỗi: Không tìm thấy file accident.txt")
        return
    end

    println("--- Đang đọc dữ liệu Accidents... ---")
    all_transactions = []
    unique_items = Set{Int}()
    open(file_path, "r") do f
        for line in eachline(f)
            isempty(strip(line)) && continue
            items = parse.(Int, split(line))
            push!(all_transactions, items)
            union!(unique_items, items)
        end
    end
    sorted_items = sort(collect(unique_items))
    total_n = length(all_transactions)

    # THỰC HIỆN WARM-UP TRƯỚC VÒNG LẶP
    warmup_before_measuring(all_transactions, sorted_items)

    percentages = [0.10, 0.25, 0.50, 0.75, 1.00]
    csv_path = "results_scalability.csv"
    f_csv = open(csv_path, "w")
    println(f_csv, "Percentage,Num_Transactions,Time_s")

    println("="^70)
    @printf("%-12s | %-15s | %-12s | %-12s\n", "Tỷ lệ (%)", "Số giao dịch", "Minsup Abs", "Thời gian (s)")
    println("-"^70)

    for p in percentages
        num_to_take = round(Int, p * total_n)
        subset = all_transactions[1:num_to_take]
        ms_absolute = round(Int, relative_minsup * num_to_take)

        item_tidsets = build_vertical_layout(subset, sorted_items)
        P_opt = [ItemsetOptimized([item], item_tidsets[item]) for item in sorted_items]
        filter!(x -> x.support >= ms_absolute, P_opt)

        # Đo đạc thời gian thật
        F_opt = Vector{ItemsetOptimized}()
        
        GC.gc() # Dọn rác trước mỗi mốc để đảm bảo công bằng
        stats = @timed run_eclat_optimized(P_opt, ms_absolute, F_opt)

        @printf("%-12.0f%% | %-15d | %-12d | %-12.4f\n", p*100, num_to_take, ms_absolute, stats.time)
        println(f_csv, "$p,$num_to_take,$(stats.time)")
    end
    
    close(f_csv)
    println("-"^70)
    println("✅ HOÀN TẤT. Kết quả lưu tại: results_scalability.csv")
end

run_scalability()