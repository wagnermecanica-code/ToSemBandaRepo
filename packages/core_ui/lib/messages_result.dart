import 'package:core_ui/features/messages/domain/entities/conversation_entity.dart';
import 'package:core_ui/features/messages/domain/entities/message_entity.dart';

/// Resultado type-safe para operações de messages
sealed class MessagesResult {
  const MessagesResult();
}

class MessagesSuccess extends MessagesResult {
  final String message;
  const MessagesSuccess({required this.message});
}

class ConversationLoaded extends MessagesResult {
  final ConversationEntity conversation;
  const ConversationLoaded(this.conversation);
}

class ConversationsLoaded extends MessagesResult {
  final List<ConversationEntity> conversations;
  const ConversationsLoaded(this.conversations);
}

class MessageSent extends MessagesResult {
  final MessageEntity message;
  const MessageSent(this.message);
}

class MessagesLoaded extends MessagesResult {
  final List<MessageEntity> messages;
  const MessagesLoaded(this.messages);
}

class MessagesFailure extends MessagesResult {
  final String message;
  final Exception? exception;
  const MessagesFailure({required this.message, this.exception});
}
