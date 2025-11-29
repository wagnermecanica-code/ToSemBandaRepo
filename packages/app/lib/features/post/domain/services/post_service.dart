import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service para gerenciar operações de posts (CRUD + Storage)
/// Abstrai lógica de Firestore e Firebase Storage
class PostService {
  PostService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Cria um novo post
  ///
  /// Returns: ID do post criado
  Future<String> createPost(Map<String, dynamic> postData) async {
    try {
      final docRef = await _firestore.collection('posts').add(postData);
      debugPrint('Post created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  /// Atualiza um post existente
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('posts').doc(postId).update(updates);
      debugPrint('Post updated: $postId');
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }

  /// Deleta um post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      debugPrint('Post deleted: $postId');
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  /// Busca um post por ID
  Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      debugPrint('Error getting post: $e');
      return null;
    }
  }

  /// Upload de imagem para Storage
  ///
  /// [file]: Arquivo da imagem comprimida
  /// [postId]: ID do post (usado no path)
  ///
  /// Returns: URL de download da imagem
  Future<String> uploadPostImage(File file, String postId) async {
    try {
      final ref = _storage
          .ref()
          .child('posts/$postId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Image uploaded: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Deleta uma imagem do Storage
  ///
  /// [imageUrl]: URL da imagem a ser deletada
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('Image deleted: $imageUrl');
    } catch (e) {
      debugPrint('Error deleting image: $e');
      // Não propaga erro (imagem pode já ter sido deletada)
    }
  }

  /// Query posts com filtros
  ///
  /// [filters]: Mapa de filtros (city, instruments, genres, etc)
  /// [limit]: Número máximo de resultados
  /// [startAfter]: DocumentSnapshot para paginação
  ///
  /// Returns: Query configurada (não executada)
  Query<Map<String, dynamic>> queryPosts({
    Map<String, dynamic>? filters,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('posts');

    // Filtros básicos
    if (filters != null) {
      if (filters['city'] != null) {
        query = query.where('city', isEqualTo: filters['city']);
      }

      if (filters['type'] != null) {
        query = query.where('type', isEqualTo: filters['type']);
      }

      // Filtro de expiração (obrigatório)
      query = query.where('expiresAt', isGreaterThan: Timestamp.now());
    } else {
      // Se não tem filtros, ainda aplica expiração
      query = query.where('expiresAt', isGreaterThan: Timestamp.now());
    }

    // Ordenação
    query = query.orderBy('expiresAt').orderBy('createdAt', descending: true);

    // Paginação
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.limit(limit);
  }

  /// Busca posts de um perfil específico
  Stream<List<Map<String, dynamic>>> watchProfilePosts(String profileId) {
    return _firestore
        .collection('posts')
        .where('authorProfileId', isEqualTo: profileId)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  /// Valida dados do post antes de salvar
  ///
  /// Throws: ArgumentError se dados inválidos
  void validatePostData(Map<String, dynamic> data) {
    // Campos obrigatórios
    final requiredFields = [
      'authorUid',
      'authorProfileId',
      'authorName',
      'type',
      'city',
      'location',
      'expiresAt',
      'createdAt',
    ];

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        throw ArgumentError('Missing required field: $field');
      }
    }

    // Validação de type
    if (!['musician', 'band'].contains(data['type'])) {
      throw ArgumentError('Invalid type: ${data['type']}');
    }

    // Validação de location (deve ser GeoPoint)
    if (data['location'] is! GeoPoint) {
      throw ArgumentError('location must be a GeoPoint');
    }

    // Validação de expiresAt (deve ser no futuro)
    final expiresAt = data['expiresAt'];
    if (expiresAt is Timestamp) {
      if (expiresAt.toDate().isBefore(DateTime.now())) {
        throw ArgumentError('expiresAt must be in the future');
      }
    }

    // Validação específica por tipo
    if (data['type'] == 'musician') {
      if (data['instruments'] == null ||
          (data['instruments'] as List).isEmpty) {
        throw ArgumentError('Musicians must have at least one instrument');
      }
    }

    if (data['type'] == 'band') {
      if (data['seekingMusicians'] == null ||
          (data['seekingMusicians'] as List).isEmpty) {
        throw ArgumentError('Bands must specify musicians they are seeking');
      }
    }
  }
}
