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
├── main.jl                # Trình điều khiển trung tâm (Runner chính)
├── src/                   # Mã nguồn chính của thuật toán
│   ├── algorithm/         # eclat_basic.jl, eclat_optimized.jl
│   ├── structures.jl      # Định nghĩa ItemsetBasic, ItemsetOptimized
│   └── utils.jl           # Module đọc/ghi file chuẩn SPMF
├── test/                  # Kiểm tra tính đúng đắn và hiệu năng
│   ├── runtests.jl        # Unit Test đối soát 100% với SPMF
│   └── test_benchmark.jl  # So sánh tốc độ & RAM giữa Basic và Opt
├── data/                  # Dữ liệu thực nghiệm
│   ├── benchmark/         # Các tập dữ liệu mẫu (.txt)
│   └── spmf/              # Đáp án mẫu từ thư viện SPMF (Groundtruth)
├── notebooks/             # Demo trực quan bằng Jupyter Notebook
├── experiment/            # Script thực hiện thí nghiệm chuyên sâu (Chương 4)
├── experiment_results/    # Kết quả thô dưới dạng CSV
├── application/           # Ứng dụng Phân tích giỏ hàng (Chương 5)
├── Project.toml           # Quản lý môi trường
└── README.md
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