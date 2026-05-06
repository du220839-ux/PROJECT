import 'package:secondhand_app/models/user_model.dart';

class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final int productId;
  final String message;
  final DateTime createdAt;
  final UserModel? sender;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.productId,
    required this.message,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      message: json['message'] ?? json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      sender: json['sender'] != null ? UserModel.fromJson(json['sender']) : null,
    );
  }
}

class ConversationModel {
  final int userId;
  final int productId;
  final String productTitle;
  final String productImage;
  final String otherUserName;
  final String? otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      userId: json['other_user_id'] ?? 0,
      productId: json['id'] ?? 0,
      productTitle: json['product_title'] ?? '',
      productImage: '', // Backend doesn't provide image_url
      otherUserName: json['other_user_name'] ?? '',
      otherUserAvatar: json['other_user_avatar'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] != null 
          ? DateTime.parse(json['last_message_time']) 
          : DateTime.now(),
      unreadCount: 0, // Backend doesn't provide unread count
    );
  }
}
