# File: tests/run_experiments.jl
using Pkg; Pkg.activate(".")
include("../src/structures.jl")
include("../src/utils.jl")
include("../src/algorithm/eclat_optimized.jl")
include("../src/algorithm/eclat_basic.jl")

using .Structures, .Utils, .EclatOptimized, .EclatBasic
using Printf

function start_experiment()
    # Cấu hình tất cả các mốc thí nghiệm (Dataset Name, Path, Minsup tuyệt đối)
    # Lưu ý: Các con số minsup này dựa trên các tỷ lệ 90%, 80%, 70%... mà chúng ta đã thảo luận
    experiments = [
        ("Chess", "data/benchmark/chess.txt", [2877, 2557, 2238, 1918, 1598]),
        ("Mushroom", "data/benchmark/mushroom.txt", [4208, 3367, 2525, 1684, 842]),
        ("Retail", "data/benchmark/retail.txt", [881, 440, 176, 88, 44]),
        ("Accidents", "data/benchmark/accident.txt", [306165, 272146, 238128, 204110, 170092])
    ]

    println("="^110)
    @printf("%-12s | %-8s | %-10s | %-10s | %-10s | %-10s | %-10s\n", 
            "Dataset", "Minsup", "FI Count", "Basic(s)", "Opt(s)", "Speedup", "RAM Opt(MB)")
    println("-"^110)

    for (name, path, minsups) in experiments
        # SỬA LỖI TẠI ĐÂY: Dùng isfile trực tiếp
        if !isfile(path)
            println("Bỏ qua $name: Không tìm thấy file tại $path")
            continue
        end

        # Đọc dữ liệu ban đầu
        item_tidsets, n_trans = read_spmf(path)
        
        for ms in minsups
            # 1. Chuẩn bị dữ liệu cho Julia
            # Bản Optimized dùng BitArray
            P_opt = [ItemsetOptimized([item], item_tidsets[item]) for item in sort(collect(keys(item_tidsets)))]
            filter!(x -> x.support >= ms, P_opt)
            
            # Bản Basic dùng Set (phải convert từ BitArray sang Set)
            P_basic = [ItemsetBasic([item], Set(findall(item_tidsets[item]))) for item in sort(collect(keys(item_tidsets)))]
            filter!(x -> x.support >= ms, P_basic)

            # 2. Chạy và đo bản Optimized (BitArray)
            F_opt = Vector{ItemsetOptimized}()
            # Warm-up (để Julia JIT compile code trước khi đo thực tế)
            if !isempty(P_opt)
                run_eclat_optimized(P_opt[1:min(1, end)], ms, Vector{ItemsetOptimized}())
            end
            
            # Đo đạc thời gian và bộ nhớ bằng @timed
            stats_opt = @timed run_eclat_optimized(P_opt, ms, F_opt)

            # 3. Chạy và đo bản Basic (Set)
            F_basic = Vector{ItemsetBasic}()
            stats_basic = @timed run_eclat_basic(P_basic, ms, F_basic)

            # 4. Tính toán kết quả
            speed_ratio = stats_basic.time / stats_opt.time
            ram_mb = stats_opt.bytes / 1024^2
            
            @printf("%-12s | %-8d | %-10d | %-10.4f | %-10.4f | %-10.2fx | %-10.2f\n", 
                    name, ms, length(F_opt), stats_basic.time, stats_opt.time, speed_ratio, ram_mb)
        end
        println("-"^110)
    end
    println("HOÀN THÀNH TẤT CẢ THÍ NGHIỆM.")
end

start_experiment()