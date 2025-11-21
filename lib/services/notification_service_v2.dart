import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'active_profile_notifier.dart';


/// Serviço de notificações refatorado para Instagram-Style Architecture
/// 
/// CRÍTICO: Todas as notificações são isoladas por profileId
/// - Usa ActiveProfileNotifier para determinar perfil ativo
/// - Stream automático reage a mudanças de perfil
/// - Zero vazamento entre perfis
class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ActiveProfileNotifier _profileNotifier = ActiveProfileNotifier();

  /// Cria uma notificação para um profileId específico
  /// 
  /// [recipientProfileId] - ID do perfil que receberá a notificação (CRÍTICO)
  /// [type] - Tipo da notificação (interest, newMessage, etc.)
  /// [title] - Título da notificação
  /// [body] - Corpo/mensagem da notificação
  /// [data] - Dados adicionais (ex: postId, conversationId)
  /// [senderProfileId] - ID do perfil que enviou (opcional)
  static Future<void> create({
    required String recipientProfileId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
    String? senderProfileId,
  }) async {
    try {
      final now = DateTime.now();
      
      // Calcular expiração baseada no tipo
      final expiresAt = _getExpirationDate(type, now);
      
      final notificationData = {
        'type': type,
        'recipientProfileId': recipientProfileId,
        'senderProfileId': senderProfileId,
        'title': title,
        'body': body,
        'data': data,
        'read': false,
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
      };

      await _firestore.collection('notifications').add(notificationData);
      
      debugPrint('NotificationService: Notificação criada - type: $type, recipient: $recipientProfileId');
    } catch (e) {
      debugPrint('NotificationService: Erro ao criar notificação: $e');
      rethrow;
    }
  }

  /// Marca uma notificação como lida
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('NotificationService: Notificação marcada como lida: $notificationId');
    } catch (e) {
      debugPrint('NotificationService: Erro ao marcar como lida: $e');
      rethrow;
    }
  }

  /// Marca todas as notificações do perfil ativo como lidas
  static Future<void> markAllAsRead() async {
    try {
      final activeProfile = _profileNotifier.value;
      if (activeProfile == null) {
        debugPrint('NotificationService: Nenhum perfil ativo para marcar como lidas');
        return;
      }

      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('recipientProfileId', isEqualTo: activeProfile.profileId)
          .where('read', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      
      debugPrint('NotificationService: ${notifications.docs.length} notificações marcadas como lidas');
    } catch (e) {
      debugPrint('NotificationService: Erro ao marcar todas como lidas: $e');
      rethrow;
    }
  }

  /// Deleta uma notificação
  static Future<void> delete(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      
      debugPrint('NotificationService: Notificação deletada: $notificationId');
    } catch (e) {
      debugPrint('NotificationService: Erro ao deletar notificação: $e');
      rethrow;
    }
  }

  /// Stream de notificações do perfil ativo
  /// 
  /// OBRIGATÓRIO: Implementação conforme spec
  /// - Filtra por recipientProfileId do perfil ativo
  /// - Remove notificações expiradas
  /// - Ordena por createdAt (mais recentes primeiro)
  /// - Reage automaticamente a mudanças de perfil
  static Stream<List<AppNotification>> streamActiveProfileNotifications() {
    return _profileNotifier.stream.asyncMap((activeProfile) async {
      if (activeProfile == null) {
        debugPrint('NotificationService: Stream - Nenhum perfil ativo');
        return <AppNotification>[];
      }

      debugPrint('NotificationService: Stream - Carregando notificações para ${activeProfile.name} (${activeProfile.profileId})');

      try {
        // Query conforme spec:
        // WHERE recipientProfileId = activeProfile.id
        // WHERE expiresAt > now OR expiresAt is null
        // ORDER BY createdAt DESC
        
        final snapshot = await _firestore
            .collection('notifications')
            .where('recipientProfileId', isEqualTo: activeProfile.profileId)
            .orderBy('createdAt', descending: true)
            .limit(100) // Limite razoável
            .get();

        final notifications = snapshot.docs
            .map((doc) {
              try {
                return AppNotification.fromMap(doc.id, doc.data());
              } catch (e) {
                debugPrint('NotificationService: Erro ao parsear notificação ${doc.id}: $e');
                return null;
              }
            })
            .whereType<AppNotification>()
            .where((notif) {
              // Filtrar expiradas (client-side por enquanto)
              if (notif.expiresAt != null && notif.expiresAt!.isBefore(DateTime.now())) {
                return false;
              }
              return true;
            })
            .toList();

        debugPrint('NotificationService: ${notifications.length} notificações carregadas');
        return notifications;
      } catch (e) {
        debugPrint('NotificationService: Erro ao carregar notificações: $e');
        return <AppNotification>[];
      }
    }).asBroadcastStream();
  }

  /// Stream de contador de notificações não lidas do perfil ativo
  static Stream<int> streamUnreadCount() {
    return _profileNotifier.stream.asyncMap((activeProfile) async {
      if (activeProfile == null) return 0;

      try {
        final snapshot = await _firestore
            .collection('notifications')
            .where('recipientProfileId', isEqualTo: activeProfile.profileId)
            .where('read', isEqualTo: false)
            .get();

        // Filtrar expiradas
        final unreadCount = snapshot.docs.where((doc) {
          final expiresAt = doc.data()['expiresAt'] as Timestamp?;
          if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
            return false;
          }
          return true;
        }).length;

        return unreadCount;
      } catch (e) {
        debugPrint('NotificationService: Erro ao contar não lidas: $e');
        return 0;
      }
    }).asBroadcastStream();
  }

  /// Limpa notificações expiradas (executar periodicamente ou via Cloud Function)
  static Future<void> cleanExpiredNotifications() async {
    try {
      final now = Timestamp.now();
      final expired = await _firestore
          .collection('notifications')
          .where('expiresAt', isLessThan: now)
          .get();

      if (expired.docs.isEmpty) {
        debugPrint('NotificationService: Nenhuma notificação expirada encontrada');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in expired.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('NotificationService: ${expired.docs.length} notificações expiradas removidas');
    } catch (e) {
      debugPrint('NotificationService: Erro ao limpar notificações expiradas: $e');
      rethrow;
    }
  }

  // Métodos de conveniência para tipos específicos de notificações

  /// Cria notificação de interesse
  static Future<void> createInterestNotification({
    required String postId,
    required String postAuthorProfileId,
    required String postMessage,
  }) async {
    final activeProfile = _profileNotifier.value;
    if (activeProfile == null) {
      debugPrint('NotificationService: Nenhum perfil ativo para enviar interesse');
      return;
    }

    await create(
      recipientProfileId: postAuthorProfileId,
      type: 'interest',
      title: 'Novo interesse!',
      body: '${activeProfile.name} demonstrou interesse em seu post',
      data: {
        'postId': postId,
        'postMessage': postMessage,
        'senderName': activeProfile.name,
        'senderPhoto': activeProfile.photoUrl ?? '',
      },
      senderProfileId: activeProfile.profileId,
    );
  }

  /// Cria notificação de post próximo
  /// 
  /// NOTA: Este método é chamado pela Cloud Function, não pelo app
  /// Mantido aqui para documentação e eventual uso local
  static Future<void> createNearbyPostNotification({
    required String postId,
    required String recipientProfileId,
    required String postAuthorProfileId,
    required double distanceKm,
    required String city,
  }) async {
    await create(
      recipientProfileId: recipientProfileId,
      type: 'nearbyPost',
      title: 'Novo post próximo!',
      body: 'Um novo post foi criado a ${distanceKm.toStringAsFixed(1)} km de você em $city',
      data: {
        'postId': postId,
        'distance': distanceKm,
        'city': city,
      },
      senderProfileId: postAuthorProfileId,
    );
  }

  /// Cria notificação de nova mensagem
  static Future<void> createNewMessageNotification({
    required String conversationId,
    required String recipientProfileId,
    required String messagePreview,
  }) async {
    final activeProfile = _profileNotifier.value;
    if (activeProfile == null) {
      debugPrint('NotificationService: Nenhum perfil ativo para enviar mensagem');
      return;
    }

    // Verificar se já existe notificação não lida desta conversa (agregação)
    final existing = await _firestore
        .collection('notifications')
        .where('recipientProfileId', isEqualTo: recipientProfileId)
        .where('type', isEqualTo: 'newMessage')
        .where('data.conversationId', isEqualTo: conversationId)
        .where('read', isEqualTo: false)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Atualizar notificação existente
      await existing.docs.first.reference.update({
        'body': '${activeProfile.name} enviou uma mensagem: $messagePreview',
        'data.messagePreview': messagePreview,
        'data.messageCount': FieldValue.increment(1),
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('NotificationService: Notificação de mensagem atualizada (agregação)');
      return;
    }

    await create(
      recipientProfileId: recipientProfileId,
      type: 'newMessage',
      title: 'Nova mensagem',
      body: '${activeProfile.name} enviou: $messagePreview',
      data: {
        'conversationId': conversationId,
        'messagePreview': messagePreview,
        'messageCount': 1,
        'senderName': activeProfile.name,
        'senderPhoto': activeProfile.photoUrl ?? '',
      },
      senderProfileId: activeProfile.profileId,
    );
  }

  // Helper: Calcula data de expiração baseada no tipo
  static DateTime? _getExpirationDate(String type, DateTime createdAt) {
    switch (type) {
      case 'interest':
      case 'interestResponse':
        return createdAt.add(const Duration(days: 30));
      case 'newMessage':
      case 'nearbyPost':
      case 'postExpiring':
      case 'postUpdated':
      case 'profileView':
        return createdAt.add(const Duration(days: 7));
      case 'profileMatch':
        return createdAt.add(const Duration(days: 14));
      case 'system':
        return createdAt.add(const Duration(days: 90));
      default:
        return createdAt.add(const Duration(days: 30));
    }
  }

  /// Método de teste rápido
  static Future<void> testNotification() async {
    final activeProfile = _profileNotifier.value;
    if (activeProfile == null) {
      debugPrint('NotificationService: Nenhum perfil ativo para teste');
      return;
    }

    await create(
      recipientProfileId: activeProfile.profileId,
      type: 'system',
      title: '🧪 Notificação de Teste',
      body: 'Sistema de notificações funcionando perfeitamente!',
      data: {
        'test': true,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    debugPrint('NotificationService: Notificação de teste enviada para ${activeProfile.name}');
  }
}
