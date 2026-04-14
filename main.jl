
using Pkg
Pkg.activate(".")

# Nạp các thành phần mã nguồn
include("src/structures.jl")
include("src/utils.jl")
include("src/algorithm/eclat_optimized.jl")
include("src/algorithm/eclat_basic.jl")

using .Structures
using .Utils
using .EclatOptimized
using .EclatBasic

function main()
    # Cấu trúc lệnh: julia main.jl <input> <minsup> <output> <mode>
    if length(ARGS) < 2
        println("❌ Lỗi: Thiếu tham số!")
        println("Sử dụng: julia --project=. main.jl <input> <minsup> [output] [mode]")
        println("  - mode: 'opt' (mặc định) hoặc 'basic'")
        return
    end

    # 1. Lấy tham số từ dòng lệnh
    input_path = ARGS[1]
    min_sup = parse(Int, ARGS[2])
    output_path = length(ARGS) >= 3 ? ARGS[3] : "output.txt"
    mode = length(ARGS) >= 4 ? ARGS[4] : "opt"

    println("--- [ECLAT RUNNER] ---")
    println("📂 Dữ liệu: $input_path")
    println("⚙️  Minsup: $min_sup")
    println("🛠️  Thuật toán: ", mode == "opt" ? "TỐI ƯU (BitArray)" : "CƠ BẢN (Set)")

    # 2. Đọc dữ liệu (Hàm này trả về BitArray Dict)
    item_tidsets, n_trans = Utils.read_spmf(input_path)

    if mode == "basic"
        # --- CHẠY BẢN CƠ BẢN ---
        # Chuyển đổi dữ liệu BitArray sang Set cho bản Basic
        P_basic = [ItemsetBasic([item], Set(findall(item_tidsets[item])))
                   for item in sort(collect(keys(item_tidsets)))]
        filter!(x -> x.support >= min_sup, P_basic)

        results = Vector{ItemsetBasic}()
        @time EclatBasic.run_eclat_basic(P_basic, min_sup, results)

        # Sắp xếp và ghi file
        sort!(results, by=x -> (length(x.items), x.items))
        Utils.write_results(results, output_path)
    else
        # --- CHẠY BẢN TỐI ƯU ---
        P_opt = [ItemsetOptimized([item], item_tidsets[item])
                 for item in sort(collect(keys(item_tidsets)))]
        filter!(x -> x.support >= min_sup, P_opt)

        results = Vector{ItemsetOptimized}()
        @time EclatOptimized.run_eclat_optimized(P_opt, min_sup, results)

        # Sắp xếp và ghi file
        sort!(results, by=x -> (length(x.items), x.items))
        Utils.write_results(results, output_path)
    end

    println("✅ Xong! Tìm thấy $(length(results)) tập phổ biến.")
    println("📁 Kết quả lưu tại: $output_path")
end

main()