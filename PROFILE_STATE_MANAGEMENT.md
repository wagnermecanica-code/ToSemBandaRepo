# Gerenciamento de Estado - Perfil Ativo

## Visão Geral

Este documento descreve como implementar um sistema robusto de gerenciamento de estado para perfis de usuário usando **Provider** ou **Riverpod**.

## Por que usar Provider/Riverpod?

Atualmente, o estado do perfil ativo está espalhado por diferentes telas, o que pode causar:
- **Inconsistências**: Dados desatualizados em diferentes partes do app
- **Recarregamento excessivo**: Múltiplas consultas ao Firestore
- **Complexidade**: Callbacks aninhados e difícil rastreamento do estado

Com Provider/Riverpod, você terá:
- **Estado centralizado**: Uma única fonte de verdade
- **Reatividade**: Widgets atualizam automaticamente
- **Testabilidade**: Fácil mockar e testar
- **Performance**: Rebuild apenas dos widgets necessários

---

## Opção 1: Provider (Recomendado para começar)

### 1.1. Adicionar dependência

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.1
```

### 1.2. Criar ProfileProvider

```dart
// lib/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile? _activeProfile;
  List<UserProfile> _profiles = [];
  bool _isLoading = false;
  String? _error;

  UserProfile? get activeProfile => _activeProfile;
  List<UserProfile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfiles => _profiles.isNotEmpty;

  /// Inicializa o provider carregando perfis do Firestore
  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = 'Usuário não autenticado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _error = 'Documento do usuário não encontrado';
        return;
      }

      final data = userDoc.data()!;
      final activeProfileId = data['activeProfileId'] as String?;
      final profilesList = data['profiles'] as List<dynamic>?;

      if (profilesList != null) {
        _profiles = profilesList
            .map((p) => UserProfile.fromMap(p as Map<String, dynamic>))
            .toList();

        // Define perfil ativo
        if (activeProfileId != null) {
          _activeProfile = _profiles.firstWhere(
            (p) => p.profileId == activeProfileId,
            orElse: () => _profiles.first,
          );
        } else if (_profiles.isNotEmpty) {
          _activeProfile = _profiles.first;
          // Atualiza activeProfileId no Firestore
          await _setActiveProfileId(_activeProfile!.profileId);
        }
      }
    } catch (e) {
      _error = 'Erro ao carregar perfis: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Troca o perfil ativo
  Future<void> switchProfile(String profileId) async {
    final profile = _profiles.firstWhere(
      (p) => p.profileId == profileId,
      orElse: () => throw Exception('Perfil não encontrado'),
    );

    _isLoading = true;
    notifyListeners();

    try {
      await _setActiveProfileId(profileId);
      _activeProfile = profile;
      _error = null;
    } catch (e) {
      _error = 'Erro ao trocar perfil: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona novo perfil
  Future<void> addProfile(UserProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    _isLoading = true;
    notifyListeners();

    try {
      _profiles.add(profile);
      
      // Atualiza Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profiles': _profiles.map((p) => p.toMap()).toList(),
        'activeProfileId': profile.profileId, // Novo perfil torna-se ativo
      });

      _activeProfile = profile;
      _error = null;
    } catch (e) {
      _profiles.remove(profile); // Rollback
      _error = 'Erro ao adicionar perfil: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza perfil existente
  Future<void> updateProfile(UserProfile updatedProfile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    _isLoading = true;
    notifyListeners();

    try {
      final index = _profiles.indexWhere(
        (p) => p.profileId == updatedProfile.profileId,
      );
      
      if (index == -1) throw Exception('Perfil não encontrado');

      _profiles[index] = updatedProfile;
      
      // Atualiza Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profiles': _profiles.map((p) => p.toMap()).toList(),
      });

      // Atualiza perfil ativo se for o mesmo
      if (_activeProfile?.profileId == updatedProfile.profileId) {
        _activeProfile = updatedProfile;
      }

      _error = null;
    } catch (e) {
      _error = 'Erro ao atualizar perfil: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove perfil
  Future<void> removeProfile(String profileId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    if (_profiles.length <= 1) {
      throw Exception('Não é possível remover o único perfil');
    }

    _isLoading = true;
    notifyListeners();

    try {
      _profiles.removeWhere((p) => p.profileId == profileId);
      
      // Se removeu o perfil ativo, define outro
      if (_activeProfile?.profileId == profileId) {
        _activeProfile = _profiles.first;
      }

      // Atualiza Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profiles': _profiles.map((p) => p.toMap()).toList(),
        'activeProfileId': _activeProfile!.profileId,
      });

      _error = null;
    } catch (e) {
      _error = 'Erro ao remover perfil: $e';
      debugPrint(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza activeProfileId no Firestore
  Future<void> _setActiveProfileId(String profileId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'activeProfileId': profileId});
  }

  /// Limpa estado (logout)
  void clear() {
    _activeProfile = null;
    _profiles = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
```

### 1.3. Configurar no main.dart

```dart
// lib/main.dart
import 'package:provider/provider.dart';
import 'providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        // Adicione outros providers aqui
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializa ProfileProvider após autenticação
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        profileProvider.initialize();
      } else {
        profileProvider.clear();
      }
    });

    return MaterialApp(
      title: 'Tô Sem Banda',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
```

### 1.4. Usar no ProfileSwitcherBottomSheet

```dart
// lib/widgets/profile_switcher_bottom_sheet.dart
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileSwitcherBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profileProvider.error != null) {
          return Center(child: Text('Erro: ${profileProvider.error}'));
        }

        if (!profileProvider.hasProfiles) {
          return _buildNoProfilesView(context, profileProvider);
        }

        return _buildProfilesList(context, profileProvider);
      },
    );
  }

  Widget _buildProfilesList(BuildContext context, ProfileProvider provider) {
    return ListView.builder(
      itemCount: provider.profiles.length,
      itemBuilder: (context, index) {
        final profile = provider.profiles[index];
        final isActive = profile.profileId == provider.activeProfile?.profileId;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profile.photoUrl != null
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: profile.photoUrl == null
                ? Icon(profile.isBand ? Icons.groups : Icons.person)
                : null,
          ),
          title: Text(profile.name),
          subtitle: Text(profile.isBand ? 'Banda' : 'Músico'),
          trailing: isActive ? const Icon(Icons.check_circle) : null,
          onTap: isActive
              ? null
              : () async {
                  try {
                    await provider.switchProfile(profile.profileId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Perfil "${profile.name}" ativado')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao trocar perfil: $e')),
                      );
                    }
                  }
                },
        );
      },
    );
  }
}
```

### 1.5. Usar na HomePage

```dart
// lib/pages/home_page.dart
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class HomePage extends StatefulWidget {
  // ...
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    
    // Escuta mudanças no perfil ativo
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.addListener(_onProfileChanged);
    
    _initLocationAndSearch();
  }

  void _onProfileChanged() {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final activeProfile = profileProvider.activeProfile;
    
    if (activeProfile == null) return;

    // Atualiza filtros baseados no perfil ativo
    setState(() {
      // Aplicar cidade do perfil
      if (activeProfile.city != null && activeProfile.city!.isNotEmpty) {
        _cityController.text = activeProfile.city!;
      }
      
      // Aplicar instrumentos (se músico)
      if (!activeProfile.isBand) {
        _selectedInstruments = activeProfile.instruments.toSet();
      }
      
      // Aplicar gêneros
      _selectedGenres = activeProfile.genres.toSet();
      
      // Aplicar nível
      if (activeProfile.level != null && activeProfile.level!.isNotEmpty) {
        _selectedLevel = activeProfile.level;
      }
      
      // Atualizar localização
      if (activeProfile.latitude != null && activeProfile.longitude != null) {
        _currentPos = LatLng(activeProfile.latitude!, activeProfile.longitude!);
      }
    });

    // Recarregar dados
    _runSearch();
    _loadNextPagePosts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // Exibir indicador de carregamento se necessário
        if (profileProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Redirecionar para criação de perfil se não houver nenhum
        if (!profileProvider.hasProfiles) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileFormPage()),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(profileProvider.activeProfile?.name ?? 'Tô Sem Banda'),
            // ...
          ),
          body: _buildBody(),
        );
      },
    );
  }
}
```

---

## Opção 2: Riverpod (Mais moderno e robusto)

### 2.1. Adicionar dependência

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.4.9
```

### 2.2. Criar ProfileNotifier

```dart
// lib/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileState {
  final UserProfile? activeProfile;
  final List<UserProfile> profiles;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.activeProfile,
    this.profiles = const [],
    this.isLoading = false,
    this.error,
  });

  bool get hasProfiles => profiles.isNotEmpty;

  ProfileState copyWith({
    UserProfile? activeProfile,
    List<UserProfile>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      activeProfile: activeProfile ?? this.activeProfile,
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState());

  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(error: 'Usuário não autenticado');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        state = state.copyWith(
          isLoading: false,
          error: 'Documento do usuário não encontrado',
        );
        return;
      }

      final data = userDoc.data()!;
      final activeProfileId = data['activeProfileId'] as String?;
      final profilesList = data['profiles'] as List<dynamic>?;

      if (profilesList != null) {
        final profiles = profilesList
            .map((p) => UserProfile.fromMap(p as Map<String, dynamic>))
            .toList();

        UserProfile? activeProfile;
        if (activeProfileId != null) {
          activeProfile = profiles.firstWhere(
            (p) => p.profileId == activeProfileId,
            orElse: () => profiles.first,
          );
        } else if (profiles.isNotEmpty) {
          activeProfile = profiles.first;
          await _setActiveProfileId(activeProfile.profileId);
        }

        state = state.copyWith(
          profiles: profiles,
          activeProfile: activeProfile,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar perfis: $e',
      );
    }
  }

  Future<void> switchProfile(String profileId) async {
    final profile = state.profiles.firstWhere(
      (p) => p.profileId == profileId,
      orElse: () => throw Exception('Perfil não encontrado'),
    );

    state = state.copyWith(isLoading: true);

    try {
      await _setActiveProfileId(profileId);
      state = state.copyWith(
        activeProfile: profile,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao trocar perfil: $e',
      );
      rethrow;
    }
  }

  Future<void> addProfile(UserProfile profile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    state = state.copyWith(isLoading: true);

    try {
      final profiles = [...state.profiles, profile];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profiles': profiles.map((p) => p.toMap()).toList(),
        'activeProfileId': profile.profileId,
      });

      state = state.copyWith(
        profiles: profiles,
        activeProfile: profile,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao adicionar perfil: $e',
      );
      rethrow;
    }
  }

  Future<void> _setActiveProfileId(String profileId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'activeProfileId': profileId});
  }

  void clear() {
    state = ProfileState();
  }
}

// Provider global
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
```

### 2.3. Configurar no main.dart

```dart
// lib/main.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializa quando usuário autentica
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        ref.read(profileProvider.notifier).initialize();
      } else {
        ref.read(profileProvider.notifier).clear();
      }
    });

    return MaterialApp(
      title: 'Tô Sem Banda',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
```

### 2.4. Usar no ProfileSwitcherBottomSheet

```dart
// lib/widgets/profile_switcher_bottom_sheet.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class ProfileSwitcherBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    if (profileState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileState.error != null) {
      return Center(child: Text('Erro: ${profileState.error}'));
    }

    if (!profileState.hasProfiles) {
      return _buildNoProfilesView(context, ref);
    }

    return _buildProfilesList(context, ref, profileState);
  }

  Widget _buildProfilesList(
    BuildContext context,
    WidgetRef ref,
    ProfileState state,
  ) {
    return ListView.builder(
      itemCount: state.profiles.length,
      itemBuilder: (context, index) {
        final profile = state.profiles[index];
        final isActive = profile.profileId == state.activeProfile?.profileId;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profile.photoUrl != null
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: profile.photoUrl == null
                ? Icon(profile.isBand ? Icons.groups : Icons.person)
                : null,
          ),
          title: Text(profile.name),
          subtitle: Text(profile.isBand ? 'Banda' : 'Músico'),
          trailing: isActive ? const Icon(Icons.check_circle) : null,
          onTap: isActive
              ? null
              : () async {
                  try {
                    await ref
                        .read(profileProvider.notifier)
                        .switchProfile(profile.profileId);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Perfil "${profile.name}" ativado')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao trocar perfil: $e')),
                      );
                    }
                  }
                },
        );
      },
    );
  }
}
```

---

## Benefícios da Implementação

### ✅ Centralização
- Estado do perfil ativo em um único lugar
- Fácil acesso em qualquer tela

### ✅ Reatividade
- Widgets atualizam automaticamente quando perfil muda
- Sem necessidade de callbacks complexos

### ✅ Performance
- Rebuild otimizado (apenas widgets que precisam)
- Cache automático de dados

### ✅ Manutenibilidade
- Código mais limpo e organizado
- Fácil adicionar novos recursos

### ✅ Testabilidade
- Fácil mockar e testar isoladamente
- Testes unitários simplificados

---

## Próximos Passos

1. Escolher entre Provider ou Riverpod
2. Implementar o provider escolhido
3. Refatorar telas existentes para usar o provider
4. Adicionar testes unitários
5. Implementar persistência local (opcional, com Hive ou SharedPreferences)

## Conclusão

Ambas as soluções são excelentes. **Provider** é mais simples e adequado se você já está familiarizado com ele. **Riverpod** é mais moderno, com melhor performance e type-safety, sendo recomendado para projetos novos ou refatorações maiores.
