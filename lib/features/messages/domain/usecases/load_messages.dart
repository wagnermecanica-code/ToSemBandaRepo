import '../entities/message_entity.dart';
import '../repositories/messages_repository.dart';

class LoadMessages {
  final MessagesRepository _repository;
  LoadMessages(this._repository);

  Future<List<MessageEntity>> call({
    required String conversationId,
    int limit = 20,
    MessageEntity? startAfter,
  }) async {
    return await _repository.getMessages(
      conversationId: conversationId,
      limit: limit,
      startAfter: startAfter,
    );
  }
}
