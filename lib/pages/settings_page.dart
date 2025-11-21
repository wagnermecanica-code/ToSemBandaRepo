import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_page.dart';
import 'auth_page.dart';

/// Tela de Configurações do perfil ativo
/// Design Airbnb 2025: Clean, minimalista, switches e botões bem organizados
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notifyInterests = true;
  bool _notifyMessages = true;
  bool _notifyNearbyPosts = true;
  double _nearbyRadiusKm = 20.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final profileState = ref.read(profileProvider);
    final activeProfile = profileState.value?.activeProfile;
    if (activeProfile == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(activeProfile.profileId)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _notifyNearbyPosts = data?['notificationRadiusEnabled'] as bool? ?? true;
          _nearbyRadiusKm = (data?['notificationRadius'] ?? 20.0).toDouble();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateNotificationSettings() async {
    final profileState = ref.read(profileProvider);
    final activeProfile = profileState.value?.activeProfile;
    if (activeProfile == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(activeProfile.profileId)
          .update({
        'notificationRadiusEnabled': _notifyNearbyPosts,
        'notificationRadius': _nearbyRadiusKm,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _showError('Erro ao salvar configurações');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.read(profileProvider);
    final activeProfile = profileState.value?.activeProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações', style: AppTypography.headlineMedium.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          // Seção: Perfil
          _buildSectionHeader('Perfil', Icons.person_outline),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.edit_outlined,
            title: 'Editar Perfil',
            subtitle: 'Atualize suas informações',
            onTap: () async {
              if (activeProfile == null) {
                _showError('Perfil ativo não encontrado');
                return;
              }

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    profileId: activeProfile.profileId,
                    initialName: activeProfile.name,
                    initialPhotoUrl: activeProfile.photoUrl,
                    initialIsBand: activeProfile.isBand,
                  ),
                ),
              );

              if (result != null && mounted) {
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
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.share_outlined,
            title: 'Compartilhar Perfil',
            subtitle: 'Compartilhe com amigos',
            onTap: () => _shareProfile(activeProfile),
          ),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          
          // Seção: Notificações
          _buildSectionHeader('Notificações', Icons.notifications_outlined),
          const SizedBox(height: 12),
          _buildSwitchTile(
            icon: Icons.favorite_outline,
            title: 'Interesses',
            subtitle: 'Notificação quando alguém demonstra interesse',
            value: _notifyInterests,
            onChanged: (value) {
              setState(() => _notifyInterests = value);
              _showSnackBar('Preferência salva');
            },
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            icon: Icons.message_outlined,
            title: 'Mensagens',
            subtitle: 'Notificação de novas mensagens',
            value: _notifyMessages,
            onChanged: (value) {
              setState(() => _notifyMessages = value);
              _showSnackBar('Preferência salva');
            },
          ),
          const SizedBox(height: 8),
          _buildNearbyPostsCard(),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          
          // Seção: Conta
          _buildSectionHeader('Conta', Icons.account_circle_outlined),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sair da Conta',
            subtitle: 'Desconectar do aplicativo',
            iconColor: AppColors.error,
            textColor: AppColors.error,
            onTap: () => _showLogoutDialog(),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildNearbyPostsCard() {
    if (_isLoading) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            secondary: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            title: Text(
              'Posts Próximos',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Notificação de novos posts perto de você',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            value: _notifyNearbyPosts,
            activeThumbColor: AppColors.primary,
            onChanged: (value) {
              setState(() => _notifyNearbyPosts = value);
              _updateNotificationSettings();
              _showSnackBar(_notifyNearbyPosts 
                  ? 'Você receberá notificações de posts próximos' 
                  : 'Notificações de posts próximos desativadas');
            },
          ),
          
          // Slider animado (aparece quando toggle está ativo)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _notifyNearbyPosts
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Raio de Notificação',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_nearbyRadiusKm.toInt()} km',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Notificar quando houver novos posts até ${_nearbyRadiusKm.toInt()} km de você',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withValues(alpha: 0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                            trackHeight: 4,
                            valueIndicatorColor: AppColors.primary,
                            valueIndicatorTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Slider(
                            value: _nearbyRadiusKm,
                            min: 5.0,
                            max: 100.0,
                            divisions: 19, // 5, 10, 15, ..., 100
                            label: '${_nearbyRadiusKm.toInt()} km',
                            onChanged: (value) {
                              setState(() => _nearbyRadiusKm = value);
                            },
                            onChangeEnd: (value) {
                              _updateNotificationSettings();
                              _showSnackBar('Raio atualizado para ${value.toInt()} km');
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '5 km',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '100 km',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
  
  void _shareProfile(dynamic profile) {
    if (profile == null) {
      _showError('Perfil não encontrado');
      return;
    }
    
    final name = profile.name ?? 'Usuário';
    final type = profile.isBand ? 'Banda' : 'Músico';
    final city = profile.city ?? 'Localização não informada';
    final instruments = profile.instruments?.join(', ') ?? '';
    final genres = profile.genres?.join(', ') ?? '';
    
    String message = '🎵 Confira o perfil no Tô Sem Banda!\n\n';
    message += '📛 Nome: $name\n';
    message += '🎸 Tipo: $type\n';
    message += '📍 Cidade: $city\n';
    
    if (instruments.isNotEmpty) {
      message += '🎹 Instrumentos: $instruments\n';
    }
    
    if (genres.isNotEmpty) {
      message += '🎼 Gêneros: $genres\n';
    }
    
    message += '\nBaixe o app e conecte-se com músicos na sua região!';
    
    Share.share(message, subject: 'Perfil no Tô Sem Banda');
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            const SizedBox(width: 12),
            const Text('Sair da Conta'),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja sair? Você precisará fazer login novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              Navigator.pop(context); // Fecha o dialog
              await _performLogout();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _performLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      
      if (mounted) {
        // Remove todas as rotas e vai para AuthPage
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Erro ao sair: $e');
    }
  }
  
  void _showSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
