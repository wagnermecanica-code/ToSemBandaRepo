import 'package:flutter/foundation.dart';

/// Utilitário para extrair o ID do vídeo do YouTube a partir de qualquer URL válida
class YoutubeUtils {
  YoutubeUtils._(); // classe utilitária – não instanciável

  /// Suporta os seguintes formatos:
  /// - https://youtu.be/dQw4w9WgXcQ
  /// - https://www.youtube.com/watch?v=dQw4w9WgXcQ
  /// - https://youtube.com/shorts/dQw4w9WgXcQ
  /// - https://www.youtube.com/embed/dQw4w9WgXcQ
  /// - https://www.youtube.com/v/dQw4w9WgXcQ
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;

    try {
      final uri = Uri.parse(url.trim());

      // youtu.be (forma curta)
      if (uri.host == 'youtu.be') {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }

      // youtube.com/shorts/
      if (uri.host.contains('youtube.com') && uri.pathSegments.first == 'shorts') {
        return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      }

      // Parâmetro v= (forma mais comum)
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }

      // Casos embed, v, etc.
      if (uri.pathSegments.isNotEmpty) {
        final lastSegment = uri.pathSegments.last;
        if (lastSegment.length == 11 && RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(lastSegment)) {
          return lastSegment;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('YoutubeUtils: erro ao extrair ID → $e');
      return null;
    }
  }

  /// Gera URL do thumbnail (hqdefault = 480x360, maxresdefault = 1280x720)
  static String thumbnailUrl(String videoId, {bool highQuality = true}) {
    return highQuality
        ? 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg'
        : 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
}
