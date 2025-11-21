import '../models/conversation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IConversationRepository {
  Future<List<Conversation>> getConversations();
}

class ConversationRepository implements IConversationRepository {
  @override
  Future<List<Conversation>> getConversations() async {
    // TODO: Implement Firestore query
    throw UnimplementedError();
  }
}

final conversationRepositoryProvider = Provider<IConversationRepository>((ref) {
  return ConversationRepository();
});
