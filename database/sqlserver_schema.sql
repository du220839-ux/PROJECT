/*
  SQL Server schema for SecondHand app
  Target: Microsoft SQL Server 2019+
*/

SET NOCOUNT ON;
GO

IF DB_ID(N'SecondHandDB') IS NULL
BEGIN
   CREATE DATABASE SecondHandDB;
END
GO

USE SecondHandDB;
GO

/* =========================
   Drop old tables (safe order)
   ========================= */
IF OBJECT_ID('dbo.notifications', 'U') IS NOT NULL DROP TABLE dbo.notifications;
IF OBJECT_ID('dbo.reports', 'U') IS NOT NULL DROP TABLE dbo.reports;
IF OBJECT_ID('dbo.reviews', 'U') IS NOT NULL DROP TABLE dbo.reviews;
IF OBJECT_ID('dbo.favorites', 'U') IS NOT NULL DROP TABLE dbo.favorites;
IF OBJECT_ID('dbo.messages', 'U') IS NOT NULL DROP TABLE dbo.messages;
IF OBJECT_ID('dbo.product_images', 'U') IS NOT NULL DROP TABLE dbo.product_images;
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL DROP TABLE dbo.products;
IF OBJECT_ID('dbo.categories', 'U') IS NOT NULL DROP TABLE dbo.categories;
IF OBJECT_ID('dbo.users', 'U') IS NOT NULL DROP TABLE dbo.users;
GO

/* =========================
   users
   ========================= */
CREATE TABLE dbo.users (
  id            INT IDENTITY(1,1) PRIMARY KEY,
  name          NVARCHAR(120) NOT NULL,
  email         NVARCHAR(255) NOT NULL,
  [password]    NVARCHAR(255) NOT NULL,
  phone         NVARCHAR(30) NULL,
  [address]     NVARCHAR(255) NULL,
  [role]        NVARCHAR(20) NOT NULL CONSTRAINT DF_users_role DEFAULT ('user'),
  avatar        NVARCHAR(500) NULL,
  created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSUTCDATETIME(),
  updated_at    DATETIME2(0) NOT NULL CONSTRAINT DF_users_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_users_email UNIQUE (email),
  CONSTRAINT CK_users_role CHECK ([role] IN ('user', 'admin'))
);
GO

/* =========================
   categories
   ========================= */
CREATE TABLE dbo.categories (
  id            INT IDENTITY(1,1) PRIMARY KEY,
  name          NVARCHAR(100) NOT NULL,
  icon          NVARCHAR(50) NULL,
  created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_categories_created_at DEFAULT SYSUTCDATETIME(),
  updated_at    DATETIME2(0) NOT NULL CONSTRAINT DF_categories_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_categories_name UNIQUE (name)
);
GO

/* =========================
   products
   ========================= */
CREATE TABLE dbo.products (
  id            INT IDENTITY(1,1) PRIMARY KEY,
  user_id       INT NOT NULL,
  category_id   INT NOT NULL,
  title         NVARCHAR(200) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  price         DECIMAL(18,2) NOT NULL,
  [status]      NVARCHAR(20) NOT NULL CONSTRAINT DF_products_status DEFAULT ('pending'),
  created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_products_created_at DEFAULT SYSUTCDATETIME(),
  updated_at    DATETIME2(0) NOT NULL CONSTRAINT DF_products_updated_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_products_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE,
  CONSTRAINT FK_products_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id),
  CONSTRAINT CK_products_status CHECK ([status] IN ('pending', 'approved', 'rejected', 'sold')),
  CONSTRAINT CK_products_price CHECK (price >= 0)
);
GO

/* =========================
   product_images
   ========================= */
CREATE TABLE dbo.product_images (
  id            INT IDENTITY(1,1) PRIMARY KEY,
  product_id    INT NOT NULL,
  image_url     NVARCHAR(500) NOT NULL,
  created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_product_images_created_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_product_images_product FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE
);
GO

/* =========================
   messages
   ========================= */
CREATE TABLE dbo.messages (
  id            INT IDENTITY(1,1) PRIMARY KEY,
  sender_id     INT NOT NULL,
  receiver_id   INT NOT NULL,
  product_id    INT NOT NULL,
  [message]     NVARCHAR(MAX) NOT NULL,
  is_read       BIT NOT NULL CONSTRAINT DF_messages_is_read DEFAULT (0),
  created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_messages_created_at DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_messages_sender FOREIGN KEY (sender_id) REFERENCES dbo.users(id),
  CONSTRAINT FK_messages_receiver FOREIGN KEY (receiver_id) REFERENCES dbo.users(id),
  CONSTRAINT FK_messages_product FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE,
  CONSTRAINT CK_messages_sender_receiver CHECK (sender_id <> receiver_id)
);
GO

/* =========================
   favorites
   ========================= */
CREATE TABLE dbo.favorites (
  id            INT IDENTITY(1,1) PRIMARY KEY,
  user_id       INT NOT NULL,
  product_id    INT NOT NULL,
  created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_favorites_created_at DEFAULT SYSUTCDATETIME(),
   CONSTRAINT FK_favorites_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
  CONSTRAINT FK_favorites_product FOREIGN KEY (product_id) REFERENCES dbo.products(id) ON DELETE CASCADE,
  CONSTRAINT UQ_favorites_user_product UNIQUE (user_id, product_id)
);
GO

/* =========================
    reviews
    ========================= */
CREATE TABLE dbo.reviews (
   id            INT IDENTITY(1,1) PRIMARY KEY,
   product_id    INT NOT NULL,
   reviewer_id   INT NOT NULL,
   seller_id     INT NOT NULL,
   rating        INT NOT NULL,
   comment       NVARCHAR(MAX) NULL,
   created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_reviews_created_at DEFAULT SYSUTCDATETIME(),
   CONSTRAINT FK_reviews_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
   CONSTRAINT FK_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES dbo.users(id),
   CONSTRAINT FK_reviews_seller FOREIGN KEY (seller_id) REFERENCES dbo.users(id),
   CONSTRAINT CK_reviews_rating CHECK (rating BETWEEN 1 AND 5)
);
GO

/* =========================
    reports
    ========================= */
CREATE TABLE dbo.reports (
   id            INT IDENTITY(1,1) PRIMARY KEY,
   product_id    INT NULL,
   reporter_id   INT NULL,
   reason        NVARCHAR(255) NULL,
   [status]      NVARCHAR(50) NOT NULL CONSTRAINT DF_reports_status DEFAULT ('pending'),
   created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_reports_created_at DEFAULT SYSUTCDATETIME(),
   CONSTRAINT FK_reports_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
   CONSTRAINT FK_reports_reporter FOREIGN KEY (reporter_id) REFERENCES dbo.users(id),
   CONSTRAINT CK_reports_status CHECK ([status] IN ('pending', 'reviewing', 'resolved', 'rejected'))
);
GO

/* =========================
    notifications
    ========================= */
CREATE TABLE dbo.notifications (
   id            INT IDENTITY(1,1) PRIMARY KEY,
   user_id       INT NOT NULL,
   title         NVARCHAR(255) NULL,
   content       NVARCHAR(MAX) NULL,
   is_read       BIT NOT NULL CONSTRAINT DF_notifications_is_read DEFAULT (0),
   created_at    DATETIME2(0) NOT NULL CONSTRAINT DF_notifications_created_at DEFAULT SYSUTCDATETIME(),
   CONSTRAINT FK_notifications_user FOREIGN KEY (user_id) REFERENCES dbo.users(id) ON DELETE CASCADE
);
GO

/* =========================
   Indexes
   ========================= */
CREATE INDEX IX_products_user_id ON dbo.products(user_id);
CREATE INDEX IX_products_category_id ON dbo.products(category_id);
CREATE INDEX IX_products_status ON dbo.products([status]);
CREATE INDEX IX_products_created_at ON dbo.products(created_at DESC);
CREATE INDEX IX_products_title ON dbo.products(title);

CREATE INDEX IX_messages_sender_receiver_product ON dbo.messages(sender_id, receiver_id, product_id);
CREATE INDEX IX_messages_created_at ON dbo.messages(created_at DESC);

CREATE INDEX IX_favorites_user_id ON dbo.favorites(user_id);
CREATE INDEX IX_favorites_product_id ON dbo.favorites(product_id);

CREATE INDEX IX_product_images_product_id ON dbo.product_images(product_id);

CREATE INDEX IX_reviews_product_id ON dbo.reviews(product_id);
CREATE INDEX IX_reviews_seller_id ON dbo.reviews(seller_id);
CREATE INDEX IX_reviews_reviewer_id ON dbo.reviews(reviewer_id);

CREATE INDEX IX_reports_product_id ON dbo.reports(product_id);
CREATE INDEX IX_reports_reporter_id ON dbo.reports(reporter_id);
CREATE INDEX IX_reports_status ON dbo.reports([status]);

CREATE INDEX IX_notifications_user_id ON dbo.notifications(user_id);
CREATE INDEX IX_notifications_is_read ON dbo.notifications(is_read);
GO

/* =========================
   Seed categories
   ========================= */
INSERT INTO dbo.categories (name, icon)
VALUES
('Dien thoai', 'phone'),
('Laptop', 'laptop'),
('Phu kien cong nghe', 'headset'),
('Xe co', 'bike'),
('Quan ao', 'shirt'),
('Noi that', 'chair'),
('Sach', 'book'),
('Game giai tri', 'gamepad'),
('Do gia dung', 'home'),
('Khac', 'box');
GO

/* Optional admin seed (replace password hash from backend) */
-- INSERT INTO dbo.users (name, email, [password], [role])
-- VALUES ('Admin', 'admin@secondhand.local', '$2y$10$replace_with_hash', 'admin');
-- GO
