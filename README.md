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
*   **Java:** Cần thiết để chạy tệp `spmf.jar` phục vụ đối soát kết quả.

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
├── main.jl                 # Trình điều khiển chính, hỗ trợ tham số dòng lệnh (Level 4)
├── spmf.jar                # Công cụ tham chiếu quốc tế để đối soát kết quả
├── src/                    # Mã nguồn cốt lõi của dự án
│   ├── algorithm/          # Hiện thực Eclat bản Basic (Set) và Optimized (BitArray)
│   ├── structures.jl       # Định nghĩa các cấu trúc dữ liệu tùy chỉnh
│   └── utils.jl            # Các hàm tiện ích: đọc/ghi file định dạng SPMF
├── test/                   # Các script kiểm tra tính đúng đắn (Correctness)
│   ├── runtests.jl         # Bộ Unit Test tự động cho toàn dự án
│   ├── test_correctness.jl # Đối chiếu kết quả 1:1 với SPMF trên 20 kịch bản
│   └── test_benchmark.jl   # Script đo lường hiệu năng cơ bản
├── experiment/             # Phân tích thực nghiệm chuyên sâu (Chương 4)
│   ├── run_experiments_b_c_d_jl.jl # Thu thập số liệu thời gian, bộ nhớ, FI count
│   ├── run_scalability_e_jl.jl     # Thí nghiệm khả năng mở rộng trên tập Accidents
│   ├── run_length_impact_f_jl.jl   # Thí nghiệm ảnh hưởng độ dài trên CSDL tổng hợp
│   └── plot_results.jl     # Tự động hóa việc vẽ biểu đồ từ kết quả thực nghiệm
├── experiment_results/     # Cơ sở dữ liệu thô phục vụ báo cáo
│   ├── results_experiment.csv      # Kết quả so sánh Basic vs Optimized
│   ├── results_scalability.csv     # Số liệu khả năng mở rộng
│   ├── results_length.csv          # Số liệu ảnh hưởng độ dài giao dịch
│   └── spmf_benchmark_results.csv  # Số liệu tham chiếu thu thập từ SPMF
├── charts/                 # Thư mục chứa các biểu đồ PNG đã xuất (dùng trong báo cáo)
├── application/            # Ứng dụng thực tế (Chương 5)
│   ├── run_application.jl  # Phân tích giỏ hàng (MBA) trên tập Retail
│   └── application_results.csv     # Top 10 luật kết hợp có Lift cao nhất
├── data/                   # Toàn bộ dữ liệu sử dụng trong đồ án
│   ├── benchmark/          # Các tập dữ liệu chuẩn: Chess, Mushroom, Retail...
│   ├── toy/                # Dữ liệu nhỏ phục vụ các ví dụ minh họa tay
│   ├── spmf/               # Các file đáp án chuẩn trích xuất từ phần mềm SPMF
│   └── spmf_results/       # Lưu trữ chi tiết kết quả từ thư viện SPMF để chạy đối soát
├── docs/                   # Chứa báo cáo PDF hoàn thiện
├── notebooks/              # Giao diện Demo trực quan bằng Jupyter Notebook
├── Project.toml            # Định nghĩa môi trường và các thư viện phụ thuộc
└── README.md               # Hướng dẫn cài đặt và sử dụng
```

## 5. Hướng dẫn sử dụng và chạy thực nghiệm
Mọi lệnh chạy dưới đây đều thực hiện tại thư mục gốc của dự án.

### 5.1. Chạy thuật toán đơn lẻ (Dùng main.jl)
Nhóm cung cấp tệp `main.jl` giúp chạy linh hoạt các phiên bản thuật toán:
*   **Chạy bản Tối ưu (Optimized):**
    ```bash
    julia --project=. main.jl data/benchmark/mushroom.txt 2000 output.txt opt
    ```
*   **Chạy bản Cơ bản (Basic):**
    ```bash
    julia --project=. main.jl data/benchmark/mushroom.txt 2000 output.txt basic
    ```

### 5.2. Chạy Unit Test tự động
Để kiểm tra độ khớp kết quả (số lượng và nội dung) so với đáp án mẫu SPMF trong thư mục `data/spmf/`:
```bash
julia --project=. test/runtests.jl
```

### 5.3. So sánh hiệu năng tức thời (Benchmarking)
So sánh trực tiếp Thời gian và RAM giữa bản **Set** và **BitArray** trên một tập dữ liệu cụ thể:
```bash
julia --project=. test/test_benchmark.jl data/benchmark/mushroom.txt 2000
```

### 5.4. Lấy đáp án mẫu từ SPMF (Tạo Groundtruth)
Cú pháp: java -jar spmf.jar run dEclat <input> <output> <minsup(percent)>
Sử dụng tệp `spmf.jar` (Java) để trích xuất đáp án chuẩn phục vụ Unit Test:
```bash

java -jar spmf.jar run dEclat data/benchmark/mushroom.txt data/spmf/mushroom_spmf.txt 23.76%
```

### 5.5. Kiểm tra tính đúng đắn (Correctness Test)
Để đối chiếu kết quả của nhóm với thư viện tham chiếu quốc tế SPMF trên quy mô lớn:
```bash
julia --project=. test/test_correctness.jl
```

### 5.6. Chạy thực nghiệm hiệu năng tổng hợp
Đo thời gian chạy, số lượng FI và RAM của bản Basic (Set) vs Optimized (BitArray) trên nhiều ngưỡng minsup:
```bash
julia --project=. experiment/run_experiments_b_c_d.jl
```

### 5.7. Thử nghiệm khả năng mở rộng và Độ dài giao dịch
*   **Scalability**: `julia --project=. experiment/run_scalability_e_jl.jl`
*   **Length Impact**: `julia --project=. experiment/run_length_impact_f_jl.jl`

### 5.8. Vẽ biểu đồ báo cáo
Sau khi đã chạy các script thực nghiệm và có file CSV trong `experiment_results/`, chạy lệnh sau để cập nhật biểu đồ:
```bash
julia --project=. experiment/plot_results.jl
```

## 6. Thành viên thực hiện
*   **Lê Quốc Thiện** (23127481)
*   **Phạm Quang Thịnh** (23127485)