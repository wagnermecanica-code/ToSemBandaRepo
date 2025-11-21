import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme/app_colors.dart';

/// Widget reutilizável para item de conversa na lista
/// Otimizado com CachedNetworkImage e timeago internacionalizado
class ConversationItem extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onToggleSelection;
  final Future<void> Function(String) onDelete;
  final Future<void> Function(String) onArchive;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    this.onToggleSelection,
    required this.onDelete,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final conversationId = conversation['conversationId'] as String;
    final unreadCount = conversation['unreadCount'] as int;
    final hasUnread = unreadCount > 0;
    final timestamp = conversation['lastMessageTimestamp'] as Timestamp?;
    final isOnline = conversation['isOnline'] as bool;
    final type = conversation['type'] as String;

    final primaryColor = AppColors.primary;
    final secondaryColor = AppColors.accent;
    const textPrimary = Color(0xFF212121);
    const textSecondary = Color(0xFF757575);
    const textTertiary = Color(0xFF9E9E9E);

    // Formata tempo relativo com timeago (internacionalizado)
    String timeAgo = '';
    if (timestamp != null) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        timeAgo = '${date.day}/${date.month}/${date.year}';
      } else {
        timeAgo = timeago.format(date, locale: 'pt_BR');
      }
    }

    return Dismissible(
      key: Key(conversationId),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.blue,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Excluir
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Excluir conversa'),
              content: const Text(
                'Deseja realmente excluir esta conversa?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Excluir'),
                ),
              ],
            ),
          );
        } else {
          // Arquivar
          await onArchive(conversationId);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Conversa arquivada'),
                backgroundColor: Colors.green,
              ),
            );
          }
          return true;
        }
      },
      child: Material(
        color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: primaryColor.withValues(alpha: 0.2),
          highlightColor: primaryColor.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Checkbox no modo seleção
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggleSelection?.call(),
                      activeColor: primaryColor,
                    ),
                  ),

                // Avatar com status online e Hero animation
                Hero(
                  tag: 'avatar_$conversationId',
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: type == 'band'
                            ? secondaryColor.withValues(alpha: 0.2)
                            : primaryColor.withValues(alpha: 0.2),
                        child: conversation['otherUserPhoto'] != null &&
                                (conversation['otherUserPhoto'] as String).isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: conversation['otherUserPhoto'],
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                  errorWidget: (context, url, error) => Icon(
                                    type == 'band' ? Icons.group : Icons.person,
                                    size: 28,
                                    color: type == 'band' ? secondaryColor : primaryColor,
                                  ),
                                  memCacheWidth: 112,
                                  memCacheHeight: 112,
                                  fadeInDuration: Duration.zero,
                                  maxWidthDiskCache: 112,
                                  maxHeightDiskCache: 112,
                                ),
                              )
                            : Icon(
                                type == 'band' ? Icons.group : Icons.person,
                                size: 28,
                                color: type == 'band' ? secondaryColor : primaryColor,
                              ),
                      ),
                      // Indicador de status online
                      if (isOnline)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Nome, última mensagem e hora
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Nome do usuário
                          Expanded(
                            child: Text(
                              conversation['otherUserName'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Hora
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: hasUnread ? primaryColor : textTertiary,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Preview da última mensagem
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation['lastMessage'],
                              style: TextStyle(
                                fontSize: 14,
                                color: hasUnread ? textSecondary : textTertiary,
                                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Badge de mensagens não lidas
                          if (hasUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: hasUnread ? primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ],
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
