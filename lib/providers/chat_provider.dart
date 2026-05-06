import 'package:flutter/material.dart';
import 'package:secondhand_app/models/message_model.dart';
import 'package:secondhand_app/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  // Add completion tracking
  bool _isConversationsLoading = false;
  bool _isMessagesLoading = false;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> loadConversations() async {
    if (_isConversationsLoading) return; // Prevent multiple calls
    
    _isConversationsLoading = true;
    _isLoading = true;
    notifyListeners();
    
    try {
      _conversations = await _service.getConversations();
      print('Loaded conversations: ${_conversations.length}');
    } catch (e) {
      print('Error loading conversations: $e');
      // Don't re-throw to prevent Future already completed
    } finally {
      _isConversationsLoading = false;
      _isLoading = false;
      // Use Future.microtask to avoid notifyListeners during build
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> loadMessages(int receiverId, int productId) async {
    if (_isMessagesLoading) return; // Prevent multiple calls
    
    _isMessagesLoading = true;
    _isLoading = true;
    _messages = [];
    notifyListeners();
    
    try {
      _messages = await _service.getMessages(receiverId, productId);
      print('Loaded messages: ${_messages.length}');
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      _isMessagesLoading = false;
      _isLoading = false;
      // Use Future.microtask to avoid notifyListeners during build
      Future.microtask(() => notifyListeners());
    }
  }

  Future<bool> sendMessage({
    required int receiverId,
    required int productId,
    required String message,
  }) async {
    try {
      final newMsg = await _service.sendMessage(
        receiverId: receiverId,
        productId: productId,
        message: message,
      );
      _messages.add(newMsg);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
