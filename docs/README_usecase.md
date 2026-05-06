# Sơ Đồ Use Case - SecondHand App

## Mô tả

Sơ đồ Use Case này mô tả toàn bộ chức năng của ứng dụng SecondHand - nền tảng mua bán đồ cũ.

## Các Actor (Người tham gia)

### 1. User (Người Dùng)
- Người dùng cơ bản của hệ thống
- Có thể đăng ký, đăng nhập, xem sản phẩm
- Kế thừa bởi Seller và Buyer

### 2. Seller (Người Bán) 
- Kế thừa từ User
- Có thể đăng bán sản phẩm, quản lý sản phẩm
- Xử lý đơn hàng bán hàng

### 3. Buyer (Người Mua)
- Kế thừa từ User  
- Tìm kiếm, mua sản phẩm, quản lý đơn hàng mua

### 4. Admin (Quản Trị Viên)
- Quản lý toàn bộ hệ thống
- Phê duyệt sản phẩm, xử lý báo cáo

## Các Nhóm Use Case Chính

### 🔐 Xác thực
- UC1: Đăng ký
- UC2: Đăng nhập  
- UC3: Đăng xuất
- UC4: Quên mật khẩu
- UC5: Đăng nhập Google/Facebook

### 👤 Quản lý hồ sơ
- UC6: Xem hồ sơ cá nhân
- UC7: Chỉnh sửa hồ sơ
- UC8: Quản lý địa chỉ
- UC9: Tải lên avatar

### 📦 Quản lý sản phẩm
- UC10: Đăng sản phẩm mới
- UC11: Tải lên hình ảnh
- UC12: Chỉnh sửa sản phẩm
- UC13: Xóa sản phẩm
- UC14: Xem sản phẩm của tôi
- UC15: Quản lý trạng thái sản phẩm

### 🔍 Duyệt sản phẩm
- UC16: Tìm kiếm sản phẩm
- UC17: Lọc theo danh mục
- UC18: Lọc theo khoảng giá
- UC19: Sắp xếp sản phẩm
- UC20: Xem chi tiết sản phẩm
- UC21: Xem sản phẩm theo danh mục

### 💬 Tương tác
- UC22: Thêm vào yêu thích
- UC23: Xóa khỏi yêu thích
- UC24: Xem danh sách yêu thích
- UC25: Đánh giá sản phẩm
- UC26: Báo cáo sản phẩm
- UC27: Nhắn tin cho người bán
- UC28: Xem lịch sử nhắn tin

### 💰 Giao dịch
- UC29: Tạo đơn hàng
- UC30: Xem lịch sử mua hàng
- UC31: Xem lịch sử bán hàng
- UC32: Quản lý đơn hàng
- UC33: Hủy đơn hàng
- UC34: Xác nhận đơn hàng

### 💳 Thanh toán
- UC35: Nạp tiền vào ví
- UC36: Thanh toán bằng ví
- UC37: Rút tiền từ ví
- UC38: Xem số dư ví
- UC39: Xem lịch sử giao dịch

### 🛠️ Quản trị
- UC40: Phê duyệt sản phẩm
- UC41: Từ chối sản phẩm
- UC42: Quản lý người dùng
- UC43: Xử lý báo cáo
- UC44: Xem thống kê
- UC45: Quản lý danh mục

### 🔔 Thông báo
- UC46: Nhận thông báo
- UC47: Xem lịch sử thông báo
- UC48: Đánh dấu đã đọc

## Cách sử dụng

### Cài đặt PlantUML
1. Cài đặt Java Runtime Environment
2. Tải PlantUML từ https://plantuml.com/download
3. Hoặc sử dụng VS Code extension: PlantUML

### Tạo sơ đồ
1. Mở file `usecase_diagram.puml`
2. Sử dụng PlantUML renderer để tạo hình ảnh:
   - Online: https://www.plantuml.com/plantuml/uml/
   - VS Code: Ctrl+Shift+P → "PlantUML: Preview"
   - Command line: `java -jar plantuml.jar usecase_diagram.puml`

## Các mối quan hệ chính

- **Include:** Tìm kiếm bao gồm các chức năng lọc và sắp xếp
- **Extend:** Thanh toán có thể mở rộng từ tạo đơn hàng
- **Inheritance:** Seller và Buyer kế thừa từ User

## Lưu ý
- Sơ đồ này được thiết kế theo chuẩn UML 2.0
- Sử dụng theme plain để dễ đọc
- Các use case được nhóm theo chức năng để dễ quản lý
