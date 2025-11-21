import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviço para resolver informações de perfis de usuários
/// Lida com a distinção entre perfil principal (uid) e perfis secundários (profileId)
class ProfileResolverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Resolve informações de um perfil dado um userId e profileId
  /// 
  /// Se profileId == userId, retorna dados do perfil principal
  /// Caso contrário, busca no array de profiles
  Future<Map<String, dynamic>?> resolveProfile(String userId, String profileId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) return null;
      
      final userData = userDoc.data()!;
      
      // Se profileId é o próprio uid, retornar dados do perfil principal
      if (profileId == userId) {
        return {
          'userId': userId,
          'profileId': profileId,
          'name': userData['name'] ?? 'Usuário',
          'photoUrl': userData['photoUrl'] ?? '',
          'isBand': userData['isBand'] ?? false,
          'instruments': (userData['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
          'genres': (userData['genres'] as List<dynamic>?)?.cast<String>() ?? [],
          'level': userData['level'] as String?,
          'city': userData['city'] as String?,
          'neighborhood': userData['neighborhood'] as String?,
          'state': userData['state'] as String?,
          'latitude': userData['latitude'] as double?,
          'longitude': userData['longitude'] as double?,
          'bio': userData['bio'] as String?,
          'youtubeLink': userData['youtubeLink'] as String?,
        };
      }
      
      // Buscar no array de perfis secundários
      final profilesList = userData['profiles'] as List<dynamic>?;
      if (profilesList == null) return null;
      
      final profileData = profilesList.cast<Map<String, dynamic>>().firstWhere(
            (p) => p['profileId'] == profileId,
            orElse: () => <String, dynamic>{}, // Retorna um mapa vazio se não encontrar
          );

      if (profileData.isEmpty) return null;

      return {
        'userId': userId,
        'profileId': profileId,
        'name': profileData['name'] ?? 'Usuário',
        'photoUrl': profileData['photoUrl'] ?? '',
        'isBand': profileData['isBand'] ?? false,
        'instruments': (profileData['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
        'genres': (profileData['genres'] as List<dynamic>?)?.cast<String>() ?? [],
        'level': profileData['level'] as String?,
        'city': profileData['city'] as String?,
        'neighborhood': profileData['neighborhood'] as String?,
        'state': profileData['state'] as String?,
        'latitude': profileData['latitude'] as double?,
        'longitude': profileData['longitude'] as double?,
        'bio': profileData['bio'] as String?,
        'youtubeLink': profileData['youtubeLink'] as String?,
      };
    } catch (e) {
      return null;
    }
  }

  /// Retorna apenas nome e foto de um perfil (para uso em listas)
  Future<Map<String, String>> resolveProfileBasicInfo(String userId, String profileId) async {
    final profile = await resolveProfile(userId, profileId);
    
    if (profile == null) {
      return {
        'name': 'Usuário',
        'photoUrl': '',
      };
    }
    
    return {
      'name': profile['name'] as String? ?? 'Usuário',
      'photoUrl': profile['photoUrl'] as String? ?? '',
    };
  }

  /// Stream para observar mudanças em um perfil específico
  Stream<Map<String, dynamic>?> watchProfile(String userId, String profileId) async* {
    await for (final snapshot in _firestore.collection('users').doc(userId).snapshots()) {
      if (!snapshot.exists) {
        yield null;
        continue;
      }
      
      final userData = snapshot.data()!;
      
      // Perfil principal
      if (profileId == userId) {
        yield {
          'userId': userId,
          'profileId': profileId,
          'name': userData['name'] ?? 'Usuário',
          'photoUrl': userData['photoUrl'] ?? '',
          'isBand': userData['isBand'] ?? false,
          'instruments': (userData['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
          'genres': (userData['genres'] as List<dynamic>?)?.cast<String>() ?? [],
          'level': userData['level'] as String?,
          'city': userData['city'] as String?,
          'bio': userData['bio'] as String?,
        };
        continue;
      }
      
      // Perfil secundário
      final profilesList = userData['profiles'] as List<dynamic>?;
      if (profilesList == null) {
        yield null;
        continue;
      }
      
      try {
        final profileData = profilesList
            .cast<Map<String, dynamic>>()
            .firstWhere((p) => p['profileId'] == profileId);
        
        yield {
          'userId': userId,
          'profileId': profileId,
          'name': profileData['name'] ?? 'Usuário',
          'photoUrl': profileData['photoUrl'] ?? '',
          'isBand': profileData['isBand'] ?? false,
          'instruments': (profileData['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
          'genres': (profileData['genres'] as List<dynamic>?)?.cast<String>() ?? [],
          'level': profileData['level'] as String?,
          'city': profileData['city'] as String?,
          'bio': profileData['bio'] as String?,
        };
      } catch (e) {
        yield null;
      }
    }
  }
}
