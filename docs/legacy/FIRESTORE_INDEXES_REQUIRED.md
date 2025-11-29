# Índices Firestore Necessários

Este documento lista os índices compostos obrigatórios para o Firestore funcionar corretamente com as queries do app.

## Status Atual
⚠️ **CRÍTICO**: Sem estes índices, os posts não aparecem no mapa/lista do HomePage.

## Como Criar os Índices

### Opção 1: Firebase Console (Recomendado para primeira vez)
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione o projeto: **to-sem-banda-83e19**
3. Vá em **Firestore Database** → **Índices**
4. Clique em **Criar índice**
5. Crie cada índice listado abaixo

### Opção 2: Firebase CLI (Deploy automático)
```bash
# Verificar projeto conectado
firebase projects:list

# Deploy dos índices (arquivo firestore.indexes.json)
firebase deploy --only firestore:indexes

# Verificar status após deploy
# Os índices levam 5-15 minutos para serem construídos
```

## Índices Necessários

### Collection: `posts`

#### Índice 1: Filtro por cidade + expiração + ordenação por data de criação
**Uso**: HomePage - Busca de posts por cidade com paginação
```
Coleção: posts
Campos:
  - city (Ascending)
  - expiresAt (Ascending)
  - createdAt (Descending)
```

**Query que usa este índice**:
```dart
FirebaseFirestore.instance.collection('posts')
  .where('city', isEqualTo: cityName)
  .where('expiresAt', isGreaterThan: Timestamp.now())
  .orderBy('expiresAt')
  .orderBy('createdAt', descending: true)
  .limit(20);
```

#### Índice 2: Filtro por cidade + ordenação inversa
**Uso**: HomePage - Ordem alternativa de posts
```
Coleção: posts
Campos:
  - city (Ascending)
  - createdAt (Descending)
  - expiresAt (Ascending)
```

**Query que usa este índice**:
```dart
FirebaseFirestore.instance.collection('posts')
  .where('city', isEqualTo: cityName)
  .orderBy('createdAt', descending: true)
  .orderBy('expiresAt')
  .limit(20);
```

#### Índice 3: Posts do perfil ativo + expiração
**Uso**: ViewProfilePage - Lista posts do perfil com filtro de expiração
```
Coleção: posts
Campos:
  - authorProfileId (Ascending)
  - expiresAt (Ascending)
  - createdAt (Descending)
```

**Query que usa este índice**:
```dart
FirebaseFirestore.instance.collection('posts')
  .where('authorProfileId', isEqualTo: profileId)
  .where('expiresAt', isGreaterThan: Timestamp.now())
  .orderBy('expiresAt')
  .orderBy('createdAt', descending: true);
```

#### Índice 4: Posts do perfil sem filtro de expiração
**Uso**: ViewProfilePage - Próprio perfil vê todos os posts (inclusive expirados)
```
Coleção: posts
Campos:
  - authorProfileId (Ascending)
  - createdAt (Descending)
```

**Query que usa este índice**:
```dart
FirebaseFirestore.instance.collection('posts')
  .where('authorProfileId', isEqualTo: profileId)
  .orderBy('createdAt', descending: true);
```

### Collection: `interests` (compatibilidade com sistema antigo)

#### Índice 5: Notificações de interesse por perfil
**Uso**: NotificationsPage - Lista interesses recebidos
```
Coleção: interests
Campos:
  - postAuthorProfileId (Ascending)
  - createdAt (Descending)
```

**Query que usa este índice**:
```dart
FirebaseFirestore.instance.collection('interests')
  .where('postAuthorProfileId', isEqualTo: profileId)
  .orderBy('createdAt', descending: true);
```

### Collection: `notifications` (sistema unificado V2)

#### Índice 6: Notificações por perfil + tipo
**Uso**: NotificationsPage - Filtro por tipo de notificação
```
Coleção: notifications
Campos:
  - recipientProfileId (Ascending)
  - type (Ascending)
  - createdAt (Descending)
```

**Query que usa este índice**:
```dart
FirebaseFirestore.instance.collection('notifications')
  .where('recipientProfileId', isEqualTo: profileId)
  .where('type', isEqualTo: 'interest')
  .orderBy('createdAt', descending: true);
```

#### Índice 7: Notificações não lidas
**Uso**: Badge de notificações não lidas
```
Coleção: notifications
Campos:
  - recipientProfileId (Ascending)
  - read (Ascending)
  - createdAt (Descending)
```

**Query que usa este índice**:
```dart
FirebaseFirestore.instance.collection('notifications')
  .where('recipientProfileId', isEqualTo: profileId)
  .where('read', isEqualTo: false)
  .orderBy('createdAt', descending: true);
```

## Verificação

Após criar os índices:

1. **Aguarde construção**: 5-15 minutos dependendo do volume de dados
2. **Verifique status no Console**: Verde = pronto, Amarelo = construindo, Vermelho = erro
3. **Teste no app**: 
   - HomePage deve carregar posts da cidade
   - NotificationsPage deve mostrar interesses
   - ViewProfilePage deve listar posts do perfil
4. **Logs de debug**: Busque por "HomePage: query returned X posts" no console

## Troubleshooting

### Erro: "FAILED_PRECONDITION: The query requires an index"
- Significa que um índice está faltando
- Copie a URL do erro (Firebase automaticamente sugere criar o índice)
- Ou crie manualmente usando as specs acima

### Erro: "Invalid query. Ordering by field 'createdAt' requires a condition on the same field"
- Significa que a ordem do orderBy está incorreta
- Verifique que expiresAt vem antes de createdAt no orderBy

### Posts não aparecem mesmo com índices criados
1. Verifique que posts têm campo `expiresAt` maior que agora:
   ```bash
   bash scripts/check_posts.sh
   ```
2. Verifique que posts têm campo `city` preenchido
3. Verifique que posts têm campo `location` (GeoPoint)
4. Se necessário, delete posts malformados:
   ```bash
   dart run scripts/delete_old_posts.dart
   ```

## Manutenção

- **Backup**: Índices são salvos em `firestore.indexes.json` (versionado no git)
- **Deploy**: Sempre use `firebase deploy --only firestore:indexes` após modificar `firestore.indexes.json`
- **Monitoramento**: Firebase Console → Firestore → Índices → Status de construção

## Referências
- [Firebase Composite Indexes Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Query Limitations](https://firebase.google.com/docs/firestore/query-data/queries#query_limitations)
- Projeto: `to-sem-banda-83e19`
- Região: `us-central` (default)
