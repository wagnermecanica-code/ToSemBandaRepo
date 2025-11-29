import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Repository interface para Messages/Chat (domain layer)
abstract class MessagesRepository {
  /// Lista conversas de um perfil específico
  /// Ordena por lastMessageTimestamp descendente
  /// Suporta paginação (limit + startAfter)
  Future<List<ConversationEntity>> getConversations({
    required String profileId,
    int limit = 20,
    ConversationEntity? startAfter,
  });

  /// Busca uma conversa específica por ID
  Future<ConversationEntity?> getConversationById(String conversationId);

  /// Busca ou cria conversa entre dois perfis
  /// Se já existe, retorna a existente
  /// Se não existe, cria nova
  Future<ConversationEntity> getOrCreateConversation({
    required String currentProfileId,
    required String otherProfileId,
    required String currentUid,
    required String otherUid,
  });

  /// Lista mensagens de uma conversa
  /// Ordena por timestamp descendente (mais recentes primeiro)
  /// Suporta paginação (limit + startAfter)
  Future<List<MessageEntity>> getMessages({
    required String conversationId,
    int limit = 20,
    MessageEntity? startAfter,
  });

  /// Envia mensagem de texto
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderProfileId,
    required String text,
    MessageReplyEntity? replyTo,
  });

  /// Envia mensagem com imagem
  Future<MessageEntity> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String senderProfileId,
    required String imageUrl,
    String text = '',
    MessageReplyEntity? replyTo,
  });

  /// Marca mensagens como lidas
  /// Atualiza unreadCount no conversation doc
  Future<void> markAsRead({
    required String conversationId,
    required String profileId,
  });

  /// Marca conversa como não lida (swipe action)
  /// Incrementa unreadCount manualmente
  Future<void> markAsUnread({
    required String conversationId,
    required String profileId,
  });

  /// Deleta uma conversa (swipe action com confirmação)
  /// Remove apenas para o perfil atual (não deleta para o outro)
  Future<void> deleteConversation({
    required String conversationId,
    required String profileId,
  });

  /// Conta mensagens não lidas para um perfil
  /// Soma unreadCount de todas as conversas
  Future<int> getUnreadMessageCount(String profileId);

  /// Stream de conversas (real-time updates)
  Stream<List<ConversationEntity>> watchConversations(String profileId);

  /// Stream de mensagens de uma conversa (real-time updates)
  Stream<List<MessageEntity>> watchMessages(String conversationId);

  /// Stream de unread count (real-time badge counter)
  Stream<int> watchUnreadCount(String profileId);
}
