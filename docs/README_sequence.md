# Biểu Đồ Tuần Tự (Sequence Diagram) - SecondHand App

## Tổng quan

Biểu đồ tuần tự mô tả luồng xử lý và tương tác giữa các thành phần trong hệ thống theo thời gian. Đây là công cụ quan trọng để hiểu cách các module giao tiếp với nhau.

## Các luồng xử lý đã mô tả

### 🔄 1. Đăng ký tài khoản
**Mục đích:** Hiển thị quy trình đăng ký người dùng mới
**Các bước chính:**
- User nhập thông tin → App validate → Gửi API
- Backend kiểm tra email tồn tại
- Mã hóa password và lưu vào database
- Trả về user data + JWT token

### 📦 2. Đăng sản phẩm mới  
**Mục đích:** Quy trình đăng bán sản phẩm
**Các bước chính:**
- Seller nhập thông tin + upload ảnh
- Backend validate dữ liệu
- Lưu product vào database
- Upload ảnh lên file storage
- Lưu URLs ảnh vào database

### 🔍 3. Tìm kiếm sản phẩm
**Mục đích:** Hiển thị luồng tìm kiếm và lọc sản phẩm
**Các bước chính:**
- Buyer nhập từ khóa + bộ lọc
- Backend xây dựng WHERE conditions động
- Query products với filters
- Join với bảng images
- Return formatted response

### 🛒 4. Tạo đơn hàng
**Mục đích:** Quy trình mua hàng và thanh toán
**Các bước chính:**
- Buyer xác nhận mua hàng
- Tạo order trong database
- Kiểm tra số dư ví
- Process payment (trừ tiền + ghi nhận transaction)
- Cập nhật status order

### 💬 5. Nhắn tin real-time
**Mục đích:** Giao tiếp giữa buyer và seller
**Đặc điểm:**
- Sử dụng WebSocket cho real-time
- Database lưu lịch sử tin nhắn
- Push notification cho recipient
- Two-way communication

### 🛠️ 6. Admin phê duyệt sản phẩm
**Mục đích:** Quy trình moderation của admin
**Các bước chính:**
- Admin view pending products
- Approve/reject products
- Cập nhật status trong database
- Gửi notification cho seller

## Các thành phần hệ thống

### Frontend Layer
- **Mobile App (Flutter)**
  - UI/UX handling
  - Form validation
  - Local state management
  - WebSocket client

### Backend Layer  
- **API Gateway (Express.js)**
  - Request routing
  - Authentication middleware
  - Request/response handling

- **Controllers**
  - Auth Controller: Xác thực
  - Product Controller: Quản lý SP
  - Order Controller: Đơn hàng
  - Message Controller: Tin nhắn
  - Payment Controller: Thanh toán
  - Notification Controller: Thông báo

### Data Layer
- **Database (SQL Server)**
  - User management
  - Product catalog
  - Order processing
  - Message history
  - Transaction logs

- **File Storage**
  - Image uploads
  - Static assets

- **WebSocket Server**
  - Real-time messaging
  - Push notifications

## Patterns và Best Practices

### 🔧 Design Patterns
- **Repository Pattern**: Database access
- **Controller Pattern**: Business logic
- **Middleware Pattern**: Authentication & validation
- **Observer Pattern**: WebSocket notifications

### 📊 Performance Optimizations
- **Database Indexing**: Fast queries
- **Image Compression**: Reduce bandwidth
- **Caching**: Frequent data
- **Pagination**: Large result sets

### 🔒 Security Measures
- **JWT Authentication**: Secure API access
- **Password Hashing**: bcrypt
- **Input Validation**: Prevent injection
- **File Upload Security**: Image validation

## Cách sử dụng diagrams

### Với PlantUML (`sequence_diagram.puml`)
```bash
# Cài đặt PlantUML
java -jar plantuml.jar sequence_diagram.puml

# Hoặc dùng VS Code extension
# PlantUML: Preview
```

### Với Mermaid (`sequence_mermaid.md`)
- Copy vào GitHub/GitLab markdown
- VS Code: Mermaid Preview extension
- Online: https://mermaid.live/

## Lợi ích của Sequence Diagrams

1. **Documentation**: Hiểu luồng xử lý hệ thống
2. **Onboarding**: Training cho developer mới
3. **Debugging**: Xác định vấn đề giao tiếp
4. **Planning**: Design features mới
5. **Communication**: Hiểu giữa team members

## Tips khi đọc diagrams

- **Theo dõi từ trên xuống dưới**: Thời gian trôi qua
- **Mũi箭 dọc**: Call messages
- **Mũi箭 ngang**: Return messages  
- **Rectangles**: System boundaries
- **Notes**: Giải thích thêm

## Extension possibilities

Có thể thêm các diagrams khác:
- User login flow
- Password reset flow
- Product review flow
- Refund process
- Report handling flow
