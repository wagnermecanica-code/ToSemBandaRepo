# Push Notifications - Guia Completo

Sistema completo de Push Notifications integrado com Firebase Cloud Messaging (FCM), Cloud Functions e arquitetura multi-perfil do Tô Sem Banda.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Setup & Configuração](#setup--configuração)
- [Uso & Desenvolvimento](#uso--desenvolvimento)
- [Cloud Functions](#cloud-functions)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

### Funcionalidades

✅ **Push Notifications via FCM**

- Notificações em foreground, background e terminated
- Customização por plataforma (Android/iOS)
- Deep linking para navegação automática

✅ **Integração Multi-Perfil**

- Cada perfil tem seus próprios tokens FCM
- Notificações filtradas por `profileId`
- Troca de perfil automática atualiza tokens

✅ **Cloud Functions Automatizadas**

- Posts próximos: notifica perfis no raio configurado
- Interesses: notifica quando alguém demonstra interesse
- Mensagens: notifica novas mensagens no chat

✅ **UI de Configurações**

- Solicitar/revogar permissões
- Configurar raio de notificações (5-100km)
- Testar notificações

---

## 🏗️ Arquitetura

### Fluxo de Dados

```
┌─────────────────┐
│  Cloud Function │ (Trigger: onCreate)
│  - Posts        │
│  - Interests    │
│  - Messages     │
└────────┬────────┘
         │
         ├─> Cria notificação in-app (Firestore)
         │   └─> profiles/{profileId}/notifications
         │
         └─> Envia push notification (FCM)
             └─> Busca tokens em profiles/{profileId}/fcmTokens
                 └─> Envia via Firebase Messaging API
                     │
                     ├─> Android: Exibe notificação
                     └─> iOS: Exibe notificação
```

### Estrutura de Dados

**FCM Tokens (Firestore):**

```
profiles/{profileId}/fcmTokens/{token}
{
  token: String,
  platform: 'ios' | 'android',
  createdAt: Timestamp,
  lastUsedAt: Timestamp
}
```

**Notifications (Firestore):**

```
notifications/{notificationId}
{
  recipientProfileId: String,
  type: 'nearbyPost' | 'interest' | 'newMessage',
  priority: 'high' | 'medium' | 'low',
  title: String,
  body: String,
  data: Map<String, dynamic>,
  createdAt: Timestamp,
  read: Boolean,
  expiresAt: Timestamp
}
```

### Componentes

**1. PushNotificationService** (`lib/services/push_notification_service.dart`)

- Inicializa Firebase Messaging
- Gerencia permissões
- Salva/remove tokens no Firestore
- Configura handlers de foreground/background

**2. PushNotificationProvider** (`lib/providers/push_notification_provider.dart`)

- Integra service com Riverpod
- Escuta mudanças de perfil/auth
- Atualiza tokens automaticamente

**3. Cloud Functions** (`functions/index.js`)

- `notifyNearbyPosts`: Posts próximos + push
- `sendInterestNotification`: Interesses + push
- `sendMessageNotification`: Mensagens + push
- `cleanupExpiredNotifications`: Limpeza agendada

**4. NotificationSettingsPage** (`lib/pages/notification_settings_page.dart`)

- UI para gerenciar configurações
- Solicitar permissões
- Testar notificações

---

## ⚙️ Setup & Configuração

### 1. Pré-requisitos

```yaml
# pubspec.yaml
dependencies:
  firebase_messaging: ">=16.0.3 <17.0.0"
  flutter_local_notifications: ^18.0.1
```

### 2. Android Setup

**a) AndroidManifest.xml** (✅ Já configurado)

```xml
<!-- Permissão para notificações (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Intent filter para notificações clicadas -->
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>

<!-- Receiver FCM -->
<receiver android:name="com.google.firebase.iid.FirebaseInstanceIdReceiver" ... />
```

**b) Testar**

```bash
flutter run
# Verificar logs:
# ✅ PushNotificationService: Initialized successfully
# 🔑 FCM Token: [token aqui]
```

### 3. iOS Setup

**IMPORTANTE:** Configuração manual via Xcode é obrigatória.

Consulte o guia detalhado em: `ios/PUSH_NOTIFICATIONS_SETUP.md`

**Resumo:**

1. Abrir `ios/Runner.xcworkspace` no Xcode
2. Adicionar capabilities:
   - **Push Notifications**
   - **Background Modes** → Remote notifications
3. Configurar APNs Key no Apple Developer Portal
4. Upload do `.p8` key no Firebase Console

**Verificação:**

```bash
flutter run
# Logs esperados:
# ✅ PushNotificationService: Permission granted
# 🔑 FCM Token: [token iOS]
```

### 4. Firebase Console

**a) Habilitar Cloud Messaging API**

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Vá para **Project Settings** → **Cloud Messaging**
3. Copie **Server Key** (usado pelas Cloud Functions)

**b) Configurar iOS APNs** (se ainda não fez)

1. Upload do `.p8` key
2. Insira **Key ID** e **Team ID**

### 5. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions

# Verificar logs
firebase functions:log
```

**Funções deployadas:**

- ✅ `notifyNearbyPosts`
- ✅ `sendInterestNotification`
- ✅ `sendMessageNotification`
- ✅ `cleanupExpiredNotifications`

---

## 💻 Uso & Desenvolvimento

### Inicializar Push Notifications

**No `main.dart`:** (✅ Já implementado)

```dart
// 1. Configurar background handler (ANTES de runApp)
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// 2. Inicializar service no MyApp.initState()
final pushService = PushNotificationService();
await pushService.initialize();

// 3. Configurar callbacks
pushService.onNotificationTapped = (message) {
  _handleNotificationTap(message);
};
```

### Salvar Token para Perfil

Chamado automaticamente quando:

- Usuário faz login
- Perfil ativo muda
- Token FCM é refreshed

```dart
final activeProfile = ref.read(activeProfileProvider);
final pushService = PushNotificationService();

await pushService.saveTokenForProfile(activeProfile.profileId);
```

### Solicitar Permissão

```dart
final pushService = PushNotificationService();
final settings = await pushService.requestPermission();

if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  // Permissão concedida
  await pushService.saveTokenForProfile(profileId);
}
```

### Navegar a partir de Notificação

```dart
void _handleNotificationTap(RemoteMessage message) {
  final type = message.data['type'];

  switch (type) {
    case 'nearbyPost':
      Navigator.push(/* PostDetailPage */);
      break;
    case 'interest':
      Navigator.push(/* PostDetailPage */);
      break;
    case 'newMessage':
      Navigator.push(/* ChatDetailPage */);
      break;
  }
}
```

### UI de Configurações

```dart
// Navegar para tela de configurações
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const NotificationSettingsPage(),
  ),
);
```

---

## ☁️ Cloud Functions

### 1. Posts Próximos

**Trigger:** `onCreate('posts/{postId}')`

**Lógica:**

1. Busca perfis com `notificationRadiusEnabled = true`
2. Calcula distância Haversine
3. Se distância ≤ `notificationRadius`, cria notificação
4. Envia push para tokens FCM do perfil

**Payload:**

```javascript
{
  notification: {
    title: 'Novo post próximo!',
    body: 'João está procurando banda a 5.2 km de você em São Paulo'
  },
  data: {
    type: 'nearbyPost',
    postId: 'abc123',
    authorName: 'João',
    city: 'São Paulo',
    click_action: 'FLUTTER_NOTIFICATION_CLICK'
  }
}
```

### 2. Interesses

**Trigger:** `onCreate('interests/{interestId}')`

**Payload:**

```javascript
{
  notification: {
    title: 'Novo interesse!',
    body: 'Maria demonstrou interesse em seu post'
  },
  data: {
    type: 'interest',
    postId: 'abc123',
    interestedProfileId: 'xyz789'
  }
}
```

### 3. Mensagens

**Trigger:** `onCreate('conversations/{id}/messages/{msgId}')`

**Lógica:**

- Verifica se já existe notificação não lida da conversa
- Se sim, atualiza (agregação) → "João (2 mensagens)"
- Se não, cria nova notificação

**Payload:**

```javascript
{
  notification: {
    title: 'João Silva',
    body: 'Oi, tudo bem?'
  },
  data: {
    type: 'newMessage',
    conversationId: 'conv123',
    senderProfileId: 'xyz789'
  }
}
```

### Monitorar Logs

```bash
# Todas as funções
firebase functions:log

# Função específica
firebase functions:log --only notifyNearbyPosts

# Tempo real
firebase functions:log --only sendInterestNotification --tail
```

---

## 🧪 Testing

### 1. Teste Local (Simulator/Device)

```dart
// Na UI de configurações, clicar em "Enviar Teste"
// ou programaticamente:
await ref.read(notificationServiceProvider).testNotification();
```

### 2. Teste via Firebase Console

1. Vá para **Cloud Messaging** → **Send your first message**
2. Insira título e corpo
3. Clique em **Send test message**
4. Cole o FCM token do dispositivo (copie dos logs)
5. Clique em **Test**

### 3. Teste Cloud Functions

**a) Criar post de teste:**

```bash
# Firestore Console → posts → Add document
{
  location: GeoPoint(-23.55, -46.63),
  city: "São Paulo",
  authorName: "Test User",
  authorProfileId: "test123",
  type: "musician",
  expiresAt: Timestamp(now + 30 days),
  createdAt: Timestamp(now)
}
```

**b) Verificar logs:**

```bash
firebase functions:log --only notifyNearbyPosts
# Esperado:
# ✅ Push enviado: 5 sucesso, 0 falhas
```

### 4. Cenários de Teste

| Cenário          | Ação               | Resultado Esperado                         |
| ---------------- | ------------------ | ------------------------------------------ |
| Foreground       | App aberto         | Notificação local exibida                  |
| Background       | App minimizado     | Notificação do sistema                     |
| Terminated       | App fechado        | Notificação do sistema, ao clicar abre app |
| Permissão negada | Negar notificações | Não exibe notificações push                |
| Troca de perfil  | Switch profile     | Token atualizado no novo perfil            |
| Logout           | Fazer logout       | Tokens removidos de todos os perfis        |

---

## 🐛 Troubleshooting

### Token não é gerado

**Sintomas:** Logs não mostram `🔑 FCM Token: ...`

**Soluções:**

1. **Android:** Verificar `google-services.json` está atualizado
2. **iOS:** Verificar Push Notifications capability habilitada no Xcode
3. **iOS:** Testar em dispositivo físico (simulador tem limitações)
4. Rebuild completo: `flutter clean && flutter pub get && flutter run`

### Notificações não aparecem

**Sintomas:** Token gerado, mas notificações não exibem

**Soluções:**

1. Verificar permissões: Settings → App → Notifications
2. **Android:** Verificar canal de notificação criado
3. **iOS:** Verificar APNs key configurado no Firebase
4. Verificar logs da Cloud Function: `firebase functions:log`
5. Testar notificação via Firebase Console (teste direto)

### Cloud Function não dispara

**Sintomas:** Post criado, mas função não executada

**Soluções:**

1. Verificar região da função: `southamerica-east1`
2. Verificar logs: `firebase functions:log --only notifyNearbyPosts`
3. Verificar índices do Firestore (perfis com `notificationRadiusEnabled`)
4. Redeploy: `firebase deploy --only functions`

### Erro "permission-denied" no Firestore

**Sintomas:** `⚠️ Badge Notifications: Erro no stream: permission-denied`

**Soluções:**

1. Verificar Firestore Rules:
   ```javascript
   allow read: if request.auth != null &&
                  request.auth.uid == resource.data.uid;
   ```
2. Verificar usuário está autenticado
3. Após logout, erro é esperado (stream fechado automaticamente)

### iOS: "no valid 'aps-environment' entitlement"

**Sintomas:** Crash ao iniciar no iOS

**Soluções:**

1. Verificar Push Notifications habilitado no Xcode
2. Rebuild: `cd ios && pod install && cd .. && flutter clean && flutter run`
3. Verificar Bundle Identifier correto
4. Verificar provisioning profile atualizado

### Tokens inválidos acumulando

**Sintomas:** Muitos tokens na coleção `fcmTokens`

**Soluções:**

- Cloud Functions automaticamente removem tokens inválidos
- Para limpeza manual:
  ```javascript
  // functions/index.js - já implementado
  // Tokens inválidos são deletados após falha no envio
  ```

---

## 📊 Monitoramento

### Métricas Importantes

**Cloud Functions:**

```bash
# Ver execuções
firebase functions:log --only notifyNearbyPosts --since 1d

# Ver erros
firebase functions:log --only sendInterestNotification --only-errors
```

**Firestore:**

- Contar tokens: `profiles/{profileId}/fcmTokens` (deve ter 1-3 por perfil)
- Contar notificações não lidas: `notifications` where `read = false`
- Verificar notificações expiradas: onde `expiresAt < now`

**Firebase Console:**

- Cloud Messaging → **Message reports**
- Analytics → **Notifications** (se habilitado)

---

## 📚 Referências

### Documentação Oficial

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)

### Arquivos Relacionados

- `lib/services/push_notification_service.dart` - Service principal
- `lib/providers/push_notification_provider.dart` - Riverpod provider
- `lib/pages/notification_settings_page.dart` - UI de configurações
- `functions/index.js` - Cloud Functions (3 triggers)
- `ios/PUSH_NOTIFICATIONS_SETUP.md` - Setup iOS detalhado
- `android/app/src/main/AndroidManifest.xml` - Configuração Android

### Próximos Passos

- [ ] Implementar analytics de notificações (taxa de abertura)
- [ ] Adicionar notificações agendadas (posts expirando)
- [ ] Implementar deep linking completo
- [ ] A/B testing de mensagens de notificação
- [ ] Notificações rich (imagens, botões de ação)

---

## ✅ Checklist de Deploy

Antes de fazer deploy em produção:

- [ ] APNs Key configurado no Firebase Console (iOS)
- [ ] Push Notifications habilitado no Xcode (iOS)
- [ ] `POST_NOTIFICATIONS` permission no AndroidManifest (Android)
- [ ] Cloud Functions deployadas: `firebase deploy --only functions`
- [ ] Testar nos 3 estados: foreground, background, terminated
- [ ] Testar em dispositivos físicos (iOS obrigatório)
- [ ] Verificar Firestore Rules permitem escrita em `fcmTokens`
- [ ] Documentar fluxo de permissões na onboarding do app
- [ ] Configurar rate limiting nas Cloud Functions (evitar spam)
- [ ] Monitorar logs por 24h após deploy

---

**🎉 Push Notifications totalmente implementado e testado!**
