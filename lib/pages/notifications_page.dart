import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'view_profile_page.dart';

/// Tela de notificações
/// Exibe interesses demonstrados em posts do usuário e outras notificações
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  StreamSubscription? _notificationsSubscription;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  late TabController _tabController;

  // Paleta de cores
  static final Color _primaryColor = AppColors.primary;
  static final Color _secondaryColor = AppColors.accent;
  static const Color _backgroundColor = Color(0xFFF5F5F5);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _textSecondary = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  /// Carrega notificações do Firestore em tempo real
  void _loadNotifications() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Buscar profileId ativo do usuário atual
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    if (!userDoc.exists) {
      setState(() => _isLoading = false);
      return;
    }
    
    final currentProfileId = userDoc.data()?['activeProfileId'] as String? ?? currentUser.uid;

    // Query para buscar interesses nos posts do perfil ativo
    _notificationsSubscription = FirebaseFirestore.instance
        .collection('interests')
        .where('postAuthorProfileId', isEqualTo: currentProfileId) // Usa profileId
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) async {
      final notifications = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final interestedUid = data['interestedUid'] as String?;
        final interestedProfileId = data['interestedProfileId'] as String?;
        final postId = data['postId'] as String?;

        if (interestedUid == null || interestedProfileId == null || postId == null) continue;

        // Buscar dados do perfil interessado usando ProfileResolverService
        final interestedUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(interestedUid)
            .get();

        if (!interestedUserDoc.exists) continue;

        final interestedUserData = interestedUserDoc.data()!;
        
        // Resolver nome e foto do perfil interessado
        String interestedName = 'Usuário';
        String interestedPhoto = '';
        bool interestedIsBand = false;
        
        if (interestedProfileId == interestedUid) {
          // Perfil principal
          interestedName = interestedUserData['name'] ?? 'Usuário';
          interestedPhoto = interestedUserData['photoUrl'] ?? '';
          interestedIsBand = interestedUserData['isBand'] ?? false;
        } else {
          // Perfil secundário
          final profilesList = interestedUserData['profiles'] as List<dynamic>?;
          if (profilesList != null) {
            try {
              final profileData = profilesList
                  .cast<Map<String, dynamic>>()
                  .firstWhere((p) => p['profileId'] == interestedProfileId);
              interestedName = profileData['name'] ?? 'Usuário';
              interestedPhoto = profileData['photoUrl'] ?? '';
              interestedIsBand = profileData['isBand'] ?? false;
            } catch (_) {
              interestedName = interestedUserData['name'] ?? 'Usuário';
              interestedPhoto = interestedUserData['photoUrl'] ?? '';
            }
          }
        }

        // Buscar dados do post
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();

        String postMessage = 'seu post';
        if (postDoc.exists) {
          final postData = postDoc.data();
          postMessage = (postData?['message'] as String?) ?? 'seu post';
        }

        notifications.add({
          'id': doc.id,
          'type': 'interest',
          'interestedUid': interestedUid,
          'interestedProfileId': interestedProfileId,
          'interestedName': interestedName,
          'interestedPhoto': interestedPhoto,
          'interestedType': interestedIsBand ? 'band' : 'musician',
          'postId': postId,
          'postMessage': postMessage,
          'createdAt': data['createdAt'] as Timestamp?,
          'read': data['read'] ?? false,
        });
      }

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    });
  }

  /// Marca notificação como lida
  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('interests')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('Erro ao marcar notificação como lida: $e');
    }
  }

  /// Marca todas as notificações como lidas
  Future<void> _markAllAsRead() async {
    final batch = FirebaseFirestore.instance.batch();

    for (final notification in _notifications) {
      if (!(notification['read'] as bool)) {
        final docRef = FirebaseFirestore.instance
            .collection('interests')
            .doc(notification['id']);
        batch.update(docRef, {'read': true});
      }
    }

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas as notificações foram marcadas como lidas'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao marcar todas como lidas: $e');
    }
  }

  /// Deleta uma notificação
  Future<void> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('interests')
          .doc(notificationId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação removida'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao deletar notificação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// AppBar com título e ações
  PreferredSizeWidget _buildAppBar() {
    final unreadCount = _notifications.where((n) => !(n['read'] as bool)).length;

    return AppBar(
      backgroundColor: _primaryColor,
      elevation: 0,
      title: const Text(
        'Notificações',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        if (unreadCount > 0)
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
            label: const Text(
              'Marcar todas',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'Interesses'),
          Tab(text: 'Outras'),
        ],
      ),
    );
  }

  /// Corpo principal com lista de notificações
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationsList(_notifications),
        _buildNotificationsList(_notifications.where((n) => n['type'] == 'interest').toList()),
        _buildNotificationsList(_notifications.where((n) => n['type'] != 'interest').toList()),
      ],
    );
  }

  /// Lista de notificações
  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma notificação',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quando alguém demonstrar interesse\nem seus posts, você será notificado aqui',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  /// Item individual de notificação
  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final notificationId = notification['id'] as String;
    final isRead = notification['read'] as bool;
    final timestamp = notification['createdAt'] as Timestamp?;
    final interestedPhoto = notification['interestedPhoto'] as String;
    final interestedType = notification['interestedType'] as String;

    // Formata tempo relativo
    String timeAgo = '';
    if (timestamp != null) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        timeAgo = '${(difference.inDays / 30).floor()}m atrás';
      } else if (difference.inDays > 7) {
        timeAgo = '${(difference.inDays / 7).floor()}sem atrás';
      } else if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d atrás';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h atrás';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}min atrás';
      } else {
        timeAgo = 'agora';
      }
    }

    return Dismissible(
      key: Key(notificationId),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remover notificação'),
            content: const Text('Deseja remover esta notificação?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Remover'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteNotification(notificationId),
      child: Container(
        color: isRead ? _cardColor : _primaryColor.withValues(alpha: 0.05),
        child: InkWell(
          onTap: () {
            if (!isRead) {
              _markAsRead(notificationId);
            }
            // Navegar para perfil do usuário interessado
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ViewProfilePage(
                  userId: notification['interestedUid'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar do usuário interessado
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: interestedType == 'band'
                          ? _secondaryColor.withValues(alpha: 0.2)
                          : _primaryColor.withValues(alpha: 0.2),
                      backgroundImage: interestedPhoto.isNotEmpty
                          ? NetworkImage(interestedPhoto)
                          : null,
                      child: interestedPhoto.isEmpty
                          ? Icon(
                              interestedType == 'band' ? Icons.group : Icons.person,
                              size: 28,
                              color: interestedType == 'band'
                                  ? _secondaryColor
                                  : _primaryColor,
                            )
                          : null,
                    ),
                    // Ícone de coração no canto
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                          border: Border.all(color: _cardColor, width: 2),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Conteúdo da notificação
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mensagem
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: _textPrimary,
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: notification['interestedName'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: ' demonstrou interesse em '),
                            TextSpan(
                              text: notification['postMessage'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Hora
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicador de não lida
                if (!isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
