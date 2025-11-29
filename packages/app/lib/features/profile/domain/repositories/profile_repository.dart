import 'package:core_ui/features/profile/domain/entities/profile_entity.dart';

/// ProfileRepository - Interface pura (domain layer)
///
/// Define contrato para operações CRUD de perfis sem detalhes de implementação.
/// A implementação real está em data/repositories/profile_repository_impl.dart
abstract class ProfileRepository {
  /// Busca todos os perfis do usuário autenticado
  ///
  /// Returns:
  /// - List<ProfileEntity> se sucesso
  /// - Lança exceção se erro
  Future<List<ProfileEntity>> getAllProfiles(String uid);

  /// Busca perfil específico por ID
  ///
  /// Returns:
  /// - ProfileEntity se encontrado
  /// - null se não encontrado
  /// - Lança exceção se erro
  Future<ProfileEntity?> getProfileById(String profileId);

  /// Cria novo perfil
  ///
  /// Validações (feitas no UseCase):
  /// - Limite de 5 perfis por usuário
  /// - Nome entre 2-50 caracteres
  /// - Localização válida
  ///
  /// Returns:
  /// - ProfileEntity criado
  /// - Lança exceção se erro
  Future<ProfileEntity> createProfile(ProfileEntity profile);

  /// Atualiza perfil existente
  ///
  /// Returns:
  /// - ProfileEntity atualizado
  /// - Lança exceção se erro
  Future<ProfileEntity> updateProfile(ProfileEntity profile);

  /// Deleta perfil (atomic transaction)
  ///
  /// Se deletar perfil ativo e houver outros perfis:
  /// - newActiveProfileId deve ser fornecido
  ///
  /// Returns:
  /// - void se sucesso
  /// - Lança exceção se erro
  Future<void> deleteProfile(
    String profileId, {
    String? newActiveProfileId,
  });

  /// Troca perfil ativo (atomic transaction)
  ///
  /// Atualiza users/{uid}.activeProfileId
  ///
  /// Returns:
  /// - void se sucesso
  /// - Lança exceção se erro
  Future<void> switchActiveProfile(String uid, String newProfileId);

  /// Busca perfil ativo do usuário
  ///
  /// Returns:
  /// - ProfileEntity se há perfil ativo
  /// - null se não há perfil ativo (primeiro acesso)
  /// - Lança exceção se erro
  Future<ProfileEntity?> getActiveProfile(String uid);

  /// Verifica se perfil pertence ao usuário
  ///
  /// Returns:
  /// - true se uid do perfil == uid fornecido
  /// - false caso contrário
  Future<bool> isProfileOwner(String profileId, String uid);

  /// Busca resumo dos perfis (usado em profile switcher)
  ///
  /// Returns:
  /// - List<Map<String, dynamic>> com profileId, name, photoUrl, type, city
  Future<List<Map<String, dynamic>>> getProfilesSummary(String uid);
}
