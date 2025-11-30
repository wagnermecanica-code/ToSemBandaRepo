// Marker Builder - Creates and manages map markers for posts
import 'package:core_ui/features/post/domain/entities/post_entity.dart';
import 'package:core_ui/services/marker_cache_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerBuilder {
  final MarkerCacheService _markerCache = MarkerCacheService();

  Future<Set<Marker>> buildMarkersForPosts(
    List<PostEntity> posts,
    String? activePostId,
    Future<void> Function(PostEntity) onMarkerTapped,
  ) async {
    final markers = <Marker>{};

    for (final post in posts) {
      final isActive = post.postId == activePostId;
      final markerType = post.type == 'musician' ? 'musician' : 'band';
      final icon = await _markerCache.getMarker(markerType, isActive: isActive);

      final marker = Marker(
        markerId: MarkerId(post.postId),
        position: LatLng(
          post.location.latitude,
          post.location.longitude,
        ),
        icon: icon,
        onTap: () => onMarkerTapped(post),
        zIndex: isActive ? 1000 : 1,
      );

      markers.add(marker);
    }

    return markers;
  }
}
