import '../entities/conversation_entity.dart';
import '../repositories/messages_repository.dart';

class LoadConversations {
  final MessagesRepository _repository;
  LoadConversations(this._repository);

  Future<List<ConversationEntity>> call({
    required String profileId,
    int limit = 20,
    ConversationEntity? startAfter,
  }) async {
    return await _repository.getConversations(
      profileId: profileId,
      limit: limit,
      startAfter: startAfter,
    );
  }
}
