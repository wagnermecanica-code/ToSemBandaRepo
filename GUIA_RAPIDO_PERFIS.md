# 🚀 Guia Rápido - Sistema de Múltiplos Perfis

## ✨ Funcionalidades Novas

### 1️⃣ Editar Perfil
1. Abra o menu de perfis (ícone no AppBar)
2. Clique nos **3 pontos (⋮)** ao lado do perfil
3. Selecione **"Editar"**
4. Faça as alterações
5. Clique em **"Salvar"**

### 2️⃣ Excluir Perfil
1. Abra o menu de perfis
2. Clique nos **3 pontos (⋮)** ao lado do perfil
3. Selecione **"Excluir"**
4. Confirme a exclusão

⚠️ **Restrições:**
- Não é possível excluir o perfil principal
- Você precisa ter pelo menos 1 perfil

### 3️⃣ Trocar de Perfil
1. Abra o menu de perfis
2. Clique no perfil desejado
3. Aguarde a animação de transição
4. ✅ Perfil trocado automaticamente!

---

## 💻 Para Desenvolvedores

### Usando ProfileService

```dart
import 'package:to_sem_banda/services/profile_service.dart';

final profileService = ProfileService();

// Buscar todos os perfis
final profiles = await profileService.getAllProfiles();

// Buscar perfil ativo
final activeProfile = await profileService.getActiveProfile();

// Trocar perfil
await profileService.setActiveProfile(profileId);

// Adicionar perfil
final newId = await profileService.addProfile(userProfile);

// Atualizar perfil
await profileService.updateProfile(userProfile);

// Excluir perfil
await profileService.deleteProfile(profileId);
```

### Animação de Transição

```dart
import 'package:to_sem_banda/widgets/profile_transition_overlay.dart';

ProfileTransitionOverlay.show(
  context,
  profileName: 'João Silva',
  isBand: false,
  photoUrl: 'https://...',
  onComplete: () {
    // Código executado após animação
  },
);
```

---

## 📁 Arquivos Criados/Modificados

### ✅ Criados:
- `lib/services/profile_service.dart`
- `lib/widgets/profile_transition_overlay.dart`
- `MULTIPLE_PROFILES_IMPROVEMENTS_V2.md`
- `GUIA_RAPIDO_PERFIS.md`

### ✏️ Modificados:
- `lib/pages/profile_form_page.dart`
- `lib/widgets/profile_switcher_bottom_sheet.dart`

---

## 🎯 Próximos Passos

1. **Testar as novas funcionalidades**
   ```bash
   flutter run
   ```

2. **Implementar Provider** (opcional)
   - Ver `PROFILE_STATE_MANAGEMENT.md`
   - Reduz leituras do Firestore

3. **Adicionar testes**
   ```dart
   // test/services/profile_service_test.dart
   test('should get all profiles', () async {
     final service = ProfileService();
     final profiles = await service.getAllProfiles();
     expect(profiles, isNotEmpty);
   });
   ```

---

## 🐛 Troubleshooting

### Erro ao excluir perfil
- ✅ Verifique se não é o perfil principal
- ✅ Verifique se tem mais de 1 perfil

### Perfil não atualiza após editar
- ✅ Verifique se `ProfileFormPage` retorna `profileId`
- ✅ Verifique callback em `ProfileSwitcherBottomSheet`

### Animação não aparece
- ✅ Verifique import de `profile_transition_overlay.dart`
- ✅ Verifique se context está montado

---

## 📚 Documentação Completa

Ver `MULTIPLE_PROFILES_IMPROVEMENTS_V2.md` para detalhes técnicos completos.
