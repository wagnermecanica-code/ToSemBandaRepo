// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ============================================
/// DATA LAYER - Dependency Injection
/// ============================================
/// Provider para AuthRemoteDataSource (singleton)

@ProviderFor(authRemoteDataSource)
const authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

/// ============================================
/// DATA LAYER - Dependency Injection
/// ============================================
/// Provider para AuthRemoteDataSource (singleton)

final class AuthRemoteDataSourceProvider extends $FunctionalProvider<
    AuthRemoteDataSource,
    AuthRemoteDataSource,
    AuthRemoteDataSource> with $Provider<AuthRemoteDataSource> {
  /// ============================================
  /// DATA LAYER - Dependency Injection
  /// ============================================
  /// Provider para AuthRemoteDataSource (singleton)
  const AuthRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'81623d7edccdf752d906b3ed575e7d500a107f64';

/// Provider para AuthRepository (singleton)

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// Provider para AuthRepository (singleton)

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Provider para AuthRepository (singleton)
  const AuthRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'a678f8abf1b6fe259300fddf49676238f81d2901';

/// ============================================
/// DOMAIN LAYER - UseCases
/// ============================================
/// Provider para SignInWithEmailUseCase

@ProviderFor(signInWithEmailUseCase)
const signInWithEmailUseCaseProvider = SignInWithEmailUseCaseProvider._();

/// ============================================
/// DOMAIN LAYER - UseCases
/// ============================================
/// Provider para SignInWithEmailUseCase

final class SignInWithEmailUseCaseProvider extends $FunctionalProvider<
    SignInWithEmailUseCase,
    SignInWithEmailUseCase,
    SignInWithEmailUseCase> with $Provider<SignInWithEmailUseCase> {
  /// ============================================
  /// DOMAIN LAYER - UseCases
  /// ============================================
  /// Provider para SignInWithEmailUseCase
  const SignInWithEmailUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'signInWithEmailUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$signInWithEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithEmailUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInWithEmailUseCase create(Ref ref) {
    return signInWithEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithEmailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithEmailUseCase>(value),
    );
  }
}

String _$signInWithEmailUseCaseHash() =>
    r'e5c4712c6497ed2312b86ace2a8b2ef3d50c9e1c';

/// Provider para SignUpWithEmailUseCase

@ProviderFor(signUpWithEmailUseCase)
const signUpWithEmailUseCaseProvider = SignUpWithEmailUseCaseProvider._();

/// Provider para SignUpWithEmailUseCase

final class SignUpWithEmailUseCaseProvider extends $FunctionalProvider<
    SignUpWithEmailUseCase,
    SignUpWithEmailUseCase,
    SignUpWithEmailUseCase> with $Provider<SignUpWithEmailUseCase> {
  /// Provider para SignUpWithEmailUseCase
  const SignUpWithEmailUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'signUpWithEmailUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$signUpWithEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignUpWithEmailUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignUpWithEmailUseCase create(Ref ref) {
    return signUpWithEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpWithEmailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpWithEmailUseCase>(value),
    );
  }
}

String _$signUpWithEmailUseCaseHash() =>
    r'aad37ba1afdd8983ab16e6e8a0dce1163059cbec';

/// Provider para SignInWithGoogleUseCase

@ProviderFor(signInWithGoogleUseCase)
const signInWithGoogleUseCaseProvider = SignInWithGoogleUseCaseProvider._();

/// Provider para SignInWithGoogleUseCase

final class SignInWithGoogleUseCaseProvider extends $FunctionalProvider<
    SignInWithGoogleUseCase,
    SignInWithGoogleUseCase,
    SignInWithGoogleUseCase> with $Provider<SignInWithGoogleUseCase> {
  /// Provider para SignInWithGoogleUseCase
  const SignInWithGoogleUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'signInWithGoogleUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$signInWithGoogleUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithGoogleUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInWithGoogleUseCase create(Ref ref) {
    return signInWithGoogleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithGoogleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithGoogleUseCase>(value),
    );
  }
}

String _$signInWithGoogleUseCaseHash() =>
    r'5276d106e8e23e2a0c4a094cd4d598af7c401a95';

/// Provider para SignInWithAppleUseCase

@ProviderFor(signInWithAppleUseCase)
const signInWithAppleUseCaseProvider = SignInWithAppleUseCaseProvider._();

/// Provider para SignInWithAppleUseCase

final class SignInWithAppleUseCaseProvider extends $FunctionalProvider<
    SignInWithAppleUseCase,
    SignInWithAppleUseCase,
    SignInWithAppleUseCase> with $Provider<SignInWithAppleUseCase> {
  /// Provider para SignInWithAppleUseCase
  const SignInWithAppleUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'signInWithAppleUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$signInWithAppleUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithAppleUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInWithAppleUseCase create(Ref ref) {
    return signInWithAppleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithAppleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithAppleUseCase>(value),
    );
  }
}

String _$signInWithAppleUseCaseHash() =>
    r'1ca1c88231300e99f32404763918be61761aca98';

/// Provider para SignOutUseCase

@ProviderFor(signOutUseCase)
const signOutUseCaseProvider = SignOutUseCaseProvider._();

/// Provider para SignOutUseCase

final class SignOutUseCaseProvider
    extends $FunctionalProvider<SignOutUseCase, SignOutUseCase, SignOutUseCase>
    with $Provider<SignOutUseCase> {
  /// Provider para SignOutUseCase
  const SignOutUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'signOutUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$signOutUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignOutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOutUseCase create(Ref ref) {
    return signOutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOutUseCase>(value),
    );
  }
}

String _$signOutUseCaseHash() => r'6eb7766aee0033bebfd5367c71aa8a01cd3154df';

/// Provider para SendPasswordResetEmailUseCase

@ProviderFor(sendPasswordResetEmailUseCase)
const sendPasswordResetEmailUseCaseProvider =
    SendPasswordResetEmailUseCaseProvider._();

/// Provider para SendPasswordResetEmailUseCase

final class SendPasswordResetEmailUseCaseProvider extends $FunctionalProvider<
        SendPasswordResetEmailUseCase,
        SendPasswordResetEmailUseCase,
        SendPasswordResetEmailUseCase>
    with $Provider<SendPasswordResetEmailUseCase> {
  /// Provider para SendPasswordResetEmailUseCase
  const SendPasswordResetEmailUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sendPasswordResetEmailUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sendPasswordResetEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<SendPasswordResetEmailUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SendPasswordResetEmailUseCase create(Ref ref) {
    return sendPasswordResetEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendPasswordResetEmailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<SendPasswordResetEmailUseCase>(value),
    );
  }
}

String _$sendPasswordResetEmailUseCaseHash() =>
    r'4dc7751434b54d4887477c9a1d7455e849ec67ed';

/// Provider para SendEmailVerificationUseCase

@ProviderFor(sendEmailVerificationUseCase)
const sendEmailVerificationUseCaseProvider =
    SendEmailVerificationUseCaseProvider._();

/// Provider para SendEmailVerificationUseCase

final class SendEmailVerificationUseCaseProvider extends $FunctionalProvider<
    SendEmailVerificationUseCase,
    SendEmailVerificationUseCase,
    SendEmailVerificationUseCase> with $Provider<SendEmailVerificationUseCase> {
  /// Provider para SendEmailVerificationUseCase
  const SendEmailVerificationUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sendEmailVerificationUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sendEmailVerificationUseCaseHash();

  @$internal
  @override
  $ProviderElement<SendEmailVerificationUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SendEmailVerificationUseCase create(Ref ref) {
    return sendEmailVerificationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendEmailVerificationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendEmailVerificationUseCase>(value),
    );
  }
}

String _$sendEmailVerificationUseCaseHash() =>
    r'2615c5d17f0dd3e80a63c95550f49a3f00ab721f';

/// ============================================
/// PRESENTATION LAYER - State
/// ============================================
/// Provider para o stream de auth state changes
///
/// Reactivo - atualiza automaticamente quando user faz login/logout

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

/// ============================================
/// PRESENTATION LAYER - State
/// ============================================
/// Provider para o stream de auth state changes
///
/// Reactivo - atualiza automaticamente quando user faz login/logout

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// ============================================
  /// PRESENTATION LAYER - State
  /// ============================================
  /// Provider para o stream de auth state changes
  ///
  /// Reactivo - atualiza automaticamente quando user faz login/logout
  const AuthStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'34a41c7499f55a661d192878d349cbfab89c78c9';

/// Provider para o usuário atual (nullable)
///
/// Útil para checagens rápidas sem async

@ProviderFor(currentUser)
const currentUserProvider = CurrentUserProvider._();

/// Provider para o usuário atual (nullable)
///
/// Útil para checagens rápidas sem async

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// Provider para o usuário atual (nullable)
  ///
  /// Útil para checagens rápidas sem async
  const CurrentUserProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'88ba1c74bce80a9739366dfefce2731e2f582f55';

/// Provider para verificar se usuário está autenticado

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Provider para verificar se usuário está autenticado

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider para verificar se usuário está autenticado
  const IsAuthenticatedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isAuthenticatedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'b72ba2077fffcbed5f0a4b6a5d3cbf052855b804';

/// Provider para verificar se email foi verificado

@ProviderFor(isEmailVerified)
const isEmailVerifiedProvider = IsEmailVerifiedProvider._();

/// Provider para verificar se email foi verificado

final class IsEmailVerifiedProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provider para verificar se email foi verificado
  const IsEmailVerifiedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isEmailVerifiedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isEmailVerifiedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isEmailVerified(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isEmailVerifiedHash() => r'16d272301be3a8b6bb79f49a2096540516e3880a';

/// ============================================
/// FACADE - Simplificação de acesso
/// ============================================
/// Provider para AuthService (facade)
///
/// MANTIDO PARA RETROCOMPATIBILIDADE COM CÓDIGO ANTIGO
/// Fornece interface simples para código legado que usa AuthService
///
/// DEPRECATED: Novo código deve usar UseCases diretamente

@ProviderFor(authService)
@Deprecated('Use UseCases diretamente (signInWithEmailUseCaseProvider, etc)')
const authServiceProvider = AuthServiceProvider._();

/// ============================================
/// FACADE - Simplificação de acesso
/// ============================================
/// Provider para AuthService (facade)
///
/// MANTIDO PARA RETROCOMPATIBILIDADE COM CÓDIGO ANTIGO
/// Fornece interface simples para código legado que usa AuthService
///
/// DEPRECATED: Novo código deve usar UseCases diretamente

@Deprecated('Use UseCases diretamente (signInWithEmailUseCaseProvider, etc)')
final class AuthServiceProvider
    extends $FunctionalProvider<IAuthService, IAuthService, IAuthService>
    with $Provider<IAuthService> {
  /// ============================================
  /// FACADE - Simplificação de acesso
  /// ============================================
  /// Provider para AuthService (facade)
  ///
  /// MANTIDO PARA RETROCOMPATIBILIDADE COM CÓDIGO ANTIGO
  /// Fornece interface simples para código legado que usa AuthService
  ///
  /// DEPRECATED: Novo código deve usar UseCases diretamente
  const AuthServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<IAuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthService>(value),
    );
  }
}

String _$authServiceHash() => r'a061f38db57f9c876af0b1b60bbad09babef3994';
