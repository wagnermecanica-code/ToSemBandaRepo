# PRÓXIMOS PASSOS - Completar Migração

## ✅ O Que Foi Feito

1. ✅ **Models Criados**
   - `lib/models/profile.dart` - Model completo com GeoPoint
   - `lib/models/app_user.dart` - Metadata mínimo

2. ✅ **Services Refatorados**

   - `lib/services/profile_service.dart` - Métodos create/update/delete (REFATORADO)

3. ✅ **Firestore**
   - `firestore.rules` - Rules atualizadas para `profiles/{profileId}`
   - Firestore limpo (executado)
   - Rules deployed (executado)

4. ✅ **ProfileFormPage** - Refatorado completamente
   - Usa novo model `Profile`
   - Cria em `profiles/{profileId}`
   - Campos obrigatórios: city, location (GeoPoint)
   - Busca localização automaticamente

5. ✅ **HomePage** - Parcialmente refatorado
   - Imports atualizados
   - ActiveProfileNotifier adicionado
   - Listener `_onProfileChanged()` criado
   - **FALTA**: Atualizar queries para usar `_activeProfile`

## ⏳ O Que Falta Fazer

### 1. Testar Criação de Perfil

```bash
flutter run
```

**Fluxo esperado:**
1. App abre
2. Pede para criar perfil (primeira vez)
3. Preencher: Nome, Tipo, Cidade, Idade, Nível
4. Localização buscada automaticamente
5. Salvar → cria em `profiles/{profileId}`

**Verificar no Firebase Console:**
- `profiles/{profileId}` deve existir
- `users/{uid}` deve ter apenas `activeProfileId` + array `profiles` resumido

### 2. Refatorar HomePage Queries (CRÍTICO)

Localizar método que faz query de posts (linha ~560) e garantir que:

**A. Usa perfil ativo:**
```dart
final activeProfile = _activeProfile;
if (activeProfile == null) return;

// Filtrar por cidade do perfil ativo
query = query.where('city', isEqualTo: activeProfile.city);
```

**B. Filtra posts próprios:**
```dart
for (final doc in snap.docs) {
  final postAuthorProfileId = data['authorProfileId'] ?? '';
  
  // CRÍTICO: Nunca mostrar posts do perfil ativo
  if (postAuthorProfileId == activeProfile.profileId) {
    continue; // Pular
  }
  
  // ... resto do processamento
}
```

### 3. Refatorar ProfileSwitcherBottomSheet

**Arquivo:** `lib/widgets/profile_switcher_bottom_sheet.dart`

**Mudanças:**
```dart
// ANTES
Navigator.pop(context, profileId);

// DEPOIS
await ProfileService().switchActiveProfile(profileId);
ProfileTransitionOverlay.show(
  context,
  profileName: profile.name,
  isBand: profile.isBand,
  photoUrl: profile.photoUrl,
  onComplete: () {
    Navigator.pop(context);
  },
);
```

### 4. Refatorar BottomNavScaffold Avatar

**Arquivo:** `lib/pages/bottom_nav_scaffold.dart`

**Mudanças:**
```dart
// Envolver avatar com ValueListenableBuilder
ValueListenableBuilder<Profile?>(
  valueListenable: ActiveProfileNotifier(),
  builder: (context, activeProfile, child) {
    if (activeProfile == null) return Icon(Icons.person);
    
    return CircleAvatar(
      backgroundImage: activeProfile.photoUrl != null 
          ? NetworkImage(activeProfile.photoUrl!)
          : null,
      child: activeProfile.photoUrl == null
          ? Icon(activeProfile.isBand ? Icons.groups : Icons.person)
          : null,
    );
  },
)
```

### 5. Testar Fluxos Completos

**A. Criar Post**
- Criar post
- Verificar `authorProfileId` correto no Firestore
- Posts próprios NÃO devem aparecer na HomePage

**B. Criar Segundo Perfil**
- Abrir ProfileSwitcherBottomSheet
- Criar novo perfil
- Trocar entre perfis
- Verificar:
  - HomePage recarrega
  - Mapa recentraliza
  - Posts filtrados corretamente
  - Notificações isoladas

**C. Demonstrar Interesse**
- Mostrar interesse em post
- Verificar notificação criada com `recipientProfileId` correto
- Trocar perfil → notificação não deve aparecer

## 📚 Arquivos de Referência

- `PROFILE_MIGRATION_GUIDE.md` - Guia completo
- `lib/examples/profile_system_examples.dart` - 8 exemplos de uso
- `.github/copilot-instructions.md` - Documentação atualizada

## 🐛 Se Encontrar Erros

### "Missing index"
```bash
firebase deploy --only firestore:indexes
```

### "Permission denied"
```bash
# Verificar rules deployadas
firebase deploy --only firestore:rules
```

### "activeProfile is null"
- Verificar se perfil foi criado corretamente
- Checar Firebase Console → `profiles/{profileId}`
- Checar `users/{uid}.activeProfileId`

### HomePage não recarrega ao trocar perfil
- Verificar `_onProfileChanged()` está sendo chamado
- Adicionar `debugPrint` para debug
- Verificar `_profileNotifier.addListener()` no initState

## 🎯 Ordem Recomendada

1. **Testar criação de perfil** (deve funcionar)
2. **Se der erro** → me avise qual erro
3. **Se funcionar** → testar HomePage (posts podem não aparecer)
4. **Refatorar HomePage queries** (seguir instruções acima)
5. **Testar posts** aparecem (exceto próprios)
6. **Refatorar ProfileSwitcher** + BottomNav
7. **Testar troca de perfis**

---

**Quer que eu:**
1. 🔧 Continue refatorando automaticamente (HomePage completo + outras páginas)
2. 🧪 Você testa agora e me avisa se deu erro
3. 📝 Eu crio exemplo específico de como refatorar HomePage queries

Escolha e me avise!
