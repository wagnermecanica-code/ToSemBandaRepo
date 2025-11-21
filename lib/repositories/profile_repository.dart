import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile.dart';


abstract class IProfileRepository {
  Future<List<Profile>> getAllProfiles();
  Future<Profile?> getActiveProfile();
  Future<void> switchActiveProfile(String profileId);
  Future<void> updateProfile(Profile profile);
}

class ProfileRepository implements IProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

    CollectionReference get _profilesRef =>
      _firestore.collection('profiles');

  @override
  Future<List<Profile>> getAllProfiles() async {
    // Busca todos os perfis do usuário logado na coleção global 'profiles'
    final snapshot = await _profilesRef.where('uid', isEqualTo: _userId).get();
    return snapshot.docs
        .map((doc) => Profile.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<Profile?> getActiveProfile() async {
    final userDoc = await _firestore.collection('users').doc(_userId).get();
    final activeId = userDoc.data()?['activeProfileId'] as String?;
    if (activeId == null) return null;

    final profileDoc = await _profilesRef.doc(activeId).get();
    if (!profileDoc.exists) return null;

    return Profile.fromMap(profileDoc.data()! as Map<String, dynamic>, profileDoc.id);
  }

  @override
  Future<void> switchActiveProfile(String profileId) async {
    await _firestore.collection('users').doc(_userId).update({'activeProfileId': profileId});
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await _profilesRef.doc(profile.profileId).set(profile.toMap(), SetOptions(merge: true));
  }
}

final profileRepositoryProvider = Provider<IProfileRepository>((ref) => ProfileRepository());
