using Pkg; Pkg.activate(".")
include("../src/structures.jl")
include("../src/utils.jl")
include("../src/algorithm/eclat_optimized.jl")

using .Structures, .Utils, .EclatOptimized
using Printf, CSV, DataFrames

# Hàm sinh luật kết hợp
function generate_rules(frequent_itemsets, min_conf, n_trans)
    set_to_sup = Dict(Set(res.items) => res.support for res in frequent_itemsets)
    rules = []
    for itemset_obj in frequent_itemsets
        items = itemset_obj.items
        if length(items) < 2 continue end
        for i in 1:length(items)
            consequent = [items[i]]
            antecedent = filter(x -> x != items[i], items)
            sup_xy = itemset_obj.support
            sup_x = get(set_to_sup, Set(antecedent), 0)
            sup_y = get(set_to_sup, Set(consequent), 0)
            if sup_x > 0
                conf = sup_xy / sup_x
                if conf >= min_conf
                    lift = (sup_xy / n_trans) / ((sup_x / n_trans) * (sup_y / n_trans))
                    # Chuyển Antecedent thành chuỗi cách nhau bởi dấu cách để Excel không bị lỗi
                    ant_str = join(antecedent, " ")
                    con_str = join(consequent, " ")
                    push!(rules, (Antecedent=ant_str, Consequent=con_str, Support=sup_xy, Conf=conf, Lift=lift))
                end
            end
        end
    end
    return rules
end

function run_mba()
    file_path = "data/benchmark/retail.txt"
    output_csv = "application/application_results.csv"
    min_sup_abs = 500
    min_conf = 0.4
    
    println("--- Ứng dụng Phân tích giỏ hàng trên tập Retail ---")
    item_tidsets, n_trans = read_spmf(file_path)
    
    # 1. Chạy Eclat
    P = [ItemsetOptimized([item], item_tidsets[item]) for item in sort(collect(keys(item_tidsets)))]
    filter!(x -> x.support >= min_sup_abs, P)
    F = Vector{ItemsetOptimized}()
    run_eclat_optimized(P, min_sup_abs, F)
    
    # 2. Sinh luật và chuyển sang DataFrame
    rules = generate_rules(F, min_conf, n_trans)
    df_rules = DataFrame(rules)
    
    # 3. Sắp xếp theo Lift giảm dần và lấy Top 10
    sort!(df_rules, :Lift, rev=true)
    top_10 = first(df_rules, 10)
    
    # 4. In ra Terminal để kiểm tra nhanh
    println("="^80)
    println(top_10)
    println("="^80)

    # 5. Xuất ra file CSV
    CSV.write(output_csv, top_10)
    println("\n✅ THÀNH CÔNG: Kết quả đã được lưu vào file: $output_csv")
end

run_mba()