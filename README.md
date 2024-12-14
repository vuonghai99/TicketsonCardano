

### TicketsonCardano

**CTicketsonCardano** là một nền tảng mã nguồn mở, dựa trên công nghệ đám mây, được thiết kế để xây dựng một chợ NFT trên blockchain Cardano.

---

### **Bắt đầu với TicketsonCardano**

Nền tảng này bao gồm ba thành phần: giao diện người dùng (frontend), phần phụ trợ (backend), và hợp đồng thông minh (smart contracts). Các phần frontend và backend cần được triển khai trên máy chủ, trong khi hợp đồng thông minh sẽ tự động được triển khai bởi nền tảng khi tạo NFT mới.

Hãy làm theo hướng dẫn bên dưới để chuẩn bị môi trường phát triển hoặc triển khai ứng dụng lên máy chủ công cộng.

---

### **Cách triển khai trên Google Cloud Platform**

Để triển khai OpenAlgoNFT, chúng ta cần tạo cơ sở dữ liệu, cụm Kubernetes trên Google Cloud Platform (GCP), và cài đặt một số công cụ liên quan. Hướng dẫn này giả định rằng bạn đã có một số kiến thức cơ bản về việc sử dụng GCP.

#### **Yêu cầu trước**

- Bộ công cụ [Google Cloud Platform SDK](https://cloud.google.com/sdk/gcloud)
- [Docker](https://www.docker.com/)
- [Kubernetes Tools](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)
- Cơ sở dữ liệu SQL trên GCP
- Container Registry trên GCP

#### **Tạo cụm Kubernetes**

1. Khởi tạo SDK Google Cloud Platform bằng cách chạy lệnh `gcloud init` và làm theo hướng dẫn.
2. Truy cập [Kubernetes Engine](https://console.cloud.google.com/kubernetes/).
3. Nhấp vào **Tạo**.
4. Cấu hình cụm của bạn. Để thử nghiệm, bạn có thể sử dụng cụm `Tiêu chuẩn` với cấu hình mặc định và giảm số lượng nút (phụ thuộc vào ngân sách).
   - Để giảm số lượng nút, vào **default-pool**, thay đổi `Số lượng nút` thành `1`.
5. Đợi cụm của bạn được cung cấp.
6. Nhấp vào nút **Hành động**, chọn **Kết nối**, và chạy lệnh được cung cấp để kết nối với cụm.
7. Sau đó, bạn có thể truy cập cụm Kubernetes bằng lệnh `kubectl`. Hãy tham khảo [Tổng quan về kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) để biết thêm chi tiết.

---

### **Triển khai backend**

Thư mục `backend` chứa thư mục `helm` bao gồm biểu đồ Helm. Biểu đồ Helm giúp quản lý sự phức tạp của việc triển khai ứng dụng trên Kubernetes. Trước khi triển khai, chúng ta cần cấu hình biểu đồ Helm và cài đặt [Bộ điều khiển Nginx Kubernetes](https://kubernetes.github.io/ingress-nginx/deploy/).

#### **Cấu hình**

- Trong tệp `values.yaml`, thiết lập biến `host_dns` thành tên miền của bạn.
- Trong tệp `secrets.yaml`, cấu hình:
  - `DATABASE_URL`: URL để truy cập cơ sở dữ liệu, tương thích với [dj-database-url](https://github.com/jacobian/dj-database-url).
  - `PURESTAKE_API_KEY`: Khóa API của Purestake.
  - `GOOGLE_CREDENTIALS`: Thông tin xác thực tài khoản dịch vụ Google, được mã hóa base64.

#### **Triển khai**

1. Kết nối Docker của bạn với Container Registry trên Google Cloud Platform.
2. Tạo không gian tên Kubernetes bằng lệnh `kubectl create namespace <tên-không-gian-tên>`.
3. Chuyển sang không gian tên đó bằng lệnh `kubectl config set-context --current --namespace=<tên-không-gian-tên>`.
4. Chạy `make image && make push && make deploy`.
5. Kiểm tra xem các container có đang chạy không bằng lệnh `kubectl get pods`.
6. Chuyển sang không gian tên `nginx-ingress` Kubernetes và lấy địa chỉ IP của máy chủ Nginx bằng lệnh `kubectl get services`.
7. Tạo một Load Balancer trỏ đến máy chủ Nginx đó.

---

### **Triển khai frontend**

Để triển khai frontend, chúng tôi khuyến nghị sử dụng [Vercel.com](https://vercel.com/), có thể kết nối với kho GitHub và tự động quản lý việc triển khai.

---

### **Thiết lập môi trường phát triển**

#### **Backend**

Mặc định, dự án sử dụng cơ sở dữ liệu SQLite, được tích hợp sẵn và không cần cài đặt riêng. Tuy nhiên, cần RabbitMQ để xử lý hàng đợi thông điệp cho worker nền.

#### **Cấu hình**

Bạn có thể đặt các biến cấu hình trong môi trường shell hoặc trong tệp `backend/settings_dev.py`.

- `PURESTAKE_API_KEY`: Phải là khóa API Purestake của bạn.
- `USE_TESTNET`: Đặt thành `0` nếu bạn muốn sử dụng cơ sở hạ tầng MainNet.

#### **Chạy máy chủ phát triển**

1. Cài đặt [Python](https://www.python.org/) 3.9 và [Poetry](https://python-poetry.org/).
2. Vào thư mục `backend`.
3. Chạy `poetry install` để cài đặt các thư viện phụ thuộc và `poetry shell` để bắt đầu sử dụng môi trường ảo chứa các thư viện đó.
4. Di chuyển cơ sở dữ liệu bằng lệnh `python manage.py migrate`.
5. Tạo tài khoản quản trị bằng lệnh `python manage.py createsuperuser`.
6. Chạy máy chủ phát triển với `python manage.py runserver`.
7. Bạn có thể truy cập bảng điều khiển admin tại `http://localhost:8000/admin/`.

---

### **Phát triển hợp đồng**

Chỉ cần môi trường phát triển hợp đồng nếu bạn muốn thay đổi hợp đồng.

#### **Công cụ cần thiết**

- Tải xuống [algorand-builder](https://github.com/scale-it/algorand-builder) và liên kết các gói cần thiết.

#### **Câu lệnh hữu ích**

- `yarn test`: Chạy kiểm tra.
- `yarn algob compile`: Biên dịch hợp đồng.
- `yarn deploy`: Triển khai hợp đồng.

---

Nếu cần thêm chi tiết, hãy cho tôi biết nhé!
