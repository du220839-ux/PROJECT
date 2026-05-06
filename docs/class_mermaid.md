# Biểu Đồ Lớp - SecondHand App (Mermaid Version)

## 1. Frontend Models

```mermaid
classDiagram
    class UserModel {
        -int id
        -String name
        -String email
        -String? phone
        -String? address
        -String? avatar
        -String role
        -DateTime createdAt
        +UserModel()
        +UserModel.fromJson()
        +Map toJson()
        +UserModel copyWith()
    }
    
    class ProductModel {
        -int id
        -int userId
        -int categoryId
        -String title
        -String description
        -double price
        -String status
        -DateTime createdAt
        -UserModel user
        -CategoryModel category
        -List~String~ images
        -bool isFavorite
        +ProductModel()
        +ProductModel.fromJson()
        +Map toJson()
        +ProductModel copyWith()
    }
    
    class CategoryModel {
        -int id
        -String name
        -String icon
        -DateTime createdAt
        +CategoryModel()
        +CategoryModel.fromJson()
        +Map toJson()
    }
    
    class OrderModel {
        -int id
        -int buyerId
        -int sellerId
        -int productId
        -double amount
        -String status
        -DateTime createdAt
        -ProductModel product
        -UserModel buyer
        -UserModel seller
        +OrderModel()
        +OrderModel.fromJson()
        +Map toJson()
    }
    
    class MessageModel {
        -int id
        -int senderId
        -int receiverId
        -int productId
        -String message
        -bool isRead
        -DateTime createdAt
        +MessageModel()
        +MessageModel.fromJson()
        +Map toJson()
    }
    
    class NotificationModel {
        -int id
        -int userId
        -String title
        -String content
        -bool isRead
        -DateTime createdAt
        +NotificationModel()
        +NotificationModel.fromJson()
        +Map toJson()
    }
    
    UserModel "1" -- "*" ProductModel : creates
    UserModel "1" -- "*" OrderModel : places
    UserModel "1" -- "*" MessageModel : sends
    ProductModel "*" -- "1" CategoryModel : belongs_to
    ProductModel "1" -- "*" OrderModel : ordered_in
    ProductModel "1" -- "*" MessageModel : about
    UserModel "1" -- "*" NotificationModel : receives
```

## 2. State Management (Providers)

```mermaid
classDiagram
    class AuthProvider {
        -UserModel? _user
        -bool _isLoading
        -String? _error
        +UserModel? get user
        +bool get isLoading
        +bool get isAuthenticated
        +Future~void~ login()
        +Future~void~ register()
        +Future~void~ logout()
        +Future~void~ updateProfile()
        +void updateUser()
    }
    
    class ProductProvider {
        -List~ProductModel~ _products
        -List~ProductModel~ _myProducts
        -List~ProductModel~ _favorites
        -bool _isLoading
        -String? _error
        +List~ProductModel~ get products
        +Future~void~ loadProducts()
        +Future~void~ searchProducts()
        +Future~void~ loadProductDetail()
        +Future~bool~ createProduct()
        +Future~bool~ updateProduct()
        +Future~bool~ deleteProduct()
        +Future~void~ toggleFavorite()
    }
    
    class OrderProvider {
        -List~OrderModel~ _orders
        -OrderModel? _currentOrder
        -bool _isLoading
        +List~OrderModel~ get orders
        +Future~void~ loadOrders()
        +Future~bool~ createOrder()
        +Future~bool~ updateOrderStatus()
    }
    
    class ChatProvider {
        -List~MessageModel~ _messages
        -Map~int, List~MessageModel~~ _conversations
        -bool _isLoading
        +List~MessageModel~ get messages
        +Future~void~ loadMessages()
        +Future~void~ sendMessage()
        +Future~void~ markAsRead()
    }
    
    AuthProvider --> UserModel : manages
    ProductProvider --> ProductModel : manages
    OrderProvider --> OrderModel : manages
    ChatProvider --> MessageModel : manages
```

## 3. API Services

```mermaid
classDiagram
    class ApiService {
        -Dio _dio
        -String _baseUrl
        +Future~Response~ get()
        +Future~Response~ post()
        +Future~Response~ put()
        +Future~Response~ delete()
        +Future~Response~ postFormData()
    }
    
    class AuthService {
        -ApiService _api
        +Future~UserModel~ login()
        +Future~UserModel~ register()
        +Future~UserModel~ getProfile()
        +Future~UserModel~ updateProfile()
    }
    
    class ProductService {
        -ApiService _api
        +Future~List~ProductModel~~ getProducts()
        +Future~ProductModel~ getProduct()
        +Future~ProductModel~ createProduct()
        +Future~ProductModel~ updateProduct()
        +Future~void~ deleteProduct()
        +Future~List~ProductModel~~ getMyProducts()
        +Future~void~ toggleFavorite()
        +Future~List~ProductModel~~ getFavorites()
    }
    
    class OrderService {
        -ApiService _api
        +Future~List~OrderModel~~ getOrders()
        +Future~OrderModel~ getOrder()
        +Future~OrderModel~ createOrder()
        +Future~OrderModel~ updateOrder()
        +Future~void~ cancelOrder()
    }
    
    class MessageService {
        -ApiService _api
        +Future~List~MessageModel~~ getMessages()
        +Future~MessageModel~ sendMessage()
        +Future~void~ markAsRead()
        +Future~List~MessageModel~~ getConversations()
    }
    
    AuthService --> ApiService : uses
    ProductService --> ApiService : uses
    OrderService --> ApiService : uses
    MessageService --> ApiService : uses
```

## 4. UI Components (Widgets)

```mermaid
classDiagram
    class ProductCard {
        -ProductModel product
        -VoidCallback? onFavorite
        -VoidCallback? onTap
        +ProductCard()
        +Widget build()
    }
    
    class AppTextField {
        -TextEditingController controller
        -String label
        -IconData? prefixIcon
        -String? Function(String?)? validator
        +AppTextField()
        +Widget build()
    }
    
    class AppButton {
        -String text
        -VoidCallback onPressed
        -bool isLoading
        +AppButton()
        +Widget build()
    }
    
    class LoadingWidget {
        +LoadingWidget()
        +Widget build()
    }
    
    class EmptyWidget {
        -String message
        -IconData icon
        -VoidCallback? onAction
        +EmptyWidget()
        +Widget build()
    }
    
    ProductCard --> ProductModel : displays
    AppTextField -- TextEditingController : uses
    AppButton -- VoidCallback : uses
```

## 5. Screens

```mermaid
classDiagram
    class HomeScreen {
        -ProductProvider _productProvider
        +Widget build()
        +Widget _buildProductGrid()
        +Widget _buildCategories()
    }
    
    class SearchScreen {
        -TextEditingController _searchController
        -ProductProvider _productProvider
        +Widget build()
        +Widget _buildSearchBar()
        +Widget _buildFilters()
        +Widget _buildResults()
    }
    
    class ProductDetailScreen {
        -ProductModel product
        -ProductProvider _productProvider
        +Widget build()
        +Widget _buildProductInfo()
        +Widget _buildSellerInfo()
        +Widget _buildActions()
    }
    
    class EditProfileScreen {
        -GlobalKey~FormState~ _formKey
        -TextEditingController _nameController
        -TextEditingController _phoneController
        -TextEditingController _addressController
        +Widget build()
        +Future~void~ _save()
        +Future~void~ _pickAvatar()
    }
    
    class ChatListScreen {
        -ChatProvider _chatProvider
        +Widget build()
        +Widget _buildConversationList()
    }
    
    HomeScreen --> ProductProvider : uses
    SearchScreen --> ProductProvider : uses
    ProductDetailScreen --> ProductProvider : uses
    EditProfileScreen --> AuthProvider : uses
    ChatListScreen --> ChatProvider : uses
```

## 6. Backend Controllers

```mermaid
classDiagram
    class AuthController {
        +async function register()
        +async function login()
        +async function getProfile()
        +async function updateProfile()
    }
    
    class ProductController {
        +async function createProduct()
        +async function getProducts()
        +async function getProduct()
        +async function updateProduct()
        +async function deleteProduct()
        +async function getMyProducts()
        +async function getPendingProducts()
    }
    
    class OrderController {
        +async function createOrder()
        +async function getOrders()
        +async function getOrder()
        +async function updateOrder()
        +async function getUserOrders()
    }
    
    class MessageController {
        +async function getMessages()
        +async function sendMessage()
        +async function markAsRead()
        +async function getConversations()
    }
    
    class NotificationController {
        +async function getNotifications()
        +async function markAsRead()
        +async function sendNotification()
    }
```

## 7. Database Schema

```mermaid
erDiagram
    users {
        int id PK
        nvarchar name
        nvarchar email
        nvarchar password
        nvarchar phone
        nvarchar address
        nvarchar avatar
        nvarchar role
        datetime2 created_at
    }
    
    products {
        int id PK
        int user_id FK
        int category_id FK
        nvarchar title
        nvarchar description
        decimal price
        nvarchar status
        datetime2 created_at
    }
    
    categories {
        int id PK
        nvarchar name
        nvarchar icon
        datetime2 created_at
    }
    
    orders {
        int id PK
        int buyer_id FK
        int seller_id FK
        int product_id FK
        decimal amount
        nvarchar status
        datetime2 created_at
    }
    
    messages {
        int id PK
        int sender_id FK
        int receiver_id FK
        int product_id FK
        nvarchar message
        bit is_read
        datetime2 created_at
    }
    
    product_images {
        int id PK
        int product_id FK
        nvarchar image_url
        datetime2 created_at
    }
    
    favorites {
        int id PK
        int user_id FK
        int product_id FK
        datetime2 created_at
    }
    
    notifications {
        int id PK
        int user_id FK
        nvarchar title
        nvarchar content
        bit is_read
        datetime2 created_at
    }
    
    users ||--o{ products : owns
    users ||--o{ orders : buys
    users ||--o{ orders : sells
    users ||--o{ messages : sends
    users ||--o{ messages : receives
    categories ||--o{ products : contains
    products ||--o{ product_images : has
    products ||--o{ orders : generates
    products ||--o{ messages : about
    users ||--o{ favorites : likes
    users ||--o{ notifications : receives
```

## Chú thích

### Các lớp chính:
- **Models**: Dữ liệu đầu vào/ra của hệ thống
- **Providers**: Quản lý state (Flutter Provider pattern)
- **Services**: Giao tiếp với backend API
- **Widgets**: UI components tái sử dụng
- **Screens**: Các màn hình chính của ứng dụng
- **Controllers**: Business logic ở backend
- **Database**: Cấu trúc dữ liệu SQL Server

### Các mối quan hệ:
- **Association**: Classes sử dụng lẫn nhau
- **Aggregation**: "has-a" relationship
- **Composition**: "part-of" relationship
- **Inheritance**: "is-a" relationship
- **Dependency**: Tạm thời sử dụng

### Design Patterns:
- **Repository Pattern**: Services layer
- **Provider Pattern**: State management
- **MVC Pattern**: Controllers + Views
- **DTO Pattern**: Models for data transfer
