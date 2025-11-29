import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'core/navigation/bottom_nav_scaffold.dart';
import 'core/theme/app_theme.dart';
import 'core/services/env_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente ANTES de inicializar Firebase
  await EnvService.init();
  if (EnvService.isDevelopment) {
    EnvService.printAll(); // Debug apenas em dev
  }

  // Firebase initialization com retry logic (3 tentativas)
  bool firebaseInitialized = false;
  int retryCount = 0;
  const maxRetries = 3;

  while (!firebaseInitialized && retryCount < maxRetries) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      retryCount++;
      debugPrint('Firebase init failed (attempt $retryCount/$maxRetries): $e');
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
  }

  // Se Firebase foi inicializado, configurar Crashlytics
  if (firebaseInitialized) {
    // Captura erros Flutter e envia para Crashlytics
    FlutterError.onError = (details) {
      debugPrint('Flutter Error: ${details.exception}');
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Captura erros assíncronos não tratados
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Async Error: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Forçar orientação portrait (UX consistente)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Rodar app com ou sem Firebase
  runApp(firebaseInitialized ? const MyApp() : const ErrorApp());
}

/// Tela de erro exibida quando Firebase não inicializa
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Color(0xFFFF5252),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Erro ao conectar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Não foi possível conectar aos servidores.\nVerifique sua conexão e tente novamente.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A699),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Fechar App',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tô Sem Banda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      // Limita textScale para acessibilidade (0.8x - 1.5x)
      // Permite zoom para deficientes visuais sem quebrar layout
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.5),
          ),
          child: child!,
        );
      },

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading bonito com a nova cor teal
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFFAFAFA),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A699)),
                  strokeWidth: 3,
                ),
              ),
            );
          }

          // Usuário logado → app principal
          if (snapshot.hasData) {
            return const BottomNavScaffold();
          }

          // Não logado → tela de autenticação
          return const AuthPage();
        },
      ),
    );
  }
}