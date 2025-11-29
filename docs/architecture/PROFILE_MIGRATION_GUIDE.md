# Migração para Sistema de Múltiplos Perfis (Instagram-Style)

## 🚨 Status: IMPLEMENTADO - REQUER MIGRAÇÃO DE DADOS

Data: 17 de novembro de 2025

## O que mudou?

### Arquitetura Antiga
```
users/{uid}
├── name, photoUrl, city, instruments, genres, etc. (perfil principal)
├── profiles: [                // Array com perfis secundários
    { profileId, name, photoUrl, city, instruments, ... }
]
└── activeProfileId
```

### Nova Arquitetura (Instagram-Style)
```
users/{uid}                    // Apenas metadata
├── uid, email, createdAt
├── activeProfileId
└── profiles: [                // Apenas resumo para switcher
    { profileId, name, photoUrl, type, city }
]

profiles/{profileId}           // Dados completos isolados
├── uid                        // Dono da conta
├── name, photoUrl, isBand
├── city, location (GeoPoint)
├── instruments[], genres[]
├── level, age, bio, youtubeLink
└── createdAt, updatedAt
```

## Por que migrar?

### Problemas Resolvidos
1. ✅ **Isolamento total**: Perfis não compartilham posts/notificações/chats
2. ✅ **Performance**: Queries filtram por `profileId` direto, não precisam carregar documento inteiro do user
3. ✅ **Escalabilidade**: `users/{uid}` não cresce com múltiplos perfis
4. ✅ **Troca instantânea**: Apenas `activeProfileId` muda, dados já estão isolados
5. ✅ **Segurança**: Firestore Rules podem validar `uid` field em cada perfil

### Bugs Eliminados
- ❌ Ver posts de outro perfil ao trocar
- ❌ Notificações aparecem misturadas
- ❌ Chats aparecem para perfil errado
- ❌ Botão "Interesse" no próprio post
- ❌ Mapa fica na cidade errada

## Como Migrar

### 1. Backup (CRÍTICO)
```bash
# Exportar dados antes de migrar
firebase firestore:export gs://to-sem-banda-83e19.appspot.com/backups/pre-migration-$(date +%Y%m%d)
```

### 2. Executar Script de Migração
```bash
cd /Users/wagneroliveira/to_sem_banda

# Migrar dados (cria profiles/{profileId} e atualiza users/{uid})
dart run scripts/migrate_profiles_to_collection.dart
```

**O que o script faz**:
- Lê todos os documentos em `users/{uid}`
- Cria documentos em `profiles/{profileId}` com dados completos
- Atualiza `users/{uid}` com apenas resumos
- Remove campos duplicados de `users/{uid}`
- Mantém `activeProfileId` intacto

### 3. Deploy Firestore Rules
```bash
# Deploy das novas rules que protegem profiles/{profileId}
firebase deploy --only firestore:rules
```

### 4. Deploy Firestore Indexes
```bash
# Nenhum índice novo necessário (já existem para authorProfileId, recipientProfileId)
firebase deploy --only firestore:indexes
```

### 5. Validar Migração
```dart
// Testar no app:
// 1. Login → verificar perfil ativo carrega
// 2. Trocar perfil → verificar HomePage recarrega
// 3. Criar post → verificar authorProfileId correto
// 4. Ver notificações → verificar isolation por recipientProfileId
// 5. Chat → verificar participantProfiles correto
```

## Novos Componentes

### Models
- ✅ `lib/models/profile.dart` - Modelo completo de perfil
- ✅ `lib/models/app_user.dart` - Modelo do documento user (metadata mínimo)

### Services

- ✅ `lib/services/profile_service.dart` - CRUD de perfis (refatorado)
  - `switchActiveProfile(profileId)` - Troca de perfil
  - `activeProfileStream` - Stream do perfil ativo
  - `createProfile()`, `updateProfile()`, `deleteProfile()`
  - `getAllProfiles()`, `getProfileById()`

### Widgets
- ✅ `lib/widgets/profile_transition_overlay.dart` - Animação de troca (300ms)

## Integração nas Pages

### HomePage (CRÍTICO)
```dart
// ANTES
final userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
final activeProfileId = userData['activeProfileId'];
// ... queries manuais

// DEPOIS
final activeProfile = ActiveProfileNotifier().activeProfile;
if (activeProfile == null) return;

query = query
  .where('city', isEqualTo: activeProfile.city)
  .where('authorProfileId', isNotEqualTo: activeProfile.profileId); // NUNCA mostrar próprio
```

### NotificationsPage
```dart
// ANTES
.where('recipientProfileId', isEqualTo: someManualId)

// DEPOIS
final activeProfile = ActiveProfileNotifier().activeProfile;
.where('recipientProfileId', isEqualTo: activeProfile!.profileId)
```

### MessagesPage
```dart
// ANTES
.where('participantProfiles', arrayContains: manualProfileId)

// DEPOIS
final activeProfile = ActiveProfileNotifier().activeProfile;
.where('participantProfiles', arrayContains: activeProfile!.profileId)
```

### ProfileSwitcherBottomSheet
```dart
// ANTES
Navigator.pop(context, profileId);
// Callback manual para recarregar

// DEPOIS
await ProfileService().switchActiveProfile(profileId);
ProfileTransitionOverlay.show(
  context,
  profileName: profile.name,
  isBand: profile.isBand,
  photoUrl: profile.photoUrl,
  onComplete: () {
    // ActiveProfileNotifier já notificou todos os widgets
    // HomePage já recarregou automaticamente
  },
);
```

## Rollback (se necessário)

Se algo der errado, você pode reverter:

```bash
# 1. Restaurar backup
firebase firestore:import gs://to-sem-banda-83e19.appspot.com/backups/pre-migration-YYYYMMDD

# 2. Reverter rules
git checkout HEAD~1 firestore.rules
firebase deploy --only firestore:rules

# 3. Reverter código
git stash  # ou git reset --hard HEAD~1
```

## Checklist Pós-Migração

### Funcionalidades Críticas
- [ ] Login → perfil ativo carrega automaticamente
- [ ] Trocar perfil → animação smooth 300ms
- [ ] HomePage → posts do perfil ativo NÃO aparecem
- [ ] HomePage → mapa centraliza na nova city
- [ ] Notificações → só do perfil ativo
- [ ] Mensagens → só conversas do perfil ativo
- [ ] Criar post → usa activeProfileId como authorProfileId
- [ ] Demonstrar interesse → cria notificação com recipientProfileId correto
- [ ] Chat → participantProfiles correto
- [ ] Avatar bottom nav → atualiza em tempo real

### Performance
- [ ] HomePage query < 1s (filtro por city + authorProfileId)
- [ ] Troca de perfil < 500ms (ActiveProfileNotifier + overlay)
- [ ] Notificações query < 500ms (índice recipientProfileId + createdAt)

### Segurança
- [ ] Firestore Rules bloqueiam edição de perfil de outro usuário
- [ ] profileId não pode ser alterado após criação
- [ ] uid field em profiles/{profileId} imutável

## Próximos Passos

1. ✅ Executar migração em ambiente de dev/staging PRIMEIRO
2. ✅ Testar todos os fluxos críticos
3. ✅ Monitorar logs do Firestore por 24h
4. ⏳ Migrar produção com janela de manutenção
5. ⏳ Monitorar métricas de performance
6. ⏳ Coletar feedback de usuários

## Suporte

Se encontrar problemas:
1. Verificar logs: `firebase firestore:logs`
2. Verificar rules: `firebase deploy --only firestore:rules --dry-run`
3. Restaurar backup se necessário
4. Contatar: [seu email/slack]

---

**Data de implementação**: 17 de novembro de 2025  
**Implementado por**: GitHub Copilot + Wagner Oliveira  
**Status**: ✅ Código pronto, ⏳ Aguardando migração de dados
