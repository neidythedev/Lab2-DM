Dưới đây là bản cập nhật tệp `README.md` hoàn chỉnh, bổ sung các hướng dẫn chạy dòng lệnh cho trình điều khiển trung tâm (`main.jl`), hệ thống Unit Test và so sánh hiệu năng dựa trên các tính năng nhóm vừa phát triển.

---

# Đồ án 2: Khai thác tập phổ biến - Thuật toán Eclat

Dự án này thực hiện cài đặt và đánh giá thuật toán **Eclat (Equivalence CLASS Transformation)** bằng ngôn ngữ lập trình Julia. Đây là một phần của môn học **Khai thác dữ liệu và ứng dụng**.

## 1. Giới thiệu
Thuật toán Eclat sử dụng cách tiếp cận duyệt theo chiều sâu (DFS) trên mô hình dữ liệu dọc (Vertical Data Layout). Phiên bản này bao gồm hai cách cài đặt:
*   **Bản Cơ bản (Basic):** Sử dụng `Set` để quản lý TID-sets.
*   **Bản Tối ưu (Optimized):** Sử dụng `BitArray` và các phép toán bitwise chuyên sâu giúp tăng tốc độ xử lý gấp nhiều lần.

## 2. Yêu cầu hệ thống
*   **Ngôn ngữ:** Julia ≥ 1.9 (Khuyến nghị bản 1.10 hoặc 1.12 LTS).
*   **Thư viện hỗ trợ:** `CSV.jl`, `DataFrames.jl`, `Plots.jl`, `BenchmarkTools.jl`.

## 3. Cài đặt môi trường
Mở Terminal tại thư mục gốc của đồ án (`LAB2-DM/`) và thực hiện:
```bash
julia --project=. -e "using Pkg; Pkg.instantiate()"
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
│   └── spmf_results/       # Lưu trữ chi tiết kết quả chạy đối soát
├── docs/                   # Chứa báo cáo PDF hoàn thiện
├── notebooks/              # Giao diện Demo trực quan bằng Jupyter Notebook
├── Project.toml            # Định nghĩa môi trường và các thư viện phụ thuộc
└── README.md               # Hướng dẫn cài đặt và sử dụng
```

## 5. Hướng dẫn sử dụng

### 5.1. Chạy thuật toán đơn lẻ (Dùng main.jl)
Nhóm cung cấp tệp `main.jl` giúp chạy linh hoạt các phiên bản thuật toán thông qua dòng lệnh:
*   **Cú pháp:** `julia --project=. main.jl <input> <minsup> <output> <mode>`
*   **Chạy bản Tối ưu (Mặc định):**
    ```bash
    julia --project=. main.jl data/benchmark/mushroom.txt 2000 output.txt opt
    ```
*   **Chạy bản Cơ bản:**
    ```bash
    julia --project=. main.jl data/benchmark/mushroom.txt 2000 output.txt basic
    ```

### 5.2. Kiểm thử tự động (Unit Test)
Để kiểm tra độ khớp kết quả (số lượng và nội dung tập phổ biến) so với thư viện chuẩn SPMF:
```bash
julia --project=. test/runtests.jl
```
*Hệ thống sẽ tự động quét các tập dữ liệu trong cấu hình và báo cáo trạng thái Pass/Fail.*

### 5.3. So sánh hiệu năng (Benchmarking)
Để đo trực tiếp sự chênh lệch về thời gian và bộ nhớ giữa bản sử dụng **Set** và **BitArray**:
```bash
julia --project=. test/test_benchmark.jl data/benchmark/mushroom.txt 2000
```
*Kết quả sẽ hiển thị tỉ lệ tốc độ được cải thiện (ví dụ: Tối ưu nhanh gấp 15 lần).*

### 5.4. Chạy thực nghiệm chuyên sâu & Vẽ biểu đồ
*   **Thực nghiệm tổng hợp:** `julia --project=. experiment/run_experiments_b_c_d.jl`
*   **Vẽ biểu đồ báo cáo:** `julia --project=. experiment/plot_results.jl`

## 6. Thành viên thực hiện
*   **Lê Quốc Thiện** (23127481)
*   **Phạm Quang Thịnh** (23127485)

---

### Lưu ý khi chạy trên Windows:
Nếu bạn gặp lỗi đường dẫn, hãy đảm bảo sử dụng dấu gạch chéo xuôi (`/`) hoặc gạch chéo ngược kép (`\\`) trong terminal. Ví dụ: `data/benchmark/toy_data.txt`.