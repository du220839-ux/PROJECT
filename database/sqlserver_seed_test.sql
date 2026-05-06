/*
  Seed data for quick API testing
  Run after sqlserver_schema.sql
*/

SET NOCOUNT ON;
GO

USE SecondHandDB;
GO

IF OBJECT_ID('dbo.users', 'U') IS NULL
BEGIN
  THROW 50001, 'Schema not found. Run database/sqlserver_schema.sql first in SecondHandDB.', 1;
END
GO

-- Clear current data in safe order
DELETE FROM dbo.notifications;
DELETE FROM dbo.reports;
DELETE FROM dbo.reviews;
DELETE FROM dbo.favorites;
DELETE FROM dbo.messages;
DELETE FROM dbo.product_images;
DELETE FROM dbo.products;
DELETE FROM dbo.users;
GO

-- Test users (password is plain text for quick local testing)
INSERT INTO dbo.users (name, email, [password], phone, [address], [role])
VALUES
(N'Admin', N'admin@secondhand.local', N'123456', N'0900000000', N'Ho Chi Minh', N'admin'),
(N'Nguyen Van A', N'user1@secondhand.local', N'123456', N'0911111111', N'Ha Noi', N'user'),
(N'Le Thi B', N'user2@secondhand.local', N'123456', N'0922222222', N'Da Nang', N'user');
GO

DECLARE @userA INT = (SELECT TOP 1 id FROM dbo.users WHERE email = N'user1@secondhand.local');
DECLARE @userB INT = (SELECT TOP 1 id FROM dbo.users WHERE email = N'user2@secondhand.local');
DECLARE @catPhone INT = (SELECT TOP 1 id FROM dbo.categories WHERE name = N'Dien thoai');
DECLARE @catLaptop INT = (SELECT TOP 1 id FROM dbo.categories WHERE name = N'Laptop');

INSERT INTO dbo.products (user_id, category_id, title, [description], price, [status])
VALUES
(@userA, @catPhone, N'iPhone 13 128GB', N'May dep 99%, pin 88%, full box', 11500000, N'approved'),
(@userB, @catLaptop, N'MacBook Air M1', N'RAM 8GB SSD 256GB, ngoai hinh dep', 15500000, N'approved');
GO

DECLARE @product1 INT = (SELECT TOP 1 id FROM dbo.products WHERE title = N'iPhone 13 128GB' ORDER BY id DESC);
DECLARE @product2 INT = (SELECT TOP 1 id FROM dbo.products WHERE title = N'MacBook Air M1' ORDER BY id DESC);

INSERT INTO dbo.product_images (product_id, image_url)
VALUES
(@product1, N'https://images.unsplash.com/photo-1510557880182-3c0f30ad4f2b?w=1200'),
(@product1, N'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=1200'),
(@product2, N'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=1200');
GO

DECLARE @adminId INT = (SELECT TOP 1 id FROM dbo.users WHERE email = N'admin@secondhand.local');
DECLARE @userA2 INT = (SELECT TOP 1 id FROM dbo.users WHERE email = N'user1@secondhand.local');
DECLARE @userB2 INT = (SELECT TOP 1 id FROM dbo.users WHERE email = N'user2@secondhand.local');
DECLARE @product1Ref INT = (SELECT TOP 1 id FROM dbo.products WHERE title = N'iPhone 13 128GB' ORDER BY id DESC);
DECLARE @product2Ref INT = (SELECT TOP 1 id FROM dbo.products WHERE title = N'MacBook Air M1' ORDER BY id DESC);

INSERT INTO dbo.reviews (product_id, reviewer_id, seller_id, rating, comment)
VALUES
(@product2Ref, @userA2, @userB2, 5, N'Nguoi ban nhiet tinh, san pham dung mo ta'),
(@product1Ref, @userB2, @userA2, 4, N'Giao dich nhanh, may dung on');

INSERT INTO dbo.reports (product_id, reporter_id, reason, [status])
VALUES
(@product1Ref, @userB2, N'Nghi ngo thong tin chua day du', N'pending'),
(@product2Ref, @userA2, N'Can admin kiem tra them hinh anh', N'reviewing');

INSERT INTO dbo.notifications (user_id, title, content, is_read)
VALUES
(@userA2, N'Bai dang da duoc duyet', N'San pham iPhone 13 128GB cua ban da duoc duyet.', 0),
(@userB2, N'Ban co danh gia moi', N'Khach hang vua gui danh gia cho giao dich cua ban.', 0),
(@adminId, N'Bao cao moi', N'He thong vua nhan them bao cao vi pham can xu ly.', 1);
GO
