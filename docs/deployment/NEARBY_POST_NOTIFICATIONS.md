# 🔔 Nearby Post Notifications - Guia de Deploy

## 📋 Overview

Sistema de notificações automáticas para usuários quando um novo post é criado dentro do raio configurado.

**Arquitetura:**
- **Cloud Function**: `onPostCreated` (trigger: onCreate em posts)
- **Algoritmo**: Haversine distance calculation
- **Filtro**: `notificationRadiusEnabled: true` + distância ≤ `notificationRadiusKm`
- **Expiração**: 7 dias

## 🚀 Deploy Completo

### 1. Instalar Dependências

```bash
cd functions
npm install
```

### 2. Fazer Login no Firebase

```bash
firebase login
```

### 3. Selecionar Projeto

```bash
firebase use to-sem-banda-83e19
```

### 4. Deploy da Cloud Function

```bash
# Deploy apenas functions
firebase deploy --only functions

# Ou deploy completo (rules + indexes + functions)
firebase deploy
```

### 5. Verificar Deploy

```bash
# Ver logs da função
firebase functions:log

# Ver status
firebase functions:list
```

## 🧪 Testar Localmente (Emulador)

### 1. Instalar Emulators

```bash
firebase init emulators
# Selecionar: Functions, Firestore
```

### 2. Iniciar Emulador

```bash
firebase emulators:start
```

### 3. Conectar App ao Emulador

No `main.dart`, adicionar antes de `Firebase.initializeApp()`:

```dart
if (kDebugMode) {
  await FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
}
```

### 4. Criar Post de Teste

1. Abra o app conectado ao emulador
2. Crie um post com location
3. Verifique logs no terminal do emulador
4. Verifique notificações criadas

## 📊 Monitoramento

### Logs em Produção

```bash
# Logs em tempo real
firebase functions:log --only onPostCreated

# Logs das últimas 24h
firebase functions:log --only onPostCreated --limit 100
```

### Métricas no Console

1. Acesse: https://console.firebase.google.com/project/to-sem-banda-83e19/functions
2. Veja execuções, erros, duração

## 🐛 Troubleshooting

### Função não executa

**Problema**: Post criado mas nenhuma notificação

**Soluções:**
1. Verificar logs: `firebase functions:log`
2. Confirmar que profiles têm `notificationRadiusEnabled: true`
3. Verificar se location é GeoPoint válido
4. Confirmar raio suficiente (`notificationRadiusKm`)

### Erros de permissão

**Problema**: `permission-denied` nos logs

**Solução:**
```bash
# Garantir que Cloud Functions tem permissão
firebase functions:config:set functions.write=true
firebase deploy --only functions
```

### Notificações duplicadas

**Problema**: Múltiplas notificações para mesmo post

**Causa**: Cloud Function executada múltiplas vezes

**Solução**: Firebase garante idempotência, mas adicionar check:

```javascript
// Verificar se já existe notificação
const existing = await admin.firestore()
  .collection('notifications')
  .where('recipientProfileId', '==', profileId)
  .where('type', '==', 'nearbyPost')
  .where('data.postId', '==', postId)
  .limit(1)
  .get();

if (!existing.empty) {
  console.log('Notificação já existe');
  continue;
}
```

## 💰 Custos Estimados

### Firebase Spark (Free Tier)

- **Cloud Functions**: 2 milhões invocações/mês grátis
- **Estimativa**: 100 posts/dia × 30 dias = 3.000 invocações/mês
- **Custo**: R$ 0,00 (bem dentro do limite)

### Firebase Blaze (Pay as you go)

- **Invocação**: $0.40 por milhão
- **Network egress**: $0.12 por GB
- **Estimativa 1000 usuários**:
  - 1000 posts/dia × 30 = 30.000 invocações
  - Custo: ~$0.01/mês (R$ 0,05)

**Conclusão**: Custo desprezível mesmo em escala

## 📱 UX no App

### 1. NotificationsPage

Já configurada para exibir tipo `nearbyPost`:

```dart
case 'nearbyPost':
  icon = Icons.location_on_outlined;
  color = AppColors.accent;
  title = notification.title; // "Novo post próximo!"
```

### 2. Badge no Bottom Nav

```dart
StreamBuilder<int>(
  stream: NotificationService.streamUnreadCount(),
  builder: (context, snapshot) {
    final count = snapshot.data ?? 0;
    return Badge.count(
      count: count,
      child: Icon(Icons.notifications_outlined),
    );
  },
)
```

### 3. Ação ao Clicar

```dart
if (notification.type == 'nearbyPost') {
  final postId = notification.data['postId'];
  // Navegar para ViewPostPage ou HomePage filtrado
}
```

## ✅ Checklist de Validação

- [ ] Cloud Function deployada com sucesso
- [ ] Logs mostram execução sem erros
- [ ] Criar post de teste
- [ ] Verificar notificação criada no Firestore
- [ ] Notificação aparece no app
- [ ] Badge atualiza corretamente
- [ ] Clicar na notificação abre post
- [ ] Distância calculada corretamente
- [ ] Raio configurável funciona
- [ ] Toggle desabilita notificações

## 🔄 Atualizações Futuras

### Rate Limiting (opcional)

Limitar notificações por usuário:

```javascript
// Max 10 notificações nearbyPost por dia
const today = new Date();
today.setHours(0, 0, 0, 0);

const count = await admin.firestore()
  .collection('notifications')
  .where('recipientProfileId', '==', profileId)
  .where('type', '==', 'nearbyPost')
  .where('createdAt', '>=', admin.firestore.Timestamp.fromDate(today))
  .count()
  .get();

if (count.data().count >= 10) {
  console.log(`Profile ${profileId} atingiu limite diário`);
  continue;
}
```

### Filtro por Instrumentos (opcional)

Notificar apenas se post tem instrumento de interesse:

```javascript
const profileInstruments = profile.instruments || [];
const postInstruments = postData.instruments || postData.seekingMusicians || [];

const hasMatch = profileInstruments.some(inst => 
  postInstruments.includes(inst)
);

if (!hasMatch) {
  console.log('Instrumentos não compatíveis');
  continue;
}
```

## 📞 Suporte

**Logs de erro?** Enviar para: wagner@tosembanda.com  
**Firebase Console**: https://console.firebase.google.com/project/to-sem-banda-83e19  
**Documentação**: https://firebase.google.com/docs/functions

---

**Status**: ✅ Implementação completa  
**Última atualização**: 19/11/2025  
**Autor**: GitHub Copilot + Wagner Oliveira
