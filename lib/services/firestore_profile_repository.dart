import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import 'i_profile_repository.dart';

/// Implementação Firestore do repositório de perfis
/// Usada em produção
class FirestoreProfileRepository implements IProfileRepository {
  final FirebaseFirestore _firestore;

  FirestoreProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Profile?> getActiveProfile(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final activeProfileId = userDoc.data()?['activeProfileId'] as String?;

      if (activeProfileId == null) {
        debugPrint('No activeProfileId for user $userId');
        return null;
      }

      return await getProfile(activeProfileId);
    } catch (e) {
      debugPrint('Error getting active profile: $e');
      return null;
    }
  }

  @override
  Future<Profile?> getProfile(String profileId) async {
    try {
      final profileDoc = await _firestore
          .collection('profiles')
          .doc(profileId)
          .get();

      if (!profileDoc.exists) {
        debugPrint('Profile $profileId not found');
        return null;
      }

      return Profile.fromMap(profileDoc.data()!, profileDoc.id);
    } catch (e) {
      debugPrint('Error getting profile $profileId: $e');
      return null;
    }
  }

  @override
  Stream<String?> watchActiveProfileId(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data()?['activeProfileId'] as String?;
    }).handleError((error) {
      debugPrint('Error watching activeProfileId: $error');
      return null;
    });
  }

  @override
  Stream<Profile?> watchProfile(String profileId) {
    return _firestore
        .collection('profiles')
        .doc(profileId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      try {
        return Profile.fromMap(snapshot.data()!, snapshot.id);
      } catch (e) {
        debugPrint('Error parsing profile $profileId: $e');
        return null;
      }
    }).handleError((error) {
      debugPrint('Error watching profile $profileId: $error');
      return null;
    });
  }

  @override
  Future<void> setActiveProfileId(String userId, String profileId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'activeProfileId': profileId,
      });
    } catch (e) {
      debugPrint('Error setting active profile: $e');
      rethrow;
    }
  }

  @override
  Future<List<Profile>> listUserProfiles(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('profiles')
          .where('uid', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Profile.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error listing user profiles: $e');
      return [];
    }
  }
}
