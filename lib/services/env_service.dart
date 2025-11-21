import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service para gerenciar variáveis de ambiente de forma segura
/// 
/// Uso:
/// ```dart
/// final apiKey = EnvService.get('GOOGLE_MAPS_API_KEY');
/// final isProduction = EnvService.isProduction;
/// ```
class EnvService {
  static bool _initialized = false;

  /// Inicializa variáveis de ambiente
  /// Chamar no main() antes de runApp()
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      await dotenv.load(fileName: ".env");
      _initialized = true;
      debugPrint('✅ Environment variables loaded');
    } catch (e) {
      debugPrint('⚠️ Failed to load .env file: $e');
      debugPrint('⚠️ Using default environment values');
    }
  }

  /// Obtém variável de ambiente (retorna null se não existir)
  static String? get(String key) {
    if (!_initialized) {
      debugPrint('⚠️ EnvService not initialized. Call EnvService.init() first.');
      return null;
    }
    return dotenv.env[key];
  }

  /// Obtém variável de ambiente com fallback
  static String getOrDefault(String key, String defaultValue) {
    return get(key) ?? defaultValue;
  }

  /// Verifica se está em ambiente de produção
  static bool get isProduction {
    return get('APP_ENV')?.toLowerCase() == 'production';
  }

  /// Verifica se está em ambiente de desenvolvimento
  static bool get isDevelopment {
    return get('APP_ENV')?.toLowerCase() == 'development';
  }

  /// Verifica se está em ambiente de staging
  static bool get isStaging {
    return get('APP_ENV')?.toLowerCase() == 'staging';
  }

  /// Firebase Project ID
  static String get firebaseProjectId {
    return getOrDefault('FIREBASE_PROJECT_ID', 'to-sem-banda-83e19');
  }

  /// Distância máxima padrão em km
  static double get maxDistanceKm {
    final value = get('MAX_DISTANCE_KM');
    return value != null ? double.tryParse(value) ?? 20000.0 : 20000.0;
  }

  /// Feature flag: Dark Mode habilitado
  static bool get isDarkModeEnabled {
    return get('ENABLE_DARK_MODE')?.toLowerCase() == 'true';
  }

  /// Feature flag: Push Notifications habilitadas
  static bool get isPushNotificationsEnabled {
    return get('ENABLE_PUSH_NOTIFICATIONS')?.toLowerCase() == 'true';
  }

  /// Debug: Imprime todas as variáveis carregadas (apenas dev)
  static void printAll() {
    if (!_initialized) {
      debugPrint('⚠️ EnvService not initialized');
      return;
    }

    if (!isDevelopment) {
      debugPrint('⚠️ printAll() only available in development');
      return;
    }

    debugPrint('📋 Environment Variables:');
    dotenv.env.forEach((key, value) {
      // Oculta valores sensíveis
      if (key.contains('KEY') || key.contains('SECRET') || key.contains('TOKEN')) {
        debugPrint('  $key: ****');
      } else {
        debugPrint('  $key: $value');
      }
    });
  }
}
