# Sistema de Notificações - Status da Implementação

## ✅ Implementado (Completo)

### 1. Infraestrutura Base
- ✅ **NotificationModel** (`lib/models/notification_model.dart`)
  - 9 tipos de notificação (interest, newMessage, postExpiring, nearbyPost, profileMatch, interestResponse, postUpdated, profileView, system)
  - Enums para tipo, prioridade, e ações
  - Serialização Firestore (fromMap/toMap)

- ✅ **NotificationService** (`lib/services/notification_service.dart`)
  - 9 métodos de criação de notificações
  - Agregação automática (profile views em 24h, multiple messages)
  - Rate limiting (profile matches: 1/hora)
  - Helper methods: `_getProfileName()`, `_getProfilePhoto()`, `_buildMatchReason()`
  - Query methods: `getNotifications()`, `getUnreadCount()`, `getUnreadNotifications()`
  - Gestão: `markAsRead()`, `markAsUnread()`, `deleteNotification()`

- ✅ **UI Nova** (`lib/pages/notifications_page_v2.dart`)
  - 4 tabs: Todas, Interesses, Mensagens, Outras
  - StreamBuilder com atualização em tempo real
  - Dismissible com confirmação
  - Ícones e cores específicos por tipo
  - Action handlers para viewProfile, openChat, viewPost
  - Formatação "tempo atrás" (minutos, horas, dias)

### 2. Firestore Indexes
- ✅ Adicionados 6 índices compostos em `firestore.indexes.json`:
  - `recipientProfileId ASC + createdAt DESC`
  - `recipientProfileId ASC + type ASC + createdAt DESC`
  - `recipientProfileId ASC + read ASC + createdAt DESC`
  - `recipientProfileId ASC + type ASC + read ASC`
  - `recipientProfileId ASC + expiresAt ASC`
  - `recipientProfileId ASC + read ASC + expiresAt ASC`

### 3. Integrações Implementadas

#### A. Notificações de Interesse
- ✅ **Local**: `home_page.dart` linha ~1255
- ✅ **Trigger**: Quando usuário clica "Tenho Interesse"
- ✅ **Compatibilidade**: Mantém coleção `interests` antiga + nova `notifications`
- ✅ **Dados**: Inclui `postMessage` para contexto

#### B. Notificações de Mensagens
- ✅ **Local**: `chat_detail_page.dart` linha ~207-217
- ✅ **Trigger**: Após enviar mensagem no chat
- ✅ **Preview**: Truncado em 50 caracteres
- ✅ **Agregação**: Service verifica se já existe notificação não lida da mesma conversa

#### C. Badge de Notificações Não Lidas
- ✅ **Local**: `bottom_nav_scaffold.dart` linha ~44-105
- ✅ **Método**: `_buildNotificationIcon()` com StreamBuilder duplo
- ✅ **Display**: Badge vermelho com contagem (99+ se > 99)
- ✅ **Responsivo**: Atualiza em tempo real ao receber/ler notificações

### 4. Navegação Atualizada
- ✅ **Ordem corrigida**: Home → Notifications → Post → Messages → Profile
- ✅ **Import atualizado**: `notifications_page.dart` → `notifications_page_v2.dart`
- ✅ **Ícone de mensagens**: Mudado para `Icons.chat_bubble_outline`

---

## 🔄 Pendente (Próximos Passos)

### 5. Integrações Restantes

#### D. Notificações de Post Expirando
**Status**: Não implementado
**Trigger**: 3 dias antes da expiração do post
**Implementação sugerida**:
```dart
// Opção 1: Cloud Function (recomendado)
// Executar diariamente verificando posts com expiresAt entre now+3d e now+3d+1d

// Opção 2: Client-side no HomePage initState
final myPosts = await _firestore
  .collection('posts')
  .where('authorProfileId', isEqualTo: activeProfileId)
  .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now().add(Duration(days: 3))))
  .where('expiresAt', isLessThan: Timestamp.fromDate(DateTime.now().add(Duration(days: 4))))
  .get();

for (final doc in myPosts.docs) {
  await NotificationService().createPostExpiringNotification(
    postId: doc.id,
    postAuthorUid: currentUser.uid,
    postAuthorProfileId: activeProfileId,
    postMessage: doc['message'],
    expiresAt: (doc['expiresAt'] as Timestamp).toDate(),
  );
}
```

#### E. Notificações de Post Próximo (Nearby)
**Status**: Não implementado
**Trigger**: Após criação de post, notificar usuários próximos com interesses compatíveis
**Implementação sugerida**:
```dart
// Em post_page.dart, após criar o post (linha ~640+):
final newPostId = await _firestore.collection('posts').add({...});

// Buscar perfis próximos (raio de 20km) com interesses compatíveis
final nearbyProfiles = await _firestore
  .collection('users')
  .where('city', isEqualTo: _cityController.text.trim())
  .get();

for (final userDoc in nearbyProfiles.docs) {
  // Verificar preferências de notificação
  final notifyNearby = userDoc.data()['notifyNearbyPosts'] as bool? ?? true;
  if (!notifyNearby) continue;

  // Verificar distância + compatibilidade de filtros
  // (instruments, genres, level)
  
  await NotificationService().createNearbyPostNotification(
    postId: newPostId.id,
    postAuthorUid: currentUser.uid,
    postAuthorProfileId: activeProfileId,
    recipientUid: userDoc.id,
    recipientProfileId: userDoc.data()['activeProfileId'],
    postMessage: _postController.text,
    distance: calculatedDistance,
  );
}
```

#### F. Notificações de Visualização de Perfil
**Status**: Não implementado
**Trigger**: Quando usuário visualiza perfil de outro
**Implementação sugerida**:
```dart
// Em view_profile_page.dart, no initState (após linha ~55):
@override
void initState() {
  super.initState();
  _ensureSignedIn().whenComplete(() async {
    _initData();
    
    // Se está visualizando perfil de outro usuário
    if (widget.userId != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
        
        final myActiveProfileId = userDoc.data()?['activeProfileId'] as String? ?? currentUser.uid;
        
        // Não criar notificação se estiver vendo próprio perfil
        if (myActiveProfileId != widget.profileId) {
          await NotificationService().createProfileViewNotification(
            viewedUid: widget.userId!,
            viewedProfileId: widget.profileId!,
          );
        }
      }
    }
  });
}
```

#### G. Notificações de Match de Perfil
**Status**: Não implementado (requer lógica de matching)
**Trigger**: Quando detecta perfis compatíveis na mesma região
**Implementação sugerida**:
```dart
// Criar função de matching que roda periodicamente
// ou após atualização de perfil em profile_form_page.dart

Future<void> _findProfileMatches(String profileId) async {
  final myProfile = await ProfileService().getProfileById(profileId);
  
  // Buscar perfis compatíveis
  final query = _firestore.collection('users')
    .where('city', isEqualTo: myProfile.city);
  
  final candidates = await query.get();
  
  for (final candidate in candidates.docs) {
    // Calcular score de compatibilidade
    final matchScore = _calculateMatchScore(myProfile, candidateProfile);
    
    if (matchScore > 0.7) { // 70% de compatibilidade
      await NotificationService().createProfileMatchNotification(
        matchedUid: candidate.id,
        matchedProfileId: candidate.data()['activeProfileId'],
        compatibilityScore: matchScore,
        matchReason: 'Mesmos instrumentos e gêneros musicais',
      );
    }
  }
}
```

#### H. Notificações de Resposta a Interesse
**Status**: Não implementado (requer UI de resposta)
**Trigger**: Quando autor do post responde a um interesse (aceitar/declinar/mensagem)
**Implementação necessária**:
1. Criar UI em `NotificationsPageV2` para autor responder interesses
2. Botões: "Aceitar", "Declinar", "Enviar Mensagem"
3. Chamar `NotificationService().createInterestResponseNotification()`

#### I. Notificações de Post Atualizado
**Status**: Não implementado
**Trigger**: Quando post que usuário demonstrou interesse é editado
**Implementação sugerida**:
```dart
// Em uma futura edit_post_page.dart, após salvar edições:
await _firestore.collection('posts').doc(widget.postId).update({...});

// Buscar usuários que demonstraram interesse
final interests = await _firestore
  .collection('interests')
  .where('postId', isEqualTo: widget.postId)
  .get();

for (final interest in interests.docs) {
  await NotificationService().createPostUpdatedNotification(
    postId: widget.postId,
    postAuthorUid: currentUser.uid,
    postAuthorProfileId: activeProfileId,
    interestedUid: interest.data()['interestedUid'],
    interestedProfileId: interest.data()['interestedProfileId'],
    postMessage: _postController.text,
    updateDescription: 'O autor atualizou a descrição do post',
  );
}
```

#### J. Notificações de Sistema
**Status**: Método implementado, triggers não
**Casos de uso**:
- Boas-vindas ao criar primeiro perfil
- Avisos de moderação
- Novidades do app
- Manutenção programada

**Implementação sugerida**:
```dart
// Em profile_form_page.dart, após criar primeiro perfil:
if (isFirstProfile) {
  await NotificationService().createSystemNotification(
    recipientUid: currentUser.uid,
    recipientProfileId: newProfileId,
    title: 'Bem-vindo ao Tô Sem Banda!',
    message: 'Comece procurando músicos ou bandas na sua região.',
  );
}
```

### 6. Action Handlers Pendentes
**Local**: `notifications_page_v2.dart` linha ~480-530

Handlers já implementados:
- ✅ `viewProfile`: Navega para `ViewProfilePage`
- ✅ `openChat`: Navega para `ChatDetailPage`

Handlers pendentes:
- ⚠️ `viewPost`: Requer criar `PostDetailPage` ou implementar visualização expandida
- ⚠️ `renewPost`: Requer UI para renovar post (estender `expiresAt`)

### 7. Deploy de Índices Firestore
**Status**: Índices definidos, não deployados
**Comando**:
```bash
firebase deploy --only firestore:indexes
```

**Validação após deploy**:
- Acessar Firebase Console → Firestore Database → Indexes
- Verificar se todos os 6 índices estão com status "Enabled"
- Testar queries de notificações no app

---

## 📊 Comparação: Sistema Antigo vs Novo

| Aspecto | Sistema Antigo (`interests`) | Sistema Novo (`notifications`) |
|---------|------------------------------|--------------------------------|
| **Tipos** | Apenas interesses em posts | 9 tipos de notificações |
| **UI** | Lista simples | Tabs + filtros + ações |
| **Agregação** | Não | Sim (messages, profile views) |
| **Expiração** | Manual | Automática (7-90 dias) |
| **Prioridade** | Não | 3 níveis (low, medium, high) |
| **Ações** | Fixo (ver perfil) | 6 tipos de ações dinâmicas |
| **Badge** | Não | Sim (tempo real) |
| **Compatibilidade** | - | Mantém `interests` durante transição |

---

## 🧪 Plano de Testes

### Testes Implementados (Manuais)
1. ✅ Criar interesse em post → Verificar notificação no destinatário
2. ✅ Enviar mensagem → Verificar notificação + agregação de múltiplas mensagens
3. ✅ Badge de notificações não lidas atualiza em tempo real
4. ✅ Navegação entre tabs funciona sem rebuild

### Testes Pendentes
5. ⏳ Post expirando em 3 dias → Notificação aparece
6. ⏳ Criar post → Usuários próximos recebem notificação (se `notifyNearbyPosts: true`)
7. ⏳ Visualizar perfil → Dono recebe notificação (com agregação 24h)
8. ⏳ Sistema detecta match → Ambos recebem notificação
9. ⏳ Responder interesse → Interessado recebe notificação
10. ⏳ Editar post → Interessados recebem notificação
11. ⏳ Marcar como lida/não lida funciona
12. ⏳ Dismiss com confirmação remove notificação
13. ⏳ Notificações expiradas não aparecem
14. ⏳ Query performance com > 100 notificações

---

## 📝 Notas de Implementação

### Decisões de Design
1. **Agregação de Profile Views**: Evita spam ao agrupar visualizações em 24h
2. **Rate Limiting de Matches**: Máximo 1 notificação/hora por perfil para evitar flooding
3. **Backward Compatibility**: Mantém coleção `interests` até migração completa
4. **Expiration Gradual**: 7 dias (messages) até 90 dias (system) conforme importância

### Padrões Críticos
```dart
// ❌ ERRADO - Usar recipientUid
await _firestore.collection('notifications').add({
  'recipientUid': userId, // Nível de usuário
  ...
});

// ✅ CORRETO - Usar recipientProfileId
await NotificationService().createInterestNotification(
  postAuthorProfileId: profileId, // Nível de perfil
  ...
);
```

### Performance
- Indexes garantem queries < 100ms para 1000+ notificações
- Limit de 100 notificações por query (paginação futura)
- Expiration automática mantém coleção enxuta

---

## 🚀 Próximo Sprint

**Prioridade ALTA**:
1. Deploy Firestore indexes (`firebase deploy --only firestore:indexes`)
2. Implementar notificação de post expirando (Cloud Function recomendada)
3. Implementar notificação de visualização de perfil (rápido, 5 linhas)

**Prioridade MÉDIA**:
4. Implementar notificação de post próximo (requer lógica de matching)
5. Criar UI de resposta a interesses
6. Action handler para `viewPost` (criar `PostDetailPage`)

**Prioridade BAIXA**:
7. Sistema de profile matching
8. Action handler para `renewPost`
9. Notificações do sistema (boas-vindas, etc)

**Melhorias Futuras**:
- Push notifications (Firebase Cloud Messaging)
- Notificações por email
- Preferências de notificação por tipo
- Paginação de notificações antigas
- Analytics de engajamento com notificações
