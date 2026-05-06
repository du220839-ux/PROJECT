import 'package:secondhand_app/models/message_model.dart';
import 'package:secondhand_app/services/api_service.dart';

class ChatService {
  final ApiService _api = ApiService();

  Future<List<ConversationModel>> getConversations() async {
    final response = await _api.get('/conversations');
    final List data = response.data['data'] ?? response.data['conversations'] ?? [];
    return data.map((e) => ConversationModel.fromJson(e)).toList();
  }

  Future<List<MessageModel>> getMessages(int receiverId, int productId, {int page = 1}) async {
    final response = await _api.get(
      '/messages',
      params: {'receiver_id': receiverId, 'product_id': productId, 'page': page},
    );
    final List data = response.data['messages'] ?? response.data['data'] ?? [];
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<MessageModel> sendMessage({
    required int receiverId,
    required int productId,
    required String message,
  }) async {
    final response = await _api.post('/messages', data: {
      'receiver_id': receiverId,
      'product_id': productId,
      'message': message,
    });
    return MessageModel.fromJson(response.data['message'] ?? response.data);
  }
}
