import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user_profile.dart'; // Removido: use apenas Profile
import '../models/profile.dart';
import '../pages/profile_form_page.dart' show ProfileFormPage;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_transition_overlay.dart';

/// BottomSheet para alternar entre perfis do usuário
/// Agora com animações melhoradas e componentes do Design System
class ProfileSwitcherBottomSheet extends ConsumerWidget {
  final String? activeProfileId;
  final Function(String profileId) onProfileSelected;

  const ProfileSwitcherBottomSheet({
    super.key,
    required this.activeProfileId,
    required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar com semântica para acessibilidade
          Semantics(
            label: 'Arraste para fechar',
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Título com melhor tipografia
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Alternar Perfil',
                  style: AppTypography.titleLarge,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Lista de perfis - Agora com Flexible para evitar overflow
          Flexible(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Erro ao carregar perfis',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final profilesList = data?['profiles'] as List<dynamic>?;
                
                // Incluir perfil original/principal do documento users (se existir)
                final allProfilesData = <Map<String, dynamic>>[];
                
                // Adicionar perfil original se tiver dados
                if (data != null && data['name'] != null && data['name'].toString().isNotEmpty) {
                  allProfilesData.add({
                    'profileId': user.uid, // ID do perfil original é o próprio UID
                    'name': data['name'],
                    'isBand': data['isBand'] ?? false,
                    'photoUrl': data['photoUrl'],
                    'instruments': data['instruments'] ?? [],
                    'genres': data['genres'] ?? [],
                    'bio': data['bio'],
                    'youtubeLink': data['youtubeLink'],
                    'city': data['city'],
                    'level': data['level'],
                  });
                }
                
                // Adicionar perfis secundários
                if (profilesList != null) {
                  allProfilesData.addAll(profilesList.cast<Map<String, dynamic>>());
                }
                
                // Se não há perfis, mostrar opção para criar primeiro perfil
                if (allProfilesData.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum perfil encontrado',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crie seu primeiro perfil para começar',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileFormPage(),
                              ),
                            );
                            if (result == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 12),
                                      const Text('Perfil criado com sucesso!'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Criar Primeiro Perfil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final profiles = allProfilesData
                  .map((p) => Profile.fromMap(p, p['profileId'] as String))
                  .toList();

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: profiles.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                      final profile = profiles[index];
                      final isActive = profile.profileId == activeProfileId;

                      // Card com animação FadeIn
                      return AnimatedOpacity(
                        duration: Duration(milliseconds: 200 + (index * 50)),
                        opacity: 1.0,
                        child: Semantics(
                          label: '${profile.name}, ${profile.isBand ? 'Banda' : 'Músico'}${isActive ? ', perfil ativo' : ''}',
                          button: true,
                          enabled: !isActive,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            // Avatar com indicador de perfil ativo
                            leading: Hero(
                              tag: 'profile-avatar-${profile.profileId}',
                              child: CircleAvatar(
                                radius: 28,
                                backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                                    ? NetworkImage(profile.photoUrl!) as ImageProvider
                                    : null,
                                child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                                    ? Icon(Icons.person, size: 28)
                                    : null,
                              ),
                            ),
                            title: Text(
                              profile.name,
                              style: AppTypography.subtitleLight.copyWith(
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                color: isActive ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  profile.isBand ? Icons.groups : Icons.person,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  profile.isBand ? 'Banda' : 'Músico',
                                  style: AppTypography.captionLight,
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isActive)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 14, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Ativo', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ],
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                                // Menu de opções (editar/excluir)
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      _editProfile(context, profile);
                                    } else if (value == 'delete') {
                                      _deleteProfile(context, ref, profile);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          const Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      enabled: profile.profileId != user.uid, // Não permite excluir perfil principal
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: profile.profileId != user.uid 
                                              ? AppColors.error 
                                              : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Excluir',
                                            style: TextStyle(
                                              color: profile.profileId != user.uid 
                                                ? AppColors.error 
                                                : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: isActive
                                ? null
                                : () async {
                                    try {
                                      // Fecha o modal primeiro
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                      
                                      // Mostra overlay de transição animado
                                      if (context.mounted) {
                                        ProfileTransitionOverlay.show(
                                          context,
                                          profileName: profile.name,
                                          isBand: profile.isBand,
                                          photoUrl: profile.photoUrl,
                                          onComplete: () async {
                                            // Chama o callback para recarregar os dados
                                            onProfileSelected(profile.profileId);
                                          },
                                        );
                                      }
                                      
                                      // Atualiza o perfil ativo usando ProfileRepository
                                      final profileRepository = ref.read(profileRepositoryProvider);
                                      await profileRepository.switchActiveProfile(profile.profileId);
                                      
                                    } catch (e) {
                                      // Fecha overlay se houver erro
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                      
                                      // Mostra mensagem de erro
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(Icons.error, color: Colors.white),
                                                const SizedBox(width: 12),
                                                Expanded(child: Text('Erro ao trocar perfil: $e')),
                                              ],
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                          ),
                        ),
                      );
                  },
                );
              },
            ),
          ),
          
          const Divider(height: 1),
          
          // Botão adicionar novo perfil com gradiente
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Semantics(
              label: 'Adicionar novo perfil',
              button: true,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileFormPage(),
                    ),
                  );
                  // Se retornou um profileId (String), perfil foi criado com sucesso
                  if (result is String && result.isNotEmpty) {
                    try {
                      // Atualiza activeProfileId para o novo perfil
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({'activeProfileId': result});
                      
                      // Chama callback para recarregar dados
                      onProfileSelected(result);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 12),
                                const Text('Perfil alterado'),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Erro ao ativar novo perfil: $e')),
                              ],
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  }
                },
                icon: Icon(Icons.person_add),
                label: Text('Adicionar Novo Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Edita um perfil existente
  void _editProfile(BuildContext context, Profile profile) async {
    Navigator.pop(context); // Fecha o bottom sheet
    
    // Convert UserProfile to Profile for ProfileFormPage
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileFormPage(profile: profile),
      ),
    );
    
    // Se retornou um profileId (String), perfil foi editado
    if (result is String && result.isNotEmpty && context.mounted) {
      // Recarrega dados através do callback
      onProfileSelected(result);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Perfil atualizado!'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Exclui um perfil com confirmação
  void _deleteProfile(BuildContext context, WidgetRef ref, Profile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    // Não permite excluir perfil principal
    if (profile.profileId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(child: Text('Não é possível excluir o perfil principal')),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Diálogo de confirmação com animação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.warning, size: 28),
            const SizedBox(width: 12),
            const Text('Confirmar Exclusão'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja excluir o perfil "${profile.name}"?',
              style: AppTypography.bodyLight,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita.',
                      style: AppTypography.captionLight.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      
      // Verifica se tem mais de um perfil
      final allProfiles = await profileRepository.getAllProfiles();
      if (allProfiles.length <= 1) {
        if (context.mounted) {
          // Não fecha o bottom sheet, apenas mostra o erro.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Você precisa ter pelo menos um perfil')),
                ],
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Fecha o bottom sheet antes de excluir
      if (context.mounted) {
        Navigator.pop(context);
      }

      await profileRepository.deleteProfile(profile.profileId);

      if (context.mounted) {
        // Se excluiu o perfil ativo, recarrega com o novo perfil ativo
        final newActiveProfile = await profileRepository.getActiveProfile();
        if (newActiveProfile != null) {
          onProfileSelected(newActiveProfile.profileId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Perfil excluído com sucesso'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao excluir perfil: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Mostra o BottomSheet de alternância de perfis
  static void show(
    BuildContext context, {
    required String? activeProfileId,
    required Function(String) onProfileSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProfileSwitcherBottomSheet(
        activeProfileId: activeProfileId,
        onProfileSelected: onProfileSelected,
      ),
    );
  }
}