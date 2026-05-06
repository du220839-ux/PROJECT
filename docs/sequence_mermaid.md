# Biểu Đồ Tuần Tự - SecondHand App (Mermaid Version)

## 1. Đăng ký tài khoản

```mermaid
sequenceDiagram
    participant User
    participant App as Mobile App
    participant API as API Gateway
    participant Auth as Auth Controller
    participant DB as Database
    
    User->>App: Nhập thông tin đăng ký
    App->>App: Validate form
    App->>API: POST /auth/register
    API->>Auth: register(req, res)
    Auth->>Auth: Kiểm tra email tồn tại
    Auth->>DB: SELECT * FROM users WHERE email = ?
    DB-->>Auth: Result set
    Auth->>Auth: Mã hóa password
    Auth->>DB: INSERT INTO users
    DB-->>Auth: User created
    Auth-->>API: User + Token
    API-->>App: 201 Created + User data
    App-->>User: Hiển thị đăng ký thành công
```

## 2. Đăng sản phẩm mới

```mermaid
sequenceDiagram
    participant Seller
    participant App as Mobile App
    participant API as API Gateway
    participant Product as Product Controller
    participant DB as Database
    participant Storage as File Storage
    
    Seller->>App: Nhập thông tin SP
    Seller->>App: Chọn hình ảnh
    App->>App: Validate form & images
    App->>API: POST /products (FormData)
    API->>Product: createProduct(req, res)
    Product->>Product: Validate product data
    Product->>DB: INSERT INTO products
    DB-->>Product: Product created
    Product->>Storage: Upload images
    Storage-->>Product: Image URLs
    Product->>DB: INSERT INTO product_images
    DB-->>Product: Images saved
    Product-->>API: Product created
    API-->>App: 201 Created + Product data
    App-->>Seller: Hiển thị đăng SP thành công
```

## 3. Tìm kiếm sản phẩm

```mermaid
sequenceDiagram
    participant Buyer
    participant App as Mobile App
    participant API as API Gateway
    participant Product as Product Controller
    participant DB as Database
    
    Buyer->>App: Nhập từ khóa tìm kiếm
    Buyer->>App: Chọn bộ lọc (danh mục, giá)
    App->>API: GET /products?q=keyword&category=1&min=100&max=1000
    API->>Product: getProducts(req, res)
    Product->>Product: Build WHERE conditions
    Product->>DB: SELECT products with filters
    DB-->>Product: Product list
    Product->>DB: SELECT product_images for products
    DB-->>Product: Images data
    Product->>Product: Format response
    Product-->>API: Products + Images
    API-->>App: 200 OK + Product list
    App->>App: Display products in grid
    App-->>Buyer: Hiển thị kết quả tìm kiếm
```

## 4. Tạo đơn hàng

```mermaid
sequenceDiagram
    participant Buyer
    participant App as Mobile App
    participant API as API Gateway
    participant Order as Order Controller
    participant Payment as Payment Controller
    participant Wallet as Wallet Controller
    participant DB as Database
    
    Buyer->>App: Xem chi tiết sản phẩm
    Buyer->>App: Nhấn "Mua ngay"
    App->>App: Hiển thị form đặt hàng
    Buyer->>App: Xác nhận thông tin & thanh toán
    App->>API: POST /orders
    API->>Order: createOrder(req, res)
    Order->>Order: Validate order data
    Order->>DB: INSERT INTO orders
    DB-->>Order: Order created
    Order->>Wallet: getBalance(user_id)
    Wallet->>DB: SELECT balance FROM wallets
    DB-->>Wallet: Balance amount
    Wallet-->>Order: User balance
    Order->>Order: Check sufficient balance
    Order->>Payment: processPayment(order_id, amount)
    Payment->>DB: UPDATE wallets (deduct)
    Payment->>DB: INSERT INTO transactions
    DB-->>Payment: Payment processed
    Payment-->>Order: Payment success
    Order->>DB: UPDATE orders status = 'paid'
    DB-->>Order: Order updated
    Order-->>API: Order created + Payment success
    API-->>App: 201 Created + Order data
    App->>App: Show order confirmation
    App-->>Buyer: Hiển thị đơn hàng thành công
```

## 5. Nhắn tin real-time

```mermaid
sequenceDiagram
    participant Buyer
    participant Seller
    participant AppB as App (Buyer)
    participant AppS as App (Seller)
    participant API as API Gateway
    participant Message as Message Controller
    participant DB as Database
    participant WS as WebSocket Server
    
    Buyer->>AppB: Nhập tin nhắn
    AppB->>API: POST /messages
    API->>Message: sendMessage(req, res)
    Message->>DB: INSERT INTO messages
    DB-->>Message: Message saved
    Message->>WS: Broadcast to recipient
    WS->>AppS: Push notification
    AppS->>AppS: Update chat UI
    AppS-->>Seller: Hiển thị tin nhắn mới
    
    Note over AppB, AppS: Real-time messaging via WebSocket
    
    Seller->>AppS: Trả lời tin nhắn
    AppS->>API: POST /messages
    API->>Message: sendMessage(req, res)
    Message->>DB: INSERT INTO messages
    DB-->>Message: Message saved
    Message->>WS: Broadcast to recipient
    WS->>AppB: Push notification
    AppB->>AppB: Update chat UI
    AppB-->>Buyer: Hiển thị tin nhắn mới
```

## 6. Admin phê duyệt sản phẩm

```mermaid
sequenceDiagram
    participant Admin
    participant Dashboard as Admin Dashboard
    participant API as API Gateway
    participant Product as Product Controller
    participant Notif as Notification Controller
    participant DB as Database
    
    Admin->>Dashboard: Xem danh sách SP chờ duyệt
    Dashboard->>API: GET /products/admin/pending
    API->>Product: getPendingProducts(req, res)
    Product->>DB: SELECT products WHERE status = 'pending'
    DB-->>Product: Pending products
    Product-->>API: Pending products list
    API-->>Dashboard: Display pending products
    
    Admin->>Dashboard: Chọn sản phẩm + "Phê duyệt"
    Dashboard->>API: PATCH /products/admin/{id}/status
    API->>Product: updateModerationStatus(req, res)
    Product->>DB: UPDATE products SET status = 'approved'
    DB-->>Product: Product updated
    Product->>Notif: sendNotification(user_id, "Sản phẩm đã được duyệt")
    Notif->>DB: INSERT INTO notifications
    DB-->>Notif: Notification saved
    Product-->>API: Status updated
    API-->>Dashboard: 200 OK
    Dashboard->>Dashboard: Remove from pending list
    Dashboard-->>Admin: Hiển thị phê duyệt thành công
```

## Chú thích

### Các luồng xử lý chính:
1. **Đăng ký**: Xác thực người dùng mới
2. **Đăng sản phẩm**: Upload và lưu sản phẩm
3. **Tìm kiếm**: Query với filter và pagination
4. **Đơn hàng**: Tạo đơn và xử lý thanh toán
5. **Nhắn tin**: Real-time communication
6. **Admin**: Moderation và quản lý

### Các thành phần tham gia:
- **User/Seller/Buyer/Admin**: Actors
- **Mobile App**: Flutter frontend
- **API Gateway**: Express.js backend
- **Controllers**: Business logic
- **Database**: SQL Server
- **File Storage**: Image uploads
- **WebSocket**: Real-time messaging

### Cách sử dụng:
- Copy từng diagram vào file markdown
- Sử dụng trên GitHub, GitLab, VS Code
- Hoặc render online tại: https://mermaid.live/
