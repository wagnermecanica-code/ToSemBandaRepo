import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/messages_repository.dart';
import '../../data/datasources/messages_remote_datasource.dart';
import '../../data/repositories/messages_repository_impl.dart';
import '../../domain/usecases/load_conversations.dart';
import '../../domain/usecases/load_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/send_image.dart';
import '../../domain/usecases/mark_as_read.dart';
import '../../domain/usecases/mark_as_unread.dart';
import '../../domain/usecases/delete_conversation.dart';
import '../../../../core/messages_result.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Provider para FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para MessagesRemoteDataSource
final messagesRemoteDataSourceProvider = Provider<IMessagesRemoteDataSource>((ref) {
  return MessagesRemoteDataSource();
});

/// Provider para MessagesRepository (nova implementação Clean Architecture)
final messagesRepositoryNewProvider = Provider<MessagesRepository>((ref) {
  final dataSource = ref.watch(messagesRemoteDataSourceProvider);
  return MessagesRepositoryImpl(remoteDataSource: dataSource);
});

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

final loadConversationsUseCaseProvider = Provider<LoadConversations>((ref) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return LoadConversations(repository);
});

final loadMessagesUseCaseProvider = Provider<LoadMessages>((ref) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return LoadMessages(repository);
});

final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return SendMessage(repository);
});

final sendImageUseCaseProvider = Provider<SendImage>((ref) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return SendImage(repository);
});

final markAsReadUseCaseProvider = Provider<MarkAsRead>((ref) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return MarkAsRead(repository);
});

final markAsUnreadUseCaseProvider = Provider<MarkAsUnread>((ref) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return MarkAsUnread(repository);
});

final deleteConversationUseCaseProvider = Provider<DeleteConversation>((ref) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return DeleteConversation(repository);
});

// ============================================================================
// STREAM PROVIDERS FOR REAL-TIME UPDATES
// ============================================================================

/// Stream de conversas em tempo real
final conversationsStreamProvider = StreamProvider.family<List<Conversation>, String>((ref, profileId) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return repository.watchConversations(profileId).map((entities) {
    return entities.map((entity) {
      return Conversation(
        id: entity.id,
        participants: entity.participants,
        participantProfiles: entity.participantProfiles,
        lastMessage: entity.lastMessage ?? '',
        lastMessageTimestamp: Timestamp.fromDate(entity.lastMessageTimestamp),
        unreadCount: entity.unreadCount,
        archived: entity.archived ?? false,
        createdAt: Timestamp.fromDate(entity.createdAt),
        updatedAt: entity.updatedAt != null ? Timestamp.fromDate(entity.updatedAt!) : null,
      );
    }).toList();
  });
});

/// Stream de mensagens em tempo real
final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, conversationId) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return repository.watchMessages(conversationId).map((entities) {
    return entities.map((entity) {
      return Message(
        messageId: entity.messageId,
        senderId: entity.senderId,
        senderProfileId: entity.senderProfileId,
        text: entity.text ?? '',
        imageUrl: entity.imageUrl,
        timestamp: Timestamp.fromDate(entity.timestamp),
        read: entity.read ?? false,
      );
    }).toList();
  });
});

/// Stream de contador de não lidas para BottomNav badge
final unreadMessageCountForProfileProvider = StreamProvider.family<int, String>((ref, profileId) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return repository.watchUnreadCount(profileId);
});

// ============================================================================
// HELPER FUNCTIONS FOR USE CASES
// ============================================================================

/// Envia uma mensagem de texto
Future<MessagesResult> sendTextMessage(
  WidgetRef ref, {
  required String conversationId,
  required String senderId,
  required String senderProfileId,
  required String text,
}) async {
  try {
    final useCase = ref.read(sendMessageUseCaseProvider);
    final messageEntity = await useCase(
      conversationId: conversationId,
      senderId: senderId,
      senderProfileId: senderProfileId,
      text: text,
    );

    final message = Message(
      messageId: messageEntity.messageId,
      senderId: messageEntity.senderId,
      senderProfileId: messageEntity.senderProfileId,
      text: messageEntity.text ?? '',
      imageUrl: messageEntity.imageUrl,
      timestamp: Timestamp.fromDate(messageEntity.timestamp),
      read: messageEntity.read ?? false,
    );

    return MessageSent(message);
  } catch (e) {
    return MessagesFailure(message: e.toString());
  }
}

/// Envia uma imagem
Future<MessagesResult> sendImageMessage(
  WidgetRef ref, {
  required String conversationId,
  required String senderId,
  required String senderProfileId,
  required String imageUrl,
  String? text,
}) async {
  try {
    final useCase = ref.read(sendImageUseCaseProvider);
    final messageEntity = await useCase(
      conversationId: conversationId,
      senderId: senderId,
      senderProfileId: senderProfileId,
      imageUrl: imageUrl,
      text: text ?? '',
    );

    final message = Message(
      messageId: messageEntity.messageId,
      senderId: messageEntity.senderId,
      senderProfileId: messageEntity.senderProfileId,
      text: messageEntity.text ?? '',
      imageUrl: messageEntity.imageUrl,
      timestamp: Timestamp.fromDate(messageEntity.timestamp),
      read: messageEntity.read ?? false,
    );

    return MessageSent(message);
  } catch (e) {
    return MessagesFailure(message: e.toString());
  }
}

/// Marca conversa como lida
Future<MessagesResult> markConversationAsRead(
  WidgetRef ref, {
  required String conversationId,
  required String profileId,
}) async {
  try {
    final useCase = ref.read(markAsReadUseCaseProvider);
    await useCase(
      conversationId: conversationId,
      profileId: profileId,
    );
    return MessagesSuccess(message: 'Marcado como lido');
  } catch (e) {
    return MessagesFailure(message: e.toString());
  }
}

/// Marca conversa como não lida (swipe right)
Future<MessagesResult> markConversationAsUnread(
  WidgetRef ref, {
  required String conversationId,
  required String profileId,
}) async {
  try {
    final useCase = ref.read(markAsUnreadUseCaseProvider);
    await useCase(
      conversationId: conversationId,
      profileId: profileId,
    );
    return MessagesSuccess(message: 'Marcado como não lido');
  } catch (e) {
    return MessagesFailure(message: e.toString());
  }
}

/// Deleta conversa (swipe left)
Future<MessagesResult> deleteConversationAction(
  WidgetRef ref, {
  required String conversationId,
  required String profileId,
}) async {
  try {
    final useCase = ref.read(deleteConversationUseCaseProvider);
    await useCase(
      conversationId: conversationId,
      profileId: profileId,
    );
    return MessagesSuccess(message: 'Conversa deletada');
  } catch (e) {
    return MessagesFailure(message: e.toString());
  }
}
