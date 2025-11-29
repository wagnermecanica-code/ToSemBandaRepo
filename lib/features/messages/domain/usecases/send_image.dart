import '../entities/message_entity.dart';
import '../repositories/messages_repository.dart';

class SendImage {
  final MessagesRepository _repository;
  SendImage(this._repository);

  Future<MessageEntity> call({
    required String conversationId,
    required String senderId,
    required String senderProfileId,
    required String imageUrl,
    String text = '',
    MessageReplyEntity? replyTo,
  }) async {
    if (imageUrl.trim().isEmpty) {
      throw Exception('URL da imagem é obrigatória');
    }
    
    return await _repository.sendImageMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderProfileId: senderProfileId,
      imageUrl: imageUrl,
      text: text,
      replyTo: replyTo,
    );
  }
}
