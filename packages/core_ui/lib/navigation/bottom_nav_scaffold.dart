import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wegig_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:wegig_app/features/home/presentation/pages/home_page.dart';
import 'package:wegig_app/features/post/presentation/pages/post_page.dart';
import 'package:wegig_app/features/messages/presentation/pages/messages_page.dart';
import 'package:wegig_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:wegig_app/features/profile/presentation/pages/view_profile_page.dart';
import 'package:wegig_app/features/notifications/domain/services/notification_service.dart';
import 'package:core_ui/models/search_params.dart';
import 'package:core_ui/features/notifications/domain/entities/notification_entity.dart';
import 'package:wegig_app/features/messages/presentation/pages/chat_detail_page.dart';

/// Configuração de item da bottom nav
class _NavItemConfig {
  const _NavItemConfig({
    required this.icon,
    required this.label,
    this.hasBadge = false,
    this.isAvatar = false,
  });

  final IconData icon;
  final String label;
  final bool hasBadge;
  final bool isAvatar;
}

/// Bottom Navigation Scaffold - Navegação principal do app
///
/// Otimizações implementadas:
/// - CachedNetworkImage para avatar (reduz rebuilds)
/// - ValueNotifier para índice (evita setState no Scaffold)
/// - StreamBuilders otimizados (apenas onde necessário)
/// - IndexedStack preserva estado das páginas

class BottomNavScaffold extends ConsumerStatefulWidget {
  const BottomNavScaffold({super.key});

  @override
  ConsumerState<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends ConsumerState<BottomNavScaffold> {
  // ValueNotifier evita rebuilds desnecessários do Scaffold
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  // notifier used to pass search params from SearchPage to HomePage
  final ValueNotifier<SearchParams?> _searchNotifier =
      ValueNotifier<SearchParams?>(null);

  // Lazy initialization - páginas carregadas sob demanda
  late final List<Widget> _pages = [
    HomePage(searchNotifier: _searchNotifier),
    const NotificationsPage(),
    PostPage(postType: 'musician'), // Default to musician type
    const MessagesPage(),
    // ViewProfilePage without userId shows the current authenticated user's profile
    const ViewProfilePage(),
  ];

  // Configuração dos itens da bottom nav (elimina código repetitivo)
  static const List<_NavItemConfig> _navItems = [
    _NavItemConfig(icon: Icons.home, label: 'Início'),
    _NavItemConfig(
        icon: Icons.notifications, label: 'Notificações', hasBadge: true),
    _NavItemConfig(icon: Icons.add_box, label: 'Criar Post'),
    _NavItemConfig(icon: Icons.chat_bubble_outline, label: 'Mensagens'),
    _NavItemConfig(icon: Icons.person, label: 'Perfil', isAvatar: true),
  ];

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    _searchNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Router garante que só chegamos aqui com perfil ativo
    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, child) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (i) async {
              if (i == 2) {
                // Show a brief full-screen loader before opening PostPage
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                await Future.delayed(const Duration(milliseconds: 300));
                if (context.mounted) Navigator.of(context).pop();
                _currentIndexNotifier.value = i;
                return;
              }

              _currentIndexNotifier.value = i;
            },
            items: List.generate(
              _navItems.length,
              (index) =>
                  _buildNavItem(_navItems[index], index == currentIndex),
            ),
          ),
        );
      },
    );
  }

  /// Constrói item da bottom nav baseado na configuração
  BottomNavigationBarItem _buildNavItem(
      _NavItemConfig config, bool isSelected) {
    Widget icon;

    if (config.hasBadge) {
      // Notificações com badge
      icon = _buildNotificationIcon();
    } else if (config.isAvatar) {
      // Avatar do perfil com cache
      icon = _buildAvatarIcon(isSelected);
    } else {
      // Ícone padrão
      icon = Icon(config.icon, size: 26);
    }

    return BottomNavigationBarItem(
      icon: icon,
      label: config.label,
    );
  }

  /// Ícone de notificações com badge reativo e modal
  Widget _buildNotificationIcon() {
    return StreamBuilder<int>(
      stream: ref.watch(notificationServiceProvider).streamUnreadCount(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return InkWell(
          onTap: () => _showNotificationsModal(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications, size: 26),
                if (unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mostra modal com notificações recentes
  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsModal(),
    );
  }

  /// Avatar do perfil ativo com CachedNetworkImage (otimizado)
  Widget _buildAvatarIcon(bool isSelected) {
    final profileState = ref.watch(profileProvider);
    final activeProfile = profileState.value?.activeProfile;
    final photo = activeProfile?.photoUrl;
    if (activeProfile == null) {
      return const CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 18),
      );
    }
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: _buildAvatarImage(photo),
    );
  }

  /// Constrói imagem do avatar com cache otimizado
  Widget _buildAvatarImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.person, size: 18),
      );
    }

    // URL remota - usar CachedNetworkImage para performance
    if (photoUrl.startsWith('http')) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            width: 28,
            height: 28,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.person,
              size: 18,
            ),
            // Otimizações de cache
            memCacheWidth: 56, // 2x resolution
            memCacheHeight: 56,
            fadeInDuration: const Duration(milliseconds: 200),
          ),
        ),
      );
    }

    // Arquivo local - usar FileImage (menos comum)
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.grey[200],
      backgroundImage: _createLocalImageProvider(photoUrl),
      child: const Icon(Icons.person, size: 18),
    );
  }

  /// Cria ImageProvider para arquivo local (fallback assíncrono)
  ImageProvider? _createLocalImageProvider(String pathOrUrl) {
    try {
      String candidate = pathOrUrl;
      if (candidate.startsWith('file://')) {
        candidate = Uri.parse(candidate).toFilePath();
      }

      final f = File(candidate);
      // Verificação assíncrona evita bloquear UI
      if (f.existsSync()) {
        return FileImage(f);
      }
    } catch (e) {
      debugPrint('Error loading local image: $e');
    }

    return null; // Fallback para ícone padrão
  }
}

/// Modal de notificações rápidas
class NotificationsModal extends ConsumerStatefulWidget {
  const NotificationsModal({super.key});

  @override
  ConsumerState<NotificationsModal> createState() =>
      _NotificationsModalState();
}

class _NotificationsModalState extends ConsumerState<NotificationsModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notificações',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to full notifications page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsPage(),
                      ),
                    );
                  },
                  child: const Text('Ver todas'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final profileState = ref.watch(profileProvider);
                final activeProfile = profileState.value?.activeProfile;
                if (activeProfile == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                // ...existing code for notifications...
                return StreamBuilder<List<NotificationEntity>>(
                  stream: ref.watch(notificationServiceProvider).streamActiveProfileNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.red.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar notificações',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }
                    final notifications = snapshot.data ?? [];
                    final recentNotifications = notifications.take(10).toList();
                    if (recentNotifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma notificação',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: recentNotifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(
                            recentNotifications[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationEntity notification) {
    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        color: notification.read ? Colors.white : Colors.blue.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildNotificationIcon(notification),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationEntity notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.interest:
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case NotificationType.newMessage:
        icon = Icons.message;
        color = Colors.blue;
        break;
      case NotificationType.postExpiring:
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case NotificationType.nearbyPost:
        icon = Icons.location_on;
        color = Colors.green;
        break;
      case NotificationType.profileMatch:
        icon = Icons.people;
        color = Colors.purple;
        break;
      case NotificationType.interestResponse:
        icon = Icons.reply;
        color = Colors.blue;
        break;
      case NotificationType.postUpdated:
        icon = Icons.edit;
        color = Colors.grey;
        break;
      case NotificationType.profileView:
        icon = Icons.visibility;
        color = Colors.purple;
        break;
      case NotificationType.system:
        icon = Icons.info;
        color = Colors.teal;
        break;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Future<void> _handleNotificationTap(NotificationEntity notification) async {
    // Close modal first
    Navigator.pop(context);

    // Mark as read
    if (!notification.read) {
      try {
        await ref.read(notificationServiceProvider).markAsRead(notification.notificationId);
      } catch (e) {
        debugPrint('Erro ao marcar notificação como lida: $e');
      }
    }

    // Execute action based on type
    if (!mounted) return;

    switch (notification.actionType) {
      case NotificationActionType.viewProfile:
        final userId = notification.actionData?['userId'] as String?;
        final profileId = notification.actionData?['profileId'] as String?;
        if (userId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ViewProfilePage(
                userId: userId,
                profileId: profileId ?? userId,
              ),
            ),
          );
        }
        break;

      case NotificationActionType.openChat:
        final conversationId =
            notification.actionData?['conversationId'] as String?;
        final otherUserId = notification.actionData?['otherUserId'] as String?;
        final otherProfileId =
            notification.actionData?['otherProfileId'] as String?;

        if (conversationId != null &&
            otherUserId != null &&
            otherProfileId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatDetailPage(
                conversationId: conversationId,
                otherUserId: otherUserId,
                otherProfileId: otherProfileId,
                otherUserName: notification.senderName ?? 'Usuário',
                otherUserPhoto: notification.senderPhoto ?? '',
              ),
            ),
          );
        }
        break;

      case NotificationActionType.viewPost:
        final postId = notification.actionData?['postId'] as String?;
        if (postId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Visualizar post (em desenvolvimento)')),
          );
        }
        break;

      case NotificationActionType.renewPost:
        final postId = notification.actionData?['postId'] as String?;
        if (postId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Renovar post (em desenvolvimento)')),
          );
        }
        break;

      default:
        break;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return 'Agora';
    }
  }
}