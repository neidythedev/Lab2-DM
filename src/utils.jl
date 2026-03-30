module Utils

using ..Structures
export read_spmf, write_results

function read_spmf(file_path::String)
    transactions = []
    unique_items = Set{Int}()
    open(file_path, "r") do f
        for line in eachline(f)
            isempty(strip(line)) && continue
            items = parse.(Int, split(line))
            push!(transactions, items)
            union!(unique_items, items)
        end
    end
    n_trans = length(transactions)
    sorted_items = sort(collect(unique_items))
    item_tidsets = Dict(item => BitArray(zeros(n_trans)) for item in sorted_items)
    for (tid, items) in enumerate(transactions)
        for item in items
            item_tidsets[item][tid] = 1
        end
    end
    return item_tidsets, n_trans
end

function get_basic_data(item_tidsets_bitarray)
    basic_data = Dict{Int,Set{Int}}()
    for (item, bitarray) in item_tidsets_bitarray
        basic_data[item] = Set(findall(bitarray))
    end
    return basic_data
end

function write_results(results, out_path::String)
    open(out_path, "w") do f
        for res in results
            line = join(res.items, " ") * " #SUP: $(res.support)"
            println(f, line)
        end
    end
end

end