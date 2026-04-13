# File: tests/run_experiments.jl
using Pkg; Pkg.activate(".")
include("../src/structures.jl")
include("../src/utils.jl")
include("../src/algorithm/eclat_optimized.jl")
include("../src/algorithm/eclat_basic.jl")

using .Structures, .Utils, .EclatOptimized, .EclatBasic
using Printf

function start_experiment()
    # GIỮ NGUYÊN các mốc số liệu của bạn
    experiments = [
        ("Chess", "data/benchmark/chess.txt", [2877, 2717, 2557, 2397, 2238]),
        ("Mushroom", "data/benchmark/mushroom.txt", [4208, 3788, 3367, 2946, 2525]),
        ("Accident", "data/benchmark/accident.txt", [306165, 289156, 272147, 255138, 238129]),
        ("Retail", "data/benchmark/retail.txt", [882, 441, 177, 89, 45])
    ]

    csv_path = "results_experiment.csv"
    f_csv = open(csv_path, "w")
    header = "Dataset,Minsup,FI_Count,Basic_Time_s,Opt_Time_s,Speedup,Basic_RAM_MB,Opt_RAM_MB,Memory_Saving_Ratio"
    println(f_csv, header)
    
    println("="^125)
    @printf("%-10s | %-8s | %-8s | %-10s | %-10s | %-8s | %-10s | %-10s\n", 
            "Dataset", "Minsup", "FI", "T_Basic", "T_Opt", "Speedup", "RAM_Basic", "RAM_Opt")
    println("-"^125)

    for (name, path, minsups) in experiments
        if !isfile(path)
            println("Bỏ qua $name: Không tìm thấy file.")
            continue
        end

        # Đọc dữ liệu
        item_tidsets, _ = read_spmf(path)
        
        # --- BƯỚC SỬA LỖI: WARM-UP THỰC TẾ CHO TỪNG TẬP DỮ LIỆU ---
        # Chạy thử mức minsup cao nhất của tập đó nhưng KHÔNG ghi lại kết quả
        # Việc này ép Julia biên dịch mã máy cho kích thước BitArray và Set của tập này
        println("--- Warm-up cho $name... ---")
        warm_ms = minsups[1]
        
        # Nháp Optimized
        P_w_opt = [ItemsetOptimized([item], item_tidsets[item]) for item in sort(collect(keys(item_tidsets)))]
        filter!(x -> x.support >= warm_ms, P_w_opt)
        run_eclat_optimized(P_w_opt, warm_ms, Vector{ItemsetOptimized}())
        
        # Nháp Basic
        P_w_basic = [ItemsetBasic([item], Set(findall(item_tidsets[item]))) for item in sort(collect(keys(item_tidsets)))]
        filter!(x -> x.support >= warm_ms, P_w_basic)
        run_eclat_basic(P_w_basic, warm_ms, Vector{ItemsetBasic}())
        # -------------------------------------------------------

        for ms in minsups
            # Chuẩn bị dữ liệu đo thật
            P_opt = [ItemsetOptimized([item], item_tidsets[item]) for item in sort(collect(keys(item_tidsets)))]
            filter!(x -> x.support >= ms, P_opt)
            
            P_basic = [ItemsetBasic([item], Set(findall(item_tidsets[item]))) for item in sort(collect(keys(item_tidsets)))]
            filter!(x -> x.support >= ms, P_basic)

            # 1. Đo bản Optimized
            F_opt = Vector{ItemsetOptimized}()
            GC.gc() # Dọn rác để con số RAM chính xác
            stats_opt = @timed run_eclat_optimized(P_opt, ms, F_opt)

            # 2. Đo bản Basic
            F_basic = Vector{ItemsetBasic}()
            GC.gc()
            stats_basic = @timed run_eclat_basic(P_basic, ms, F_basic)

            # 3. Xuất kết quả
            t_basic, t_opt = stats_basic.time, stats_opt.time
            ram_basic, ram_opt = stats_basic.bytes/1024^2, stats_opt.bytes/1024^2
            speedup = t_opt > 0 ? t_basic/t_opt : 0.0
            mem_ratio = ram_opt > 0 ? ram_basic/ram_opt : 0.0
            
            @printf("%-10s | %-8d | %-8d | %-10.4f | %-10.4f | %-8.2fx | %-10.2f | %-10.2f\n", 
                    name, ms, length(F_opt), t_basic, t_opt, speedup, ram_basic, ram_opt)
            
            println(f_csv, "$name,$ms,$(length(F_opt)),$t_basic,$t_opt,$speedup,$ram_basic,$ram_opt,$mem_ratio")
        end
        println("-"^125)
    end
    close(f_csv)
    println("✅ THỰC NGHIỆM HOÀN TẤT. File kết quả: results_experiment.csv")
end

start_experiment()