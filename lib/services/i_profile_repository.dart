import '../models/profile.dart';

/// Interface para abstração do repositório de perfis
/// Facilita testes e permite injeção de dependências
/// 
/// Implementações:
/// - FirestoreProfileRepository: Produção (Firestore real)
/// - MockProfileRepository: Testes (dados mockados)
abstract class IProfileRepository {
  /// Busca o perfil ativo do usuário autenticado
  /// 
  /// Returns:
  /// - Profile se encontrado
  /// - null se não autenticado ou perfil não existe
  Future<Profile?> getActiveProfile(String userId);

  /// Busca um perfil específico pelo ID
  Future<Profile?> getProfile(String profileId);

  /// Stream que emite mudanças no activeProfileId do usuário
  Stream<String?> watchActiveProfileId(String userId);

  /// Stream que emite mudanças em um perfil específico
  Stream<Profile?> watchProfile(String profileId);

  /// Atualiza o perfil ativo do usuário
  Future<void> setActiveProfileId(String userId, String profileId);

  /// Lista todos os perfis do usuário
  Future<List<Profile>> listUserProfiles(String userId);
}
