import 'package:core_ui/features/messages/domain/entities/message_entity.dart';
import 'package:wegig_app/features/messages/domain/repositories/messages_repository.dart';

class SendMessage {
  SendMessage(this._repository);
  final MessagesRepository _repository;

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

    return _repository.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      senderProfileId: senderProfileId,
      text: text,
      replyTo: replyTo,
    );
  }
}
