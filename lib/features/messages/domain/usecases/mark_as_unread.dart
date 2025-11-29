import '../repositories/messages_repository.dart';

class MarkAsUnread {
  final MessagesRepository _repository;
  MarkAsUnread(this._repository);

  Future<void> call({
    required String conversationId,
    required String profileId,
  }) async {
    await _repository.markAsUnread(
      conversationId: conversationId,
      profileId: profileId,
    );
  }
}
