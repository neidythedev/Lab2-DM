module EclatBasic
using ..Structures
export run_eclat_basic

function run_eclat_basic(P::Vector{ItemsetBasic}, min_sup::Int, F::Vector{ItemsetBasic})
    for i in 1:length(P)
        push!(F, P[i])
        P_new = Vector{ItemsetBasic}()
        for j in (i+1):length(P)
            new_tidset = intersect(P[i].tidset, P[j].tidset)
            new_sup = length(new_tidset)
            if new_sup >= min_sup
                push!(P_new, ItemsetBasic(vcat(P[i].items, P[j].items[end]), new_tidset))
            end
        end
        !isempty(P_new) && run_eclat_basic(P_new, min_sup, F)
    end
end
end