using Pkg; Pkg.activate(".")
using Plots, CSV, DataFrames, StatsPlots

# Đảm bảo thư mục charts tồn tại
!isdir("charts") && mkdir("charts")

println("--- Đang xử lý dữ liệu và vẽ biểu đồ thực nghiệm... ---")

# 1. DỮ LIỆU SPMF (Lấy từ hình ảnh Excel bạn cung cấp - Đơn vị: ms)
spmf_data = Dict(
    "Chess" => [100, 216, 433, 1047, 1900],
    "Mushroom" => [95, 81, 122, 153, 218],
    "Accident" => [2313, 2650, 4033, 6197, 9625],
    "Retail" => [638, 598, 770, 1027, 1036]
)

# 2. ĐỌC DỮ LIỆU JULIA CỦA NHÓM
df = CSV.read("results_experiment.csv", DataFrame)

# --- THÍ NGHIỆM 4.B: SO SÁNH NHÓM VS SPMF ---
for dataset in ["Chess", "Mushroom", "Accident", "Retail"]
    sub_df = df[df.Dataset .== dataset, :]
    minsups = sub_df.Minsup
    julia_opt_ms = sub_df.Opt_Time_s .* 1000 # Đổi sang ms

    p = plot(minsups, [spmf_data[dataset], julia_opt_ms],
        label=["Thư viện SPMF" "Nhóm (Optimized)"],
        title="Runtime Comparison: $dataset",
        xlabel="Minsup (Absolute)", ylabel="Time (ms)",
        marker=[:circle :square], linewidth=2,
        yaxis=:log10, legend=:bottomleft)
    
    savefig("charts/compare_spmf_$dataset.png")
end

# --- THÍ NGHIỆM 4.C: SỐ LƯỢNG FI (OUTPUT SIZE) ---
# Lấy dữ liệu 2 tập đại diện
chess_df = df[df.Dataset .== "Chess", :]
retail_df = df[df.Dataset .== "Retail", :]

# Vẽ biểu đồ cho tập Dày (Chess)
p_dense = plot(chess_df.Minsup, chess_df.FI_Count,
    label="Chess (Dày)", title="FI Count: Dense Data",
    xlabel="Minsup", ylabel="Number of FIs",
    marker=:circle, color=:blue, linewidth=2, yaxis=:log10)
savefig("charts/fi_count_dense.png")

# Vẽ biểu đồ cho tập Thưa (Retail)
p_sparse = plot(retail_df.Minsup, retail_df.FI_Count,
    label="Retail (Thưa)", title="FI Count: Sparse Data",
    xlabel="Minsup", ylabel="Number of FIs",
    marker=:square, color=:green, linewidth=2, yaxis=:log10)
savefig("charts/fi_count_sparse.png")

# --- THÍ NGHIỆM 4.D: SO SÁNH BỘ NHỚ (MEMORY USAGE) ---
println("--- Đang vẽ biểu đồ so sánh bộ nhớ... ---")

# Lấy dữ liệu tại minsup trung bình của mỗi tập (dòng thứ 3 trong mỗi nhóm của file CSV)
# Bạn có thể điều chỉnh lọc thủ công nếu muốn chính xác mốc trung bình
target_minsups = [
    ("Chess", 2557),
    ("Mushroom", 3367),
    ("Accident", 272147),
    ("Retail", 177)
]

labels = String[]
basic_rams = Float64[]
opt_rams = Float64[]

for (d_name, m_val) in target_minsups
    row = df[(df.Dataset .== d_name) .& (df.Minsup .== m_val), :]
    if !isempty(row)
        push!(labels, d_name)
        push!(basic_rams, row.Basic_RAM_MB[1])
        push!(opt_rams, row.Opt_RAM_MB[1])
    end
end

# Vẽ biểu đồ cột so sánh RAM
p_mem = groupedbar(labels, [basic_rams opt_rams],
    label=["Basic (Set)" "Optimized (BitArray)"],
    title="Peak Memory Usage Comparison",
    ylabel="Memory (MB)",
    xlabel="Datasets at Average Minsup",
    color=[:gray :orange],
    yaxis=:log10, # CỰC KỲ QUAN TRỌNG: Dùng thang log vì RAM lệch nhau hàng nghìn lần
    legend=:topleft,
    background_color_legend = RGBA(1,1,1,0.6))

savefig("charts/memory_comparison_bar.png")

# --- THÍ NGHIỆM 4.E: SCALABILITY ---
if isfile("results_scalability.csv")
    df_scal = CSV.read("results_scalability.csv", DataFrame)
    p_scal = plot(df_scal.Percentage .* 100, df_scal.Time_s,
        label="Optimized Eclat (Julia)",
        title="Scalability Analysis (Accident)",
        xlabel="Data Size (%)", ylabel="Time (s)",
        marker=:square, color=:red, linewidth=2, legend=:topleft)
    savefig("charts/chart_scalability.png")
end

# --- THÍ NGHIỆM 4.F: ẢNH HƯỞNG ĐỘ DÀI GIAO DỊCH ---
if isfile("results_length.csv")
    df_len = CSV.read("results_length.csv", DataFrame)
    p_len = plot(df_len.Length, df_len.Time_s,
        label="Eclat Runtime", title="Impact of Transaction Length",
        xlabel="Average Transaction Length", ylabel="Time (s)",
        marker=:diamond, color=:blue, linewidth=2, legend=:topleft, yaxis=:log10)
    savefig("charts/chart_length_impact.png")
end

println("✅ HOÀN TẤT: Toàn bộ biểu đồ đã được lưu trong thư mục charts/")
