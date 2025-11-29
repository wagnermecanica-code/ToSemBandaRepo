import '../../models/profile.dart' as legacy_profile;
import 'package:core_ui/features/profile/domain/entities/profile_entity.dart';

/// Mappers para converter entre Profile (model) e ProfileEntity (domain)
/// 
/// Usado durante a migração gradual de Clean Architecture
/// TODOS os campos são compatíveis após unificação
extension ProfileToEntityMapper on legacy_profile.Profile {
  /// Converte Profile (model) para ProfileEntity (domain)
  ProfileEntity toEntity() {
    return ProfileEntity(
      profileId: profileId,
      uid: uid,
      name: name,
      isBand: isBand,
      photoUrl: photoUrl,
      city: city,
      location: location,
      instruments: instruments,
      genres: genres,
      level: level,
      birthYear: birthYear,
      bio: bio,
      youtubeLink: youtubeLink,
      instagramLink: instagramLink,
      tiktokLink: tiktokLink,
      bandMembers: bandMembers,
      neighborhood: neighborhood,
      state: state,
      notificationRadiusEnabled: notificationRadiusEnabled,
      notificationRadius: notificationRadius,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ProfileEntityToModelMapper on ProfileEntity {
  /// Converte ProfileEntity (domain) para Profile (model)
  legacy_profile.Profile toModel() {
    return legacy_profile.Profile(
      profileId: profileId,
      uid: uid,
      name: name,
      isBand: isBand,
      photoUrl: photoUrl,
      city: city,
      location: location,
      instruments: instruments,
      genres: genres,
      level: level,
      birthYear: birthYear,
      bio: bio,
      youtubeLink: youtubeLink,
      instagramLink: instagramLink,
      tiktokLink: tiktokLink,
      bandMembers: bandMembers,
      neighborhood: neighborhood,
      state: state,
      notificationRadiusEnabled: notificationRadiusEnabled,
      notificationRadius: notificationRadius,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
