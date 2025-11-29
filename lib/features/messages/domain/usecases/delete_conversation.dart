import '../repositories/messages_repository.dart';

class DeleteConversation {
  final MessagesRepository _repository;
  DeleteConversation(this._repository);

  Future<void> call({
    required String conversationId,
    required String profileId,
  }) async {
    await _repository.deleteConversation(
      conversationId: conversationId,
      profileId: profileId,
    );
  }
}
