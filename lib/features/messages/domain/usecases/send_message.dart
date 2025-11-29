import '../entities/message_entity.dart';
import '../repositories/messages_repository.dart';

class SendMessage {
  final MessagesRepository _repository;
  SendMessage(this._repository);

  Future<MessageEntity> call({
    required String conversationId,
    required String senderId,
    required String senderProfileId,
    required String text,
    MessageReplyEntity? replyTo,
  }) async {
    if (text.trim().isEmpty) {
      throw Exception('Mensagem não pode ser vazia');
    }
    
    return await _repository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderProfileId: senderProfileId,
      text: text,
      replyTo: replyTo,
    );
  }
}
