import '../repositories/messages_repository.dart';

class MarkAsRead {
  final MessagesRepository _repository;
  MarkAsRead(this._repository);

  Future<void> call({
    required String conversationId,
    required String profileId,
  }) async {
    await _repository.markAsRead(
      conversationId: conversationId,
      profileId: profileId,
    );
  }
}
