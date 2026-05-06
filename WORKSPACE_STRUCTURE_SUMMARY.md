# Tóm Tắt Cấu Trúc SecondHand App Workspace

## 1. MÔ HÌNH SẢN PHẨM (Product Model)

### File: `lib/models/product_model.dart`

**Cấu trúc dữ liệu Product:**
```dart
class ProductModel {
  final int id;                          // ID sản phẩm
  final int userId;                      // ID người bán
  final int categoryId;                  // ID danh mục
  final String title;                    // Tên sản phẩm
  final String description;              // Mô tả sản phẩm
  final double price;                    // Giá sản phẩm
  final ProductStatus status;            // Trạng thái (pending, approved, rejected, sold)
  final DateTime createdAt;              // Thời gian tạo
  final UserModel? seller;               // Thông tin người bán (liên kết)
  final CategoryModel? category;         // Thông tin danh mục (liên kết)
  final List<String> images;             // Danh sách URL ảnh sản phẩm
  final String? location;                // Địa chỉ sản phẩm
  bool isFavorite;                       // Đánh dấu yêu thích
}
```

**Trạng thái sản phẩm:**
- `pending` → Chờ duyệt
- `approved` → Đang bán
- `rejected` → Từ chối
- `sold` → Đã bán

**Danh mục (Categories):**
```
1. Điện thoại (📱)
2. Laptop (💻)
3. Phụ kiện công nghệ (🎧)
4. Xe cộ (🚲)
5. Quần áo (👕)
6. Nội thất (🪑)
7. Sách (📚)
8. Game / Đồ giải trí (🎮)
9. Đồ gia dụng (🏠)
10. Khác (📦)
```

---

## 2. API ENDPOINTS HIỆN TẠI

### File: `backend/src/routes/productRoutes.js`

**Base URL:** `http://127.0.0.1:8000/api/products`

| Method | Endpoint | Auth | Quyền | Chức năng |
|--------|----------|------|-------|----------|
| GET | `/` | Optional | Public | Lấy danh sách sản phẩm (phân trang, tìm kiếm, lọc) |
| GET | `/:id` | Optional | Public | Lấy chi tiết sản phẩm |
| POST | `/` | Required | User | Tạo sản phẩm mới |
| GET | `/my-products` | Required | User | Lấy sản phẩm của người dùng hiện tại |
| GET | `/admin/pending` | Required | Admin | Lấy danh sách sản phẩm chờ duyệt |
| PATCH | `/admin/:id/status` | Required | Admin | Cập nhật trạng thái sản phẩm (duyệt/từ chối) |

### Chi tiết Endpoints:

#### 1. **GET /products** - Lấy danh sách sản phẩm (Công khai)
**Query Parameters:**
```
- page: number (default: 1) - Số trang
- limit: number (default: 20) - Số bản ghi mỗi trang
- category_id: number - Lọc theo danh mục
- q: string - Tìm kiếm theo tên hoặc mô tả sản phẩm
- min_price: number - Giá tối thiểu
- max_price: number - Giá tối đa
- sort_by: string (newest|oldest|price_low|price_high) - Sắp xếp
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "user_id": 5,
      "category_id": 1,
      "title": "iPhone 13 Pro",
      "description": "Điện thoại mới đẹp",
      "price": 15000000,
      "status": "approved",
      "created_at": "2024-03-20T10:00:00Z",
      "user": {
        "id": 5,
        "name": "Nguyễn Văn A",
        "email": "user@example.com",
        "phone": "0901234567",
        "address": "TP HCM",
        "avatar": "http://..."
      },
      "category": {
        "id": 1,
        "name": "Điện thoại",
        "icon": "📱"
      },
      "images": [
        { "image_url": "http://localhost:8000/uploads/products/..." },
        { "image_url": "http://localhost:8000/uploads/products/..." }
      ],
      "is_favorite": false
    }
  ],
  "page": 1,
  "limit": 20
}
```

#### 2. **GET /products/:id** - Lấy chi tiết sản phẩm
**Response:** Cấu trúc giống như trên (single product)

#### 3. **POST /products** - Tạo sản phẩm mới
**Auth Required:** Yes (Bearer token)

**Body (multipart/form-data):**
```json
{
  "category_id": 1,
  "title": "iPhone 13 Pro",
  "description": "Điện thoại mới đẹp",
  "price": 15000000,
  "location": "TP HCM",
  "images[]": [File, File, ...]  // Tối đa 5 ảnh
}
```

**Response:**
```json
{
  "message": "Product created successfully. Waiting for admin approval.",
  "product": { ... }
}
```

#### 4. **GET /products/my-products** - Lấy sản phẩm của user
**Auth Required:** Yes
**Response:** Array của products

#### 5. **GET /products/admin/pending** - Danh sách chờ duyệt
**Auth Required:** Yes (Admin only)
**Response:** Array của products (status = 'pending')

#### 6. **PATCH /products/admin/:id/status** - Cập nhật trạng thái
**Auth Required:** Yes (Admin only)
**Body:**
```json
{ "status": "approved" | "rejected" }
```

---

## 3. CẤU TRÚC BACKEND (Node.js)

### Controllers: `backend/src/controllers/productController.js`

**Hàm chính:**
1. `createProduct()` - Tạo sản phẩm, upload ảnh
2. `getProducts()` - Lấy danh sách sản phẩm (có lọc, tìm kiếm, sắp xếp)
3. `getProduct()` - Lấy chi tiết sản phẩm
4. `getMyProducts()` - Lấy sản phẩm của user hiện tại
5. `getPendingProducts()` - Lấy danh sách chờ duyệt (Admin)
6. `updateProductStatus()` - Cập nhật trạng thái (Admin)

**Quy trình Database:**
- Sản phẩm lưu trong bảng `dbo.products`
- Ảnh lưu trong bảng `dbo.product_images`
- Yêu thích lưu trong bảng `dbo.favorites`
- Danh mục lưu trong bảng `dbo.categories`

**Middleware:**
- `uploadProductImages` - Xử lý upload ảnh (Multer)
- `auth` - Xác thực người dùng
- `adminOnly` - Kiểm tra quyền admin

### Routes: `backend/src/routes/productRoutes.js`
- Route công khai có thể tùy chọn authenticate
- Route tạo sản phẩm yêu cầu auth + upload middleware
- Route admin yêu cầu auth + adminOnly middleware

---

## 4. CẤU TRÚC SERVICES (lib/services)

### File: `lib/services/product_service.dart`

**Hàm chính:**
```dart
class ProductService {
  // Lấy danh sách sản phẩm (có lọc, tìm kiếm)
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int? categoryId,
    String? query,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  })

  // Lấy chi tiết sản phẩm
  Future<ProductModel> getProduct(int id)

  // Tạo sản phẩm mới
  Future<ProductModel> createProduct({...})

  // Cập nhật sản phẩm
  Future<ProductModel> updateProduct({...})

  // Xóa sản phẩm
  Future<void> deleteProduct(int id)

  // Lấy sản phẩm của user
  Future<List<ProductModel>> getMyProducts()

  // Lấy sản phẩm chờ duyệt (Admin)
  Future<List<ProductModel>> getPendingProducts()

  // Cập nhật trạng thái (Admin)
  Future<void> updateProductModerationStatus({...})

  // Lấy danh mục
  Future<List<CategoryModel>> getCategories()

  // Toggle yêu thích
  Future<void> toggleFavorite(int productId)

  // Lấy danh sách yêu thích
  Future<List<ProductModel>> getFavorites()
}
```

**API Base:** Sử dụng `ApiService` (centralized API wrapper)

---

## 5. CẤU TRÚC PROVIDER (State Management)

### File: `lib/providers/product_provider.dart`

**State:**
```dart
class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products;           // Danh sách sản phẩm
  List<ProductModel> _myProducts;         // Sản phẩm của user
  List<ProductModel> _favorites;          // Danh sách yêu thích
  List<ProductModel> _pendingProducts;    // Chờ duyệt (Admin)
  ProductModel? _currentProduct;          // Chi tiết sản phẩm hiện tại
  
  bool _isLoading;
  bool _hasMore;
  int _currentPage;
  String? _error;
  int? _selectedCategoryId;
}
```

**Hàm chính:**
```dart
// Tải danh sách sản phẩm (phân trang)
Future<void> loadProducts({bool refresh = false})

// Tìm kiếm sản phẩm với điều kiện
Future<void> searchProducts(String query, {int? categoryId, ...})

// Tải chi tiết sản phẩm
Future<void> loadProductDetail(int id)

// Tạo sản phẩm mới
Future<bool> createProduct({...})

// Cập nhật sản phẩm
Future<bool> updateProduct({...})

// Xóa sản phẩm
Future<bool> deleteProduct(int id)

// Tải sản phẩm của user
Future<void> loadMyProducts()

// Tải sản phẩm chờ duyệt
Future<void> loadPendingProducts()

// Toggle yêu thích
Future<void> toggleFavorite(int id)

// Tải danh sách yêu thích
Future<void> loadFavorites()

// Lọc theo danh mục
void filterByCategory(int? categoryId)
```

---

## 6. CẤU TRÚC SCREENS

### Folder: `lib/screens`

```
screens/
├── admin/          # Màn hình admin
├── auth/           # Xác thực
├── chat/           # Chat
├── favorites/      # Danh sách yêu thích
├── help/           # Trợ giúp
├── home/           # Trang chủ
│   └── home_screen.dart
├── order/          # Đơn hàng
├── payment/        # Thanh toán
├── product/        # Sản phẩm
│   ├── add_product_screen.dart       # Thêm sản phẩm mới
│   ├── edit_product_screen.dart      # Chỉnh sửa sản phẩm
│   ├── my_products_screen.dart       # Danh sách sản phẩm của tôi
│   └── product_detail_screen.dart    # Chi tiết sản phẩm
├── profile/        # Hồ sơ user
├── search/         # Tìm kiếm
├── splash/         # Splash screen
└── wallet/         # Ví
```

### Screens chính liên quan đến Product:
1. **home_screen.dart** - Hiển thị danh sách sản phẩm chính
2. **add_product_screen.dart** - Form thêm sản phẩm mới
3. **edit_product_screen.dart** - Form chỉnh sửa sản phẩm
4. **product_detail_screen.dart** - Xem chi tiết sản phẩm
5. **my_products_screen.dart** - Danh sách sản phẩm của user

---

## 7. CẤU TRÚC SERVICES HIỆN CÓ

### `lib/services/` - API Services

1. **api_service.dart** - Centralized API wrapper (Dio)
2. **product_service.dart** - Tất cả API product
3. **auth_service.dart** - Xác thực
4. **chat_service.dart** - Chat
5. **firebase_auth_service.dart** - Firebase auth
6. **google_auth_service.dart** - Google OAuth
7. **location_service.dart** - GPS/Location
8. **notification_service.dart** - Thông báo
9. **order_service.dart** - Đơn hàng
10. **payment_service.dart** - Thanh toán
11. **review_service.dart** - Đánh giá
12. **transaction_service.dart** - Giao dịch
13. **wallet_service.dart** - Ví
14. **report_service.dart** - Báo cáo

---

## 8. LUỒNG DỮ LIỆU

### Tạo sản phẩm:
```
AddProductScreen 
  → ProductProvider.createProduct()
  → ProductService.createProduct()
  → POST /api/products (multipart)
  → Backend: create product + upload images → DB
```

### Xem danh sách sản phẩm:
```
HomeScreen
  → ProductProvider.loadProducts()
  → ProductService.getProducts()
  → GET /api/products?page=1&limit=20
  → Backend: query DB + attach images + check favorites
```

### Tìm kiếm:
```
SearchScreen
  → ProductProvider.searchProducts(query, categoryId, minPrice, maxPrice)
  → ProductService.getProducts(q=query, ...)
  → GET /api/products?q=...&category_id=...&min_price=...&max_price=...
```

### Lọc theo danh mục:
```
HomeScreen
  → ProductProvider.filterByCategory(id)
  → ProductProvider.loadProducts()
  → GET /api/products?category_id=1&page=1
```

---

## 9. TECHNOLOGY STACK

**Frontend (Flutter):**
- [Dio](https://pub.dev/packages/dio) - HTTP client
- Provider - State management
- Image Picker - Chọn ảnh
- MIME - Xác định loại file
- Firebase Authentication

**Backend (Node.js):**
- Express.js - Web framework
- SQL Server - Database
- Multer - File upload
- Middleware: Auth, AdminOnly, Upload

**Database (SQL Server):**
- `dbo.products` - Bảng sản phẩm
- `dbo.product_images` - Bảng ảnh sản phẩm
- `dbo.categories` - Bảng danh mục
- `dbo.favorites` - Bảng yêu thích
- `dbo.users` - Bảng người dùng

---

## 10. LỖI/VẤNĐỀ CẦN LƯU Ý

✅ Sản phẩm sử dụng pagination
✅ Hỗ trợ multiple image upload
✅ Hỗ trợ tìm kiếm full-text
✅ Hỗ trợ lọc theo giá, danh mục
✅ Hỗ trợ sắp xếp (newest, oldest, price_low, price_high)
✅ Tracking favorite status per user
⚠️ Admin moderation workflow

---

**Cập nhật:** 20/03/2026
