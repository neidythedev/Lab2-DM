module EclatOptimized

using ..Structures
export run_eclat_optimized

function run_eclat_optimized(P::Vector{ItemsetOptimized}, min_sup::Int, F::Vector{ItemsetOptimized})
    # P là lớp tương đương hiện tại (Equivalence Class)
    for i in 1:length(P)
        # 1. Thêm tập phổ biến hiện tại vào kết quả
        push!(F, P[i])

        # 2. Tạo lớp tương đương mới cho tầng tiếp theo
        P_new = Vector{ItemsetOptimized}()

        for j in (i+1):length(P)
            # Phép giao TID-sets cực nhanh nhờ BitArray
            new_tidset = P[i].tidset .& P[j].tidset
            new_support = sum(new_tidset)

            # ... trong vòng lặp của run_eclat ...
            if new_support >= min_sup
                new_items = vcat(P[i].items, P[j].items[end])
                # Truyền 3 tham số để tối ưu (đã có new_support từ dòng trước)
                push!(P_new, ItemsetOptimized(new_items, new_tidset, new_support))
            end
            # ...
        end

        # 3. Đệ quy theo chiều sâu (DFS)
        if !isempty(P_new)
            run_eclat_optimized(P_new, min_sup, F)
        end
    end
end

end