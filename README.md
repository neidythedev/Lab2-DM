# Đồ án 2: Khai thác tập phổ biến - Thuật toán Eclat

Dự án này thực hiện cài đặt và đánh giá thuật toán **Eclat (Equivalence CLASS Transformation)** bằng ngôn ngữ lập trình Julia. Đây là một phần của môn học **Khai thác dữ liệu và ứng dụng**.

## 1. Giới thiệu
Thuật toán Eclat sử dụng cách tiếp cận duyệt theo chiều sâu (DFS) trên mô hình dữ liệu dọc (Vertical Data Layout) để tìm kiếm các tập mục phổ biến. Phiên bản này được tối ưu hóa bằng cấu trúc `BitArray` giúp tăng tốc phép giao tập hợp (Intersection) ở mức CPU.

## 2. Yêu cầu hệ thống
*   **Ngôn ngữ:** Julia ≥ 1.9 (Khuyến nghị bản 1.10 hoặc 1.12 LTS).
*   **Thư viện hỗ trợ:** 
    *   `CSV.jl`, `DataFrames.jl`: Xử lý dữ liệu và kết quả.
    *   `Plots.jl`, `StatsPlots.jl`: Vẽ biểu đồ thực nghiệm.
    *   `BenchmarkTools.jl`: Đo lường hiệu năng chuyên sâu.

## 3. Cài đặt môi trường
Để đảm bảo tính tái lập và tránh xung đột thư viện, nhóm sử dụng môi trường riêng của dự án thông qua file `Project.toml`.

1.  Mở Terminal tại thư mục gốc của đồ án (`LAB2-DM/`).
2.  Khởi động Julia với môi trường hiện tại:
    ```bash
    julia --project=.
    ```
3.  Cài đặt các dependency cần thiết (chỉ cần thực hiện lần đầu):
    ```julia
    using Pkg; Pkg.instantiate()
    ```

## 4. Cấu trúc thư mục
```text
LAB2-DM/
├── application/           # Ứng dụng Phân tích giỏ hàng (Chương 5)
├── charts/                # Các biểu đồ kết quả sau khi chạy script vẽ
├── data/                  # Dữ liệu thực nghiệm (Toy, Benchmark, SPMF)
├── docs/                  # Báo cáo PDF 
├── experiment/            # Các script thực hiện thí nghiệm (Chương 4)
├── experiment_results/    # File CSV chứa số liệu thô từ thực nghiệm
├── notebooks/             # Demo trực quan bằng Jupyter Notebook
├── src/                   # Mã nguồn chính của thuật toán
├── test/                  # Script kiểm tra tính đúng đắn và Unit Test
├── README.md              # Hướng dẫn sử dụng
└── Project.toml           # Quản lý môi trường Julia
```

## 5.Hướng dẫn sử dụng và chạy thực nghiệm
Mọi lệnh chạy dưới đây đều thực hiện tại thư mục gốc của dự án.

### 5.1. Kiểm tra tính đúng đắn (Correctness Test)
Để đối chiếu kết quả của nhóm với thư viện tham chiếu quốc tế SPMF:
```bash
julia --project=. test/test_correctness.jl
```

### 5.2. Chạy thực nghiệm hiệu năng (Benchmark)
Đo thời gian chạy, số lượng FI và RAM của bản Basic (Set) vs Optimized (BitArray):
```bash
julia --project=. experiment/run_experiments_b_c_d.jl
```

### 5.3. Thử nghiệm khả năng mở rộng và Độ dài giao dịch
*   **Scalability**: julia --project=. experiment/run_scalability_e_jl.jl
*   **Length Impact**: julia --project=. experiment/run_length_impact_f_jl.jl

### 5.4. Vẽ biểu đồ báo cáo
Sau khi đã chạy các script thực nghiệm và có file CSV trong experiment_results/, chạy lệnh sau để cập nhật biểu đồ:
```bash
julia --project=. experiment/plot_results.jl
```

## 6. Thành viên thực hiện
*   **Lê Quốc Thiện** (23127481)
*   **Phạm Quang Thịnh** (23127485)
