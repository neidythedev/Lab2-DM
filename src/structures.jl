module Structures

export ItemsetOptimized, ItemsetBasic


# Bản tối ưu (BitArray)
struct ItemsetOptimized
    items::Vector{Int}
    tidset::BitArray
    support::Int

    # Constructor 1: Nhận 2 tham số, tự tính support (Dùng cho bước khởi đầu)
    ItemsetOptimized(items::Vector{Int}, tidset::BitArray) = new(items, tidset, sum(tidset))

    # Constructor 2: Nhận 3 tham số (Dùng trong đệ quy để không phải sum lại, tăng tốc độ)
    ItemsetOptimized(items::Vector{Int}, tidset::BitArray, sup::Int) = new(items, tidset, sup)
end

# Bản cơ bản (Set)
struct ItemsetBasic
    items::Vector{Int}
    tidset::Set{Int}
    support::Int
    # Constructor cơ bản
    ItemsetBasic(items, tidset) = new(items, tidset, length(tidset))
end

end