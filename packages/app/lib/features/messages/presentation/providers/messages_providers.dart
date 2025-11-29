import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_ui/messages_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/providers/stream_provider.dart';
import 'package:wegig_app/features/messages/data/datasources/messages_remote_datasource.dart';
import 'package:wegig_app/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:core_ui/features/messages/domain/entities/conversation_entity.dart';
import 'package:core_ui/features/messages/domain/entities/message_entity.dart';
import 'package:wegig_app/features/messages/domain/repositories/messages_repository.dart';
import 'package:wegig_app/features/messages/domain/usecases/delete_conversation.dart';
import 'package:wegig_app/features/messages/domain/usecases/load_conversations.dart';
import 'package:wegig_app/features/messages/domain/usecases/load_messages.dart';
import 'package:wegig_app/features/messages/domain/usecases/mark_as_read.dart';
import 'package:wegig_app/features/messages/domain/usecases/mark_as_unread.dart';
import 'package:wegig_app/features/messages/domain/usecases/send_image.dart';
import 'package:wegig_app/features/messages/domain/usecases/send_message.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Provider para FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para MessagesRemoteDataSource
final messagesRemoteDataSourceProvider =
    Provider<IMessagesRemoteDataSource>((ref) {
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
final StreamProviderFamily<List<ConversationEntity>, String>
    conversationsStreamProvider =
    StreamProvider.family<List<ConversationEntity>, String>((ref, profileId) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return repository.watchConversations(profileId);
});

/// Stream de mensagens em tempo real
final StreamProviderFamily<List<MessageEntity>, String> messagesStreamProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, conversationId) {
  final repository = ref.watch(messagesRepositoryNewProvider);
  return repository.watchMessages(conversationId);
});

/// Stream de contador de não lidas para BottomNav badge
final StreamProviderFamily<int, String> unreadMessageCountForProfileProvider =
    StreamProvider.family<int, String>((ref, profileId) {
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

    return MessageSent(messageEntity);
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

    return MessageSent(messageEntity);
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
    return const MessagesSuccess(message: 'Marcado como lido');
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
    return const MessagesSuccess(message: 'Marcado como não lido');
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
    return const MessagesSuccess(message: 'Conversa deletada');
  } catch (e) {
    return MessagesFailure(message: e.toString());
  }
}
