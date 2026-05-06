USE [SecondHandDB]
GO
/****** Object:  Table [dbo].[admin_roles]    Script Date: 3/18/2026 12:57:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[admin_roles](
	[role_id] [int] IDENTITY(1,1) NOT NULL,
	[role_name] [nvarchar](50) NOT NULL,
	[permissions] [nvarchar](1000) NOT NULL,
	[description] [nvarchar](500) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[admin_users]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[admin_users](
	[admin_user_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[role_id] [int] NOT NULL,
	[is_active] [bit] NULL,
	[assigned_by] [int] NULL,
	[assigned_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[admin_user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[banks]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[banks](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[bank_name] [nvarchar](255) NULL,
	[bank_code] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[categories]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[categories](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[icon] [nvarchar](50) NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[conversations]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[conversations](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[buyer_id] [int] NOT NULL,
	[seller_id] [int] NOT NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[disputes]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[disputes](
	[dispute_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [int] NOT NULL,
	[complainant_id] [int] NOT NULL,
	[respondent_id] [int] NOT NULL,
	[reason] [nvarchar](500) NOT NULL,
	[evidence_images] [nvarchar](1000) NULL,
	[status] [nvarchar](20) NULL,
	[resolution] [nvarchar](500) NULL,
	[admin_id] [int] NULL,
	[created_at] [datetime] NULL,
	[resolved_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[dispute_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[favorites]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[favorites](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[frozen_users]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[frozen_users](
	[freeze_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[reason] [nvarchar](500) NOT NULL,
	[admin_id] [int] NOT NULL,
	[status] [nvarchar](20) NULL,
	[unfreeze_reason] [nvarchar](500) NULL,
	[unfreeze_admin_id] [int] NULL,
	[unfreeze_at] [datetime] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[freeze_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[messages]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[messages](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sender_id] [int] NOT NULL,
	[receiver_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[message] [nvarchar](max) NOT NULL,
	[is_read] [bit] NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[content] [nvarchar](1000) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[notifications]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[notifications](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[title] [nvarchar](255) NULL,
	[content] [nvarchar](max) NULL,
	[is_read] [bit] NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[orders]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[orders](
	[order_id] [int] IDENTITY(1,1) NOT NULL,
	[buyer_id] [int] NOT NULL,
	[seller_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[total_price] [decimal](15, 2) NOT NULL,
	[shipping_address] [nvarchar](500) NULL,
	[shipping_fee] [decimal](10, 2) NULL,
	[status] [nvarchar](20) NULL,
	[is_disputed] [bit] NULL,
	[delivery_at] [datetime] NULL,
	[auto_completed_at] [datetime] NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[payment_holding]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payment_holding](
	[holding_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [int] NOT NULL,
	[amount] [decimal](15, 2) NOT NULL,
	[buyer_id] [int] NOT NULL,
	[seller_id] [int] NOT NULL,
	[status] [nvarchar](20) NULL,
	[release_reason] [nvarchar](200) NULL,
	[released_at] [datetime] NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[holding_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[payments]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payments](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[order_id] [bigint] NULL,
	[amount] [decimal](12, 2) NULL,
	[payment_method] [nvarchar](50) NULL,
	[status] [nvarchar](50) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[product_images]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product_images](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[image_url] [nvarchar](500) NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[product_transactions]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product_transactions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[buyer_id] [int] NOT NULL,
	[seller_id] [int] NOT NULL,
	[status] [nvarchar](20) NOT NULL,
	[created_at] [datetime2](7) NOT NULL,
	[confirmed_at] [datetime2](7) NULL,
	[type] [nvarchar](50) NULL,
	[payment_method] [nvarchar](50) NULL,
	[payment_reference] [nvarchar](100) NULL,
	[admin_id] [int] NULL,
	[processed_at] [datetime] NULL,
	[rejection_reason] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[products]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[products](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[category_id] [int] NOT NULL,
	[title] [nvarchar](200) NOT NULL,
	[description] [nvarchar](max) NULL,
	[price] [decimal](18, 2) NOT NULL,
	[status] [nvarchar](20) NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reports]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reports](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NULL,
	[reporter_id] [int] NULL,
	[reason] [nvarchar](255) NULL,
	[status] [nvarchar](50) NOT NULL,
	[created_at] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reviews]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reviews](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[reviewer_id] [int] NOT NULL,
	[seller_id] [int] NOT NULL,
	[rating] [int] NOT NULL,
	[comment] [nvarchar](max) NULL,
	[created_at] [datetime2](0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[system_settings]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[system_settings](
	[setting_id] [int] IDENTITY(1,1) NOT NULL,
	[setting_key] [nvarchar](100) NOT NULL,
	[setting_value] [nvarchar](1000) NOT NULL,
	[setting_type] [nvarchar](20) NULL,
	[description] [nvarchar](500) NULL,
	[is_public] [bit] NULL,
	[updated_by] [int] NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[setting_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[transactions]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transactions](
	[transaction_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [int] NULL,
	[user_id] [int] NOT NULL,
	[amount] [decimal](15, 2) NOT NULL,
	[type] [nvarchar](50) NOT NULL,
	[status] [nvarchar](20) NOT NULL,
	[payment_method] [nvarchar](50) NULL,
	[payment_reference] [nvarchar](100) NULL,
	[product_name] [nvarchar](200) NULL,
	[from_user_name] [nvarchar](100) NULL,
	[to_user_name] [nvarchar](100) NULL,
	[admin_id] [int] NULL,
	[processed_at] [datetime] NULL,
	[rejection_reason] [nvarchar](500) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[user_bank_accounts]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_bank_accounts](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[bank_id] [bigint] NULL,
	[account_number] [nvarchar](50) NULL,
	[account_name] [nvarchar](255) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[users]    Script Date: 3/18/2026 12:57:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](120) NOT NULL,
	[email] [nvarchar](255) NOT NULL,
	[password] [nvarchar](255) NOT NULL,
	[phone] [nvarchar](30) NULL,
	[address] [nvarchar](255) NULL,
	[role] [nvarchar](20) NOT NULL,
	[avatar] [nvarchar](500) NULL,
	[created_at] [datetime2](0) NOT NULL,
	[updated_at] [datetime2](0) NOT NULL,
	[wallet_balance] [decimal](15, 2) NULL,
	[pending_balance] [decimal](15, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[admin_roles] ON 
GO
INSERT [dbo].[admin_roles] ([role_id], [role_name], [permissions], [description], [created_at]) VALUES (1, N'SUPER_ADMIN', N'["*"]', N'Full system access', CAST(N'2026-03-15T17:25:54.647' AS DateTime))
GO
INSERT [dbo].[admin_roles] ([role_id], [role_name], [permissions], [description], [created_at]) VALUES (2, N'FINANCE_ADMIN', N'["wallet", "transactions", "withdrawals"]', N'Manage wallet and transactions', CAST(N'2026-03-15T17:25:54.647' AS DateTime))
GO
INSERT [dbo].[admin_roles] ([role_id], [role_name], [permissions], [description], [created_at]) VALUES (3, N'DISPUTE_ADMIN', N'["disputes", "orders"]', N'Handle disputes and orders', CAST(N'2026-03-15T17:25:54.647' AS DateTime))
GO
INSERT [dbo].[admin_roles] ([role_id], [role_name], [permissions], [description], [created_at]) VALUES (4, N'USER_ADMIN', N'["users", "freeze"]', N'Manage user accounts', CAST(N'2026-03-15T17:25:54.647' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[admin_roles] OFF
GO
SET IDENTITY_INSERT [dbo].[banks] ON 
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (1, N'Ngân hàng TMCP Ngoại thương Việt Nam', N'VCB')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (2, N'Ngân hàng TMCP Công thương Việt Nam', N'CTG')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (3, N'Ngân hàng TMCP Đầu tư và Phát triển Việt Nam', N'BIDV')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (4, N'Ngân hàng Nông nghiệp và Phát triển Nông thôn', N'AGRIBANK')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (5, N'Ngân hàng TMCP Kỹ thương Việt Nam', N'TCB')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (6, N'Ngân hàng TMCP Việt Nam Thịnh Vượng', N'VPB')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (7, N'Ngân hàng TMCP Quân đội', N'MBBANK')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (8, N'Ngân hàng TMCP Á Châu', N'ACB')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (9, N'Ngân hàng TMCP Tiên Phong', N'TPBANK')
GO
INSERT [dbo].[banks] ([id], [bank_name], [bank_code]) VALUES (10, N'Ngân hàng TMCP Sài Gòn Thương Tín', N'SACOMBANK')
GO
SET IDENTITY_INSERT [dbo].[banks] OFF
GO
SET IDENTITY_INSERT [dbo].[categories] ON 
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (1, N'Dien thoai', N'phone', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (2, N'Laptop', N'laptop', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (3, N'Phu kien cong nghe', N'headset', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (4, N'Xe co', N'bike', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (5, N'Quan ao', N'shirt', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (6, N'Noi that', N'chair', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (7, N'Sach', N'book', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (8, N'Game giai tri', N'gamepad', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (9, N'Do gia dung', N'home', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
INSERT [dbo].[categories] ([id], [name], [icon], [created_at], [updated_at]) VALUES (10, N'Khac', N'box', CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2), CAST(N'2026-03-11T13:36:14.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[categories] OFF
GO
SET IDENTITY_INSERT [dbo].[favorites] ON 
GO
INSERT [dbo].[favorites] ([id], [user_id], [product_id], [created_at]) VALUES (2, 4, 11, CAST(N'2026-03-15T11:13:30.0000000' AS DateTime2))
GO
INSERT [dbo].[favorites] ([id], [user_id], [product_id], [created_at]) VALUES (3, 16, 9, CAST(N'2026-03-15T15:41:17.0000000' AS DateTime2))
GO
INSERT [dbo].[favorites] ([id], [user_id], [product_id], [created_at]) VALUES (4, 16, 11, CAST(N'2026-03-15T15:44:59.0000000' AS DateTime2))
GO
INSERT [dbo].[favorites] ([id], [user_id], [product_id], [created_at]) VALUES (5, 16, 7, CAST(N'2026-03-15T16:03:40.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[favorites] OFF
GO
SET IDENTITY_INSERT [dbo].[messages] ON 
GO
INSERT [dbo].[messages] ([id], [sender_id], [receiver_id], [product_id], [message], [is_read], [created_at], [content]) VALUES (1, 16, 7, 9, N'helo', 0, CAST(N'2026-03-15T15:52:04.0000000' AS DateTime2), N'')
GO
INSERT [dbo].[messages] ([id], [sender_id], [receiver_id], [product_id], [message], [is_read], [created_at], [content]) VALUES (2, 6, 5, 7, N'hello', 0, CAST(N'2026-03-15T15:55:36.0000000' AS DateTime2), N'')
GO
INSERT [dbo].[messages] ([id], [sender_id], [receiver_id], [product_id], [message], [is_read], [created_at], [content]) VALUES (3, 6, 5, 7, N'hhh', 0, CAST(N'2026-03-15T15:55:45.0000000' AS DateTime2), N'')
GO
INSERT [dbo].[messages] ([id], [sender_id], [receiver_id], [product_id], [message], [is_read], [created_at], [content]) VALUES (4, 16, 7, 9, N'heo', 0, CAST(N'2026-03-15T15:57:43.0000000' AS DateTime2), N'')
GO
INSERT [dbo].[messages] ([id], [sender_id], [receiver_id], [product_id], [message], [is_read], [created_at], [content]) VALUES (5, 16, 7, 9, N'xin chào', 0, CAST(N'2026-03-15T15:59:58.0000000' AS DateTime2), N'')
GO
INSERT [dbo].[messages] ([id], [sender_id], [receiver_id], [product_id], [message], [is_read], [created_at], [content]) VALUES (6, 16, 7, 9, N'xin chào', 0, CAST(N'2026-03-15T16:01:09.0000000' AS DateTime2), N'')
GO
SET IDENTITY_INSERT [dbo].[messages] OFF
GO
SET IDENTITY_INSERT [dbo].[notifications] ON 
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (1, 5, N'Bai dang da duoc duyet', N'San pham iPhone 13 128GB cua ban da duoc duyet.', 0, CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (2, 6, N'Ban co danh gia moi', N'Khach hang vua gui danh gia cho giao dich cua ban.', 1, CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (3, 4, N'Bao cao moi', N'He thong vua nhan them bao cao vi pham can xu ly.', 1, CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (4, 6, N'Yeu cau mua moi', N'Co nguoi vua gui yeu cau mua san pham "MacBook Air M1".', 1, CAST(N'2026-03-11T16:54:44.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (5, 5, N'Yeu cau mua da duoc chap nhan', N'Nguoi ban da xac nhan giao dich cho san pham "MacBook Air M1".', 0, CAST(N'2026-03-11T16:55:57.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (6, 5, N'Yeu cau mua moi', N'Co nguoi vua gui yeu cau mua san pham "Test tao bang JSON".', 0, CAST(N'2026-03-11T17:04:26.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (7, 6, N'Yeu cau mua da duoc chap nhan', N'Nguoi ban da xac nhan giao dich cho san pham "Test tao bang JSON".', 0, CAST(N'2026-03-11T17:16:05.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (8, 4, N'Don mua da thanh toan', N'Nguoi mua da thanh toan cho san pham "iPhone 12 128GB #811656-1". Vui long xac nhan giao dich.', 0, CAST(N'2026-03-11T17:32:47.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (9, 4, N'Yeu cau mua moi', N'Co nguoi vua gui yeu cau mua san pham "Dell XPS 13 #811777-5".', 0, CAST(N'2026-03-11T17:34:29.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (1007, 6, N'Don mua da thanh toan', N'Nguoi mua da thanh toan cho san pham "AirPods Pro 2 #811811-7". Vui long xac nhan giao dich.', 0, CAST(N'2026-03-12T02:09:55.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (2007, 5, N'Yeu cau mua da duoc chap nhan', N'Nguoi ban da xac nhan giao dich cho san pham "Dell XPS 13 #811777-5".', 0, CAST(N'2026-03-15T09:30:38.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (2008, 5, N'Yeu cau mua da duoc chap nhan', N'Nguoi ban da xac nhan giao dich cho san pham "iPhone 12 128GB #811656-1".', 0, CAST(N'2026-03-15T09:30:39.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (2009, 6, N'Don mua da thanh toan', N'Nguoi mua da thanh toan cho san pham "Xiaomi 11T Pro #811720-3". Vui long xac nhan giao dich.', 1, CAST(N'2026-03-15T09:59:56.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (2010, 4, N'Yeu cau mua da duoc chap nhan', N'Nguoi ban da xac nhan giao dich cho san pham "Xiaomi 11T Pro #811720-3".', 0, CAST(N'2026-03-15T10:00:53.0000000' AS DateTime2))
GO
INSERT [dbo].[notifications] ([id], [user_id], [title], [content], [is_read], [created_at]) VALUES (2011, 7, N'Danh gia moi', N'Ban vua nhan duoc danh gia 5/5 cho san pham #9.', 0, CAST(N'2026-03-15T17:18:34.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[notifications] OFF
GO
SET IDENTITY_INSERT [dbo].[payments] ON 
GO
INSERT [dbo].[payments] ([id], [order_id], [amount], [payment_method], [status], [created_at]) VALUES (1, 3, CAST(150000.00 AS Decimal(12, 2)), N'VNPAY', N'released', CAST(N'2026-03-12T00:32:47.180' AS DateTime))
GO
INSERT [dbo].[payments] ([id], [order_id], [amount], [payment_method], [status], [created_at]) VALUES (2, NULL, CAST(320000.00 AS Decimal(12, 2)), N'BANK_TRANSFER', N'pending', CAST(N'2026-03-12T00:39:01.953' AS DateTime))
GO
INSERT [dbo].[payments] ([id], [order_id], [amount], [payment_method], [status], [created_at]) VALUES (10002, 1003, CAST(660000.00 AS Decimal(12, 2)), N'MOMO', N'paid', CAST(N'2026-03-12T09:09:49.817' AS DateTime))
GO
INSERT [dbo].[payments] ([id], [order_id], [amount], [payment_method], [status], [created_at]) VALUES (20002, NULL, CAST(320000.00 AS Decimal(12, 2)), N'BANK_TRANSFER', N'pending', CAST(N'2026-03-15T16:59:41.117' AS DateTime))
GO
INSERT [dbo].[payments] ([id], [order_id], [amount], [payment_method], [status], [created_at]) VALUES (20003, 2003, CAST(320000.00 AS Decimal(12, 2)), N'BANK_TRANSFER', N'released', CAST(N'2026-03-15T16:59:54.343' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[payments] OFF
GO
SET IDENTITY_INSERT [dbo].[product_images] ON 
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (4, 3, N'https://images.unsplash.com/photo-1510557880182-3c0f30ad4f2b?w=1200', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (5, 3, N'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=1200', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (6, 4, N'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=1200', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (7, 6, N'https://images.unsplash.com/photo-1510557880182-3c0f30ad4f2b?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (8, 6, N'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (9, 7, N'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (10, 7, N'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (11, 8, N'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (12, 8, N'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (13, 9, N'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (14, 9, N'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (15, 10, N'https://images.unsplash.com/photo-1518444065439-e933c06ce9cd?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (16, 10, N'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (17, 11, N'https://images.unsplash.com/photo-1486401899868-0e435ed85128?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (18, 11, N'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (19, 12, N'https://images.unsplash.com/photo-1510557880182-3c0f30ad4f2b?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (20, 12, N'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (21, 13, N'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (22, 13, N'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (23, 14, N'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (24, 14, N'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (25, 15, N'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (26, 15, N'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (27, 16, N'https://images.unsplash.com/photo-1518444065439-e933c06ce9cd?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (28, 16, N'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (29, 17, N'https://images.unsplash.com/photo-1486401899868-0e435ed85128?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (30, 17, N'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (31, 18, N'https://images.unsplash.com/photo-1510557880182-3c0f30ad4f2b?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (32, 18, N'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (33, 19, N'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (34, 19, N'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (35, 20, N'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (36, 20, N'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (37, 21, N'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (38, 21, N'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (39, 22, N'https://images.unsplash.com/photo-1518444065439-e933c06ce9cd?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (40, 22, N'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (41, 23, N'https://images.unsplash.com/photo-1486401899868-0e435ed85128?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (42, 23, N'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (43, 24, N'https://images.unsplash.com/photo-1510557880182-3c0f30ad4f2b?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (44, 24, N'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (45, 25, N'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (46, 25, N'https://images.unsplash.com/photo-1517336714739-489689fd1ca8?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (47, 26, N'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (48, 26, N'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (49, 27, N'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (50, 27, N'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (51, 28, N'https://images.unsplash.com/photo-1518444065439-e933c06ce9cd?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (52, 28, N'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (53, 29, N'https://images.unsplash.com/photo-1486401899868-0e435ed85128?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[product_images] ([id], [product_id], [image_url], [created_at]) VALUES (54, 29, N'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=1400', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[product_images] OFF
GO
SET IDENTITY_INSERT [dbo].[product_transactions] ON 
GO
INSERT [dbo].[product_transactions] ([id], [product_id], [buyer_id], [seller_id], [status], [created_at], [confirmed_at], [type], [payment_method], [payment_reference], [admin_id], [processed_at], [rejection_reason]) VALUES (2, 5, 6, 5, N'completed', CAST(N'2026-03-11T17:04:26.4648709' AS DateTime2), CAST(N'2026-03-11T17:16:05.3048205' AS DateTime2), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[product_transactions] ([id], [product_id], [buyer_id], [seller_id], [status], [created_at], [confirmed_at], [type], [payment_method], [payment_reference], [admin_id], [processed_at], [rejection_reason]) VALUES (3, 6, 5, 4, N'completed', CAST(N'2026-03-11T17:32:47.2409679' AS DateTime2), CAST(N'2026-03-15T09:30:39.3951447' AS DateTime2), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[product_transactions] ([id], [product_id], [buyer_id], [seller_id], [status], [created_at], [confirmed_at], [type], [payment_method], [payment_reference], [admin_id], [processed_at], [rejection_reason]) VALUES (4, 10, 5, 4, N'completed', CAST(N'2026-03-11T17:34:28.8368261' AS DateTime2), CAST(N'2026-03-15T09:30:37.6828270' AS DateTime2), NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[product_transactions] ([id], [product_id], [buyer_id], [seller_id], [status], [created_at], [confirmed_at], [type], [payment_method], [payment_reference], [admin_id], [processed_at], [rejection_reason]) VALUES (1003, 12, 5, 6, N'pending', CAST(N'2026-03-12T02:09:54.5363691' AS DateTime2), NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[product_transactions] ([id], [product_id], [buyer_id], [seller_id], [status], [created_at], [confirmed_at], [type], [payment_method], [payment_reference], [admin_id], [processed_at], [rejection_reason]) VALUES (2003, 8, 4, 6, N'completed', CAST(N'2026-03-15T09:59:55.9494425' AS DateTime2), CAST(N'2026-03-15T10:00:53.2703072' AS DateTime2), NULL, NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[product_transactions] OFF
GO
SET IDENTITY_INSERT [dbo].[products] ON 
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (3, 5, 1, N'iPhone 13 128GB', N'May dep 99%, pin 88%, full box', CAST(11500000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2), CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (4, 6, 2, N'MacBook Air M1', N'RAM 8GB SSD 256GB, ngoai hinh dep', CAST(15500000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2), CAST(N'2026-03-11T17:01:41.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (5, 5, 1, N'Test tao bang JSON', N'San pham tao de test API dang bai sau khi sua upload web', CAST(123456.00 AS Decimal(18, 2)), N'sold', CAST(N'2026-03-11T15:57:03.0000000' AS DateTime2), CAST(N'2026-03-11T17:16:05.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (6, 4, 4, N'iPhone 12 128GB #811656-1', N'Used carefully, all functions work well, minor scratches only.', CAST(150000.00 AS Decimal(18, 2)), N'sold', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-15T09:30:39.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (7, 5, 5, N'Samsung Galaxy S21 #811695-2', N'Good condition, battery and screen are stable, includes charger.', CAST(235000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (8, 6, 6, N'Xiaomi 11T Pro #811720-3', N'Selling because of upgrade, device has been factory reset.', CAST(320000.00 AS Decimal(18, 2)), N'sold', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-15T10:00:53.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (9, 7, 7, N'MacBook Pro 2019 #811749-4', N'Works perfectly, no repair history, can test before buying.', CAST(405000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (10, 4, 8, N'Dell XPS 13 #811777-5', N'Price is negotiable for quick deal, serious buyers only.', CAST(490000.00 AS Decimal(18, 2)), N'sold', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-15T09:30:38.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (11, 5, 9, N'HP Envy 14 #811797-6', N'Used carefully, all functions work well, minor scratches only.', CAST(575000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (12, 6, 10, N'AirPods Pro 2 #811811-7', N'Good condition, battery and screen are stable, includes charger.', CAST(660000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (13, 7, 1, N'Sony WH-1000XM4 #811824-8', N'Selling because of upgrade, device has been factory reset.', CAST(745000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (14, 4, 2, N'Mechanical Keyboard #811837-9', N'Works perfectly, no repair history, can test before buying.', CAST(830000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (15, 5, 3, N'Gaming Mouse #811850-10', N'Price is negotiable for quick deal, serious buyers only.', CAST(915000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (16, 6, 4, N'Road Bike Giant #811864-11', N'Used carefully, all functions work well, minor scratches only.', CAST(1000000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (17, 7, 5, N'Honda Vision 2021 #811878-12', N'Good condition, battery and screen are stable, includes charger.', CAST(1085000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (18, 4, 6, N'Levis Denim Jacket #811889-13', N'Selling because of upgrade, device has been factory reset.', CAST(1170000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (19, 5, 7, N'Nike Air Force 1 #811916-14', N'Works perfectly, no repair history, can test before buying.', CAST(1255000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (20, 6, 8, N'Wooden Study Desk #811955-15', N'Price is negotiable for quick deal, serious buyers only.', CAST(1340000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (21, 7, 9, N'Ergonomic Chair #811983-16', N'Used carefully, all functions work well, minor scratches only.', CAST(1425000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (22, 4, 10, N'Clean Code Book Set #811996-17', N'Good condition, battery and screen are stable, includes charger.', CAST(1510000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (23, 5, 1, N'Nintendo Switch Lite #812010-18', N'Selling because of upgrade, device has been factory reset.', CAST(1595000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (24, 6, 2, N'PS4 Slim 500GB #812024-19', N'Works perfectly, no repair history, can test before buying.', CAST(1680000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (25, 7, 3, N'Blender Philips #812038-20', N'Price is negotiable for quick deal, serious buyers only.', CAST(1765000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (26, 4, 4, N'Rice Cooker Sharp #812052-21', N'Used carefully, all functions work well, minor scratches only.', CAST(1850000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (27, 5, 5, N'Coffee Maker Delonghi #812064-22', N'Good condition, battery and screen are stable, includes charger.', CAST(1935000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (28, 6, 6, N'Canon EOS M50 #812074-23', N'Selling because of upgrade, device has been factory reset.', CAST(2020000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
INSERT [dbo].[products] ([id], [user_id], [category_id], [title], [description], [price], [status], [created_at], [updated_at]) VALUES (29, 7, 7, N'GoPro Hero 9 #812082-24', N'Works perfectly, no repair history, can test before buying.', CAST(2105000.00 AS Decimal(18, 2)), N'approved', CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2), CAST(N'2026-03-11T17:06:52.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[products] OFF
GO
SET IDENTITY_INSERT [dbo].[reports] ON 
GO
INSERT [dbo].[reports] ([id], [product_id], [reporter_id], [reason], [status], [created_at]) VALUES (1, 3, 6, N'Nghi ngo thong tin chua day du', N'pending', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[reports] ([id], [product_id], [reporter_id], [reason], [status], [created_at]) VALUES (2, 4, 5, N'Can admin kiem tra them hinh anh', N'reviewing', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[reports] ([id], [product_id], [reporter_id], [reason], [status], [created_at]) VALUES (3, 3, 5, N'Test report tu API moi', N'pending', CAST(N'2026-03-11T13:47:25.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[reports] OFF
GO
SET IDENTITY_INSERT [dbo].[reviews] ON 
GO
INSERT [dbo].[reviews] ([id], [product_id], [reviewer_id], [seller_id], [rating], [comment], [created_at]) VALUES (3, 4, 5, 6, 5, N'Nguoi ban nhiet tinh, san pham dung mo ta', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[reviews] ([id], [product_id], [reviewer_id], [seller_id], [rating], [comment], [created_at]) VALUES (4, 3, 6, 5, 4, N'Giao dich nhanh, may dung on', CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2))
GO
INSERT [dbo].[reviews] ([id], [product_id], [reviewer_id], [seller_id], [rating], [comment], [created_at]) VALUES (5, 9, 16, 7, 5, N'hay quá', CAST(N'2026-03-15T17:18:34.0000000' AS DateTime2))
GO
SET IDENTITY_INSERT [dbo].[reviews] OFF
GO
SET IDENTITY_INSERT [dbo].[system_settings] ON 
GO
INSERT [dbo].[system_settings] ([setting_id], [setting_key], [setting_value], [setting_type], [description], [is_public], [updated_by], [updated_at]) VALUES (1, N'min_withdrawal_amount', N'50000', N'NUMBER', N'Minimum withdrawal amount', 1, NULL, CAST(N'2026-03-15T17:25:54.720' AS DateTime))
GO
INSERT [dbo].[system_settings] ([setting_id], [setting_key], [setting_value], [setting_type], [description], [is_public], [updated_by], [updated_at]) VALUES (2, N'max_withdrawal_amount', N'5000000', N'NUMBER', N'Maximum withdrawal amount', 1, NULL, CAST(N'2026-03-15T17:25:54.720' AS DateTime))
GO
INSERT [dbo].[system_settings] ([setting_id], [setting_key], [setting_value], [setting_type], [description], [is_public], [updated_by], [updated_at]) VALUES (3, N'withdrawal_fee_percent', N'2', N'NUMBER', N'Withdrawal fee percentage', 1, NULL, CAST(N'2026-03-15T17:25:54.720' AS DateTime))
GO
INSERT [dbo].[system_settings] ([setting_id], [setting_key], [setting_value], [setting_type], [description], [is_public], [updated_by], [updated_at]) VALUES (4, N'auto_complete_days', N'7', N'NUMBER', N'Days to auto-complete orders', 0, NULL, CAST(N'2026-03-15T17:25:54.720' AS DateTime))
GO
INSERT [dbo].[system_settings] ([setting_id], [setting_key], [setting_value], [setting_type], [description], [is_public], [updated_by], [updated_at]) VALUES (5, N'maintenance_mode', N'false', N'BOOLEAN', N'System maintenance mode', 1, NULL, CAST(N'2026-03-15T17:25:54.720' AS DateTime))
GO
INSERT [dbo].[system_settings] ([setting_id], [setting_key], [setting_value], [setting_type], [description], [is_public], [updated_by], [updated_at]) VALUES (6, N'app_version', N'1.0.0', N'STRING', N'Current app version', 1, NULL, CAST(N'2026-03-15T17:25:54.720' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[system_settings] OFF
GO
SET IDENTITY_INSERT [dbo].[transactions] ON 
GO
INSERT [dbo].[transactions] ([transaction_id], [order_id], [user_id], [amount], [type], [status], [payment_method], [payment_reference], [product_name], [from_user_name], [to_user_name], [admin_id], [processed_at], [rejection_reason], [created_at]) VALUES (1, NULL, 16, CAST(200000.00 AS Decimal(15, 2)), N'TOPUP', N'SUCCESS', N'BANK_TRANSFER', NULL, N'Top Up', N'System', N'User', NULL, CAST(N'2026-03-16T00:12:39.220' AS DateTime), NULL, CAST(N'2026-03-16T00:12:39.220' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[transactions] OFF
GO
SET IDENTITY_INSERT [dbo].[user_bank_accounts] ON 
GO
INSERT [dbo].[user_bank_accounts] ([id], [user_id], [bank_id], [account_number], [account_name], [created_at]) VALUES (1, 5, 4, N'123456789', N'NGUYEN VAN A', CAST(N'2026-03-12T00:32:36.610' AS DateTime))
GO
INSERT [dbo].[user_bank_accounts] ([id], [user_id], [bank_id], [account_number], [account_name], [created_at]) VALUES (2, 6, 4, N'222233334444', N'SELLER TEST', CAST(N'2026-03-12T00:39:01.893' AS DateTime))
GO
INSERT [dbo].[user_bank_accounts] ([id], [user_id], [bank_id], [account_number], [account_name], [created_at]) VALUES (10002, 16, 4, N'90812309123123', N'thachhoangdu', CAST(N'2026-03-16T00:02:53.463' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[user_bank_accounts] OFF
GO
SET IDENTITY_INSERT [dbo].[users] ON 
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (4, N'Admin', N'admin@secondhand.local', N'123456', N'0900000000', N'Thành phố Cần Thơ', N'admin', NULL, CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2), CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (5, N'Nguyen Van A', N'user1@secondhand.local', N'123456', N'0911111111', N'Thành phố Cần Thơ', N'user', NULL, CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2), CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (6, N'Le Thi B', N'user2@secondhand.local', N'123456', N'0922222222', N'Thành phố Cần Thơ', N'user', NULL, CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2), CAST(N'2026-03-11T13:40:30.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (7, N'Firebase Test', N'verify_960d2812@secondhand.local', N'$2a$10$oIxNhiiw3wqnCrxbq43w9.wywd.qJHcB68QX.2Uq2xLSloi0J8IVq', N'0999999999', NULL, N'user', NULL, CAST(N'2026-03-11T15:28:21.0000000' AS DateTime2), CAST(N'2026-03-11T15:28:21.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (8, N'thachhoangdu', N'thachhoangdu07@gmail.com', N'$2a$10$f7eywO4gdzzgvcdLNlpsh.LmLnyrcDGIpsezaxSm.hAaPj0nXFQd6', N'0966411411', NULL, N'user', NULL, CAST(N'2026-03-14T11:36:54.0000000' AS DateTime2), CAST(N'2026-03-14T11:36:54.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (9, N'kriss', N'krisvalli944@gmail.com', N'$2a$10$kL7EAjzh8K2voRzntQElCuT5rJfl3lyjdvrMb1FApuD94k1ZqS06K', N'0921361234', NULL, N'user', NULL, CAST(N'2026-03-14T11:38:40.0000000' AS DateTime2), CAST(N'2026-03-14T11:38:40.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (10, N'dựh', N'krisvalli941@gmail.com', N'$2a$10$Muu1XfiLMc8sG0KYD9lFVuYF3rbZIa8RWxKczKLWP3vtdWZe1YlbS', N'09312863712', NULL, N'user', NULL, CAST(N'2026-03-14T12:17:36.0000000' AS DateTime2), CAST(N'2026-03-14T12:17:36.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (11, N'ádasd', N'thachhoangdu09@gmail.com', N'$2a$10$P7prAP8A10W7jyW/tXgXSOU6E93nghO6VZETLODaVDW5pQ3qvvuQ6', N'08231973', NULL, N'user', NULL, CAST(N'2026-03-14T12:20:11.0000000' AS DateTime2), CAST(N'2026-03-14T12:20:11.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (12, N'hpoangf', N'toankun1409@gmail.com', N'$2a$10$8Eo1WVy9s9oCKJ7GPofClunSh6RY5CqF7IXGLdPSLls0Haq3yh3bS', N'08931212371', NULL, N'user', NULL, CAST(N'2026-03-14T14:42:53.0000000' AS DateTime2), CAST(N'2026-03-14T14:42:53.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (13, N'HOANGDUI', N'hoangdu011i@gmail.com', N'$2a$10$PhNyNd1SvbQ2NjHAqgSVeOaq0YCWDLifZ6RkhNRjnyO3Vr8MjxU8G', N'2431234241', NULL, N'user', NULL, CAST(N'2026-03-15T08:19:17.0000000' AS DateTime2), CAST(N'2026-03-15T08:19:17.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (14, N'hopangd', N'hoangdu01i@gmail.com', N'$2a$10$Jr9TfNJoYReVaNFjff9stOnI2BOj5hW6dzRiGLiOHvdTCh3q9otMG', N'0966477511', NULL, N'user', NULL, CAST(N'2026-03-15T08:55:33.0000000' AS DateTime2), CAST(N'2026-03-15T08:55:33.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (15, N'honagdu', N'quenrmk944@gmail.com', N'$2a$10$lecbjySIdKp7TQ9p99BmJu7uDT0D2h2c3qmgC.3o2R/9N6odlP7k2', N'091236312', NULL, N'user', NULL, CAST(N'2026-03-15T09:00:29.0000000' AS DateTime2), CAST(N'2026-03-15T09:00:29.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[users] ([id], [name], [email], [password], [phone], [address], [role], [avatar], [created_at], [updated_at], [wallet_balance], [pending_balance]) VALUES (16, N'duy', N'duy22@gmail.com', N'$2a$10$8ZI5AizZFoF7prJCv5KizuDphBieA8azYHPrzJmunO.uGWbhzt.1m', N'098831231', N'Thành phố Cần Thơ', N'user', NULL, CAST(N'2026-03-15T15:36:00.0000000' AS DateTime2), CAST(N'2026-03-15T15:36:00.0000000' AS DateTime2), CAST(200000.00 AS Decimal(15, 2)), CAST(0.00 AS Decimal(15, 2)))
GO
SET IDENTITY_INSERT [dbo].[users] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__admin_ro__783254B1B4E323EC]    Script Date: 3/18/2026 12:57:14 AM ******/
ALTER TABLE [dbo].[admin_roles] ADD UNIQUE NONCLUSTERED 
(
	[role_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__admin_us__B9BE370EBA2185FD]    Script Date: 3/18/2026 12:57:14 AM ******/
ALTER TABLE [dbo].[admin_users] ADD UNIQUE NONCLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_categories_name]    Script Date: 3/18/2026 12:57:14 AM ******/
ALTER TABLE [dbo].[categories] ADD  CONSTRAINT [UQ_categories_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__disputes__46596228C50D698A]    Script Date: 3/18/2026 12:57:14 AM ******/
ALTER TABLE [dbo].[disputes] ADD UNIQUE NONCLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_favorites_user_product]    Script Date: 3/18/2026 12:57:14 AM ******/
ALTER TABLE [dbo].[favorites] ADD  CONSTRAINT [UQ_favorites_user_product] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__payment___46596228E7AE42AE]    Script Date: 3/18/2026 12:57:14 AM ******/
ALTER TABLE [dbo].[payment_holding] ADD UNIQUE NONCLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__system_s__0DFAC427D72B6B50]    Script Date: 3/18/2026 12:57:14 AM ******/
ALTER TABLE [dbo].[system_settings] ADD UNIQUE NONCLUSTERED 
(
	[setting_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_users_email]    Script Date: 3/18/2026 12:57:14 AM ******/
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [UQ_users_email] UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[admin_roles] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[admin_users] ADD  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[admin_users] ADD  DEFAULT (getdate()) FOR [assigned_at]
GO
ALTER TABLE [dbo].[categories] ADD  CONSTRAINT [DF_categories_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[categories] ADD  CONSTRAINT [DF_categories_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[conversations] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[conversations] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[disputes] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[disputes] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[favorites] ADD  CONSTRAINT [DF_favorites_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[frozen_users] ADD  DEFAULT ('FROZEN') FOR [status]
GO
ALTER TABLE [dbo].[frozen_users] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[messages] ADD  CONSTRAINT [DF_messages_is_read]  DEFAULT ((0)) FOR [is_read]
GO
ALTER TABLE [dbo].[messages] ADD  CONSTRAINT [DF_messages_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[messages] ADD  DEFAULT ('') FOR [content]
GO
ALTER TABLE [dbo].[notifications] ADD  CONSTRAINT [DF_notifications_is_read]  DEFAULT ((0)) FOR [is_read]
GO
ALTER TABLE [dbo].[notifications] ADD  CONSTRAINT [DF_notifications_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT ((0.00)) FOR [shipping_fee]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT ((0)) FOR [is_disputed]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[payment_holding] ADD  DEFAULT ('HOLDING') FOR [status]
GO
ALTER TABLE [dbo].[payment_holding] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[payments] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[product_images] ADD  CONSTRAINT [DF_product_images_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[product_transactions] ADD  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[product_transactions] ADD  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[product_transactions] ADD  DEFAULT ('PAYMENT') FOR [type]
GO
ALTER TABLE [dbo].[products] ADD  CONSTRAINT [DF_products_status]  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[products] ADD  CONSTRAINT [DF_products_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[products] ADD  CONSTRAINT [DF_products_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[reports] ADD  CONSTRAINT [DF_reports_status]  DEFAULT ('pending') FOR [status]
GO
ALTER TABLE [dbo].[reports] ADD  CONSTRAINT [DF_reports_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[reviews] ADD  CONSTRAINT [DF_reviews_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[system_settings] ADD  DEFAULT ('STRING') FOR [setting_type]
GO
ALTER TABLE [dbo].[system_settings] ADD  DEFAULT ((0)) FOR [is_public]
GO
ALTER TABLE [dbo].[system_settings] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[transactions] ADD  DEFAULT ('PAYMENT') FOR [type]
GO
ALTER TABLE [dbo].[transactions] ADD  DEFAULT ('PENDING') FOR [status]
GO
ALTER TABLE [dbo].[transactions] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[user_bank_accounts] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_role]  DEFAULT ('user') FOR [role]
GO
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_created_at]  DEFAULT (sysutcdatetime()) FOR [created_at]
GO
ALTER TABLE [dbo].[users] ADD  CONSTRAINT [DF_users_updated_at]  DEFAULT (sysutcdatetime()) FOR [updated_at]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ((0.00)) FOR [wallet_balance]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ((0.00)) FOR [pending_balance]
GO
ALTER TABLE [dbo].[admin_users]  WITH CHECK ADD FOREIGN KEY([assigned_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[admin_users]  WITH CHECK ADD FOREIGN KEY([role_id])
REFERENCES [dbo].[admin_roles] ([role_id])
GO
ALTER TABLE [dbo].[admin_users]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[conversations]  WITH CHECK ADD FOREIGN KEY([buyer_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[conversations]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
GO
ALTER TABLE [dbo].[conversations]  WITH CHECK ADD FOREIGN KEY([seller_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[disputes]  WITH CHECK ADD FOREIGN KEY([admin_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[disputes]  WITH CHECK ADD FOREIGN KEY([complainant_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[disputes]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([order_id])
GO
ALTER TABLE [dbo].[disputes]  WITH CHECK ADD FOREIGN KEY([respondent_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[favorites]  WITH CHECK ADD  CONSTRAINT [FK_favorites_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[favorites] CHECK CONSTRAINT [FK_favorites_product]
GO
ALTER TABLE [dbo].[favorites]  WITH CHECK ADD  CONSTRAINT [FK_favorites_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[favorites] CHECK CONSTRAINT [FK_favorites_user]
GO
ALTER TABLE [dbo].[frozen_users]  WITH CHECK ADD FOREIGN KEY([admin_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[frozen_users]  WITH CHECK ADD FOREIGN KEY([unfreeze_admin_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[frozen_users]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[messages]  WITH CHECK ADD  CONSTRAINT [FK_messages_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[messages] CHECK CONSTRAINT [FK_messages_product]
GO
ALTER TABLE [dbo].[messages]  WITH CHECK ADD  CONSTRAINT [FK_messages_receiver] FOREIGN KEY([receiver_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[messages] CHECK CONSTRAINT [FK_messages_receiver]
GO
ALTER TABLE [dbo].[messages]  WITH CHECK ADD  CONSTRAINT [FK_messages_sender] FOREIGN KEY([sender_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[messages] CHECK CONSTRAINT [FK_messages_sender]
GO
ALTER TABLE [dbo].[notifications]  WITH CHECK ADD  CONSTRAINT [FK_notifications_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[notifications] CHECK CONSTRAINT [FK_notifications_user]
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD FOREIGN KEY([buyer_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD FOREIGN KEY([seller_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[payment_holding]  WITH CHECK ADD FOREIGN KEY([buyer_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[payment_holding]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([order_id])
GO
ALTER TABLE [dbo].[payment_holding]  WITH CHECK ADD FOREIGN KEY([seller_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[product_images]  WITH CHECK ADD  CONSTRAINT [FK_product_images_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[product_images] CHECK CONSTRAINT [FK_product_images_product]
GO
ALTER TABLE [dbo].[product_transactions]  WITH CHECK ADD  CONSTRAINT [FK_transactions_admin] FOREIGN KEY([admin_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[product_transactions] CHECK CONSTRAINT [FK_transactions_admin]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [FK_products_category] FOREIGN KEY([category_id])
REFERENCES [dbo].[categories] ([id])
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [FK_products_category]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [FK_products_user] FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [FK_products_user]
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD  CONSTRAINT [FK_reports_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
GO
ALTER TABLE [dbo].[reports] CHECK CONSTRAINT [FK_reports_product]
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD  CONSTRAINT [FK_reports_reporter] FOREIGN KEY([reporter_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[reports] CHECK CONSTRAINT [FK_reports_reporter]
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD  CONSTRAINT [FK_reviews_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[products] ([id])
GO
ALTER TABLE [dbo].[reviews] CHECK CONSTRAINT [FK_reviews_product]
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD  CONSTRAINT [FK_reviews_reviewer] FOREIGN KEY([reviewer_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[reviews] CHECK CONSTRAINT [FK_reviews_reviewer]
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD  CONSTRAINT [FK_reviews_seller] FOREIGN KEY([seller_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[reviews] CHECK CONSTRAINT [FK_reviews_seller]
GO
ALTER TABLE [dbo].[system_settings]  WITH CHECK ADD FOREIGN KEY([updated_by])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[transactions]  WITH CHECK ADD FOREIGN KEY([admin_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[transactions]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([order_id])
GO
ALTER TABLE [dbo].[transactions]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[user_bank_accounts]  WITH CHECK ADD FOREIGN KEY([bank_id])
REFERENCES [dbo].[banks] ([id])
GO
ALTER TABLE [dbo].[user_bank_accounts]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([id])
GO
ALTER TABLE [dbo].[messages]  WITH CHECK ADD  CONSTRAINT [CK_messages_sender_receiver] CHECK  (([sender_id]<>[receiver_id]))
GO
ALTER TABLE [dbo].[messages] CHECK CONSTRAINT [CK_messages_sender_receiver]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [CK_products_price] CHECK  (([price]>=(0)))
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [CK_products_price]
GO
ALTER TABLE [dbo].[products]  WITH CHECK ADD  CONSTRAINT [CK_products_status] CHECK  (([status]='sold' OR [status]='rejected' OR [status]='approved' OR [status]='pending'))
GO
ALTER TABLE [dbo].[products] CHECK CONSTRAINT [CK_products_status]
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD  CONSTRAINT [CK_reports_status] CHECK  (([status]='rejected' OR [status]='resolved' OR [status]='reviewing' OR [status]='pending'))
GO
ALTER TABLE [dbo].[reports] CHECK CONSTRAINT [CK_reports_status]
GO
ALTER TABLE [dbo].[reviews]  WITH CHECK ADD  CONSTRAINT [CK_reviews_rating] CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[reviews] CHECK CONSTRAINT [CK_reviews_rating]
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD  CONSTRAINT [CK_users_role] CHECK  (([role]='admin' OR [role]='user'))
GO
ALTER TABLE [dbo].[users] CHECK CONSTRAINT [CK_users_role]
GO
