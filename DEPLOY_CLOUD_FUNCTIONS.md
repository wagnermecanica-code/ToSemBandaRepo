# 🚀 Deploy das Cloud Functions - Passo a Passo

## Status Atual
✅ **Código completo e pronto para deploy**
✅ **Dependências instaladas** (`node_modules/` com firebase-admin e firebase-functions)
✅ **firebase.json configurado** com seção functions

## Pré-requisitos

### 1. Firebase CLI Instalado
```bash
# Verificar instalação
firebase --version

# Se não instalado, instalar via npm
npm install -g firebase-tools
```

### 2. Login no Firebase
```bash
# Fazer login (abrirá navegador)
firebase login

# Verificar projetos disponíveis
firebase projects:list
```

### 3. Selecionar Projeto
```bash
# Navegar para pasta do projeto
cd /Users/wagneroliveira/to_sem_banda

# Selecionar projeto to-sem-banda-83e19
firebase use to-sem-banda-83e19

# Verificar projeto ativo
firebase use
```

## Deploy

### Opção 1: Deploy Apenas Functions (Recomendado)
```bash
firebase deploy --only functions
```

**Tempo estimado**: 2-3 minutos  
**Funções deployadas**: 
- `onPostCreated` - Trigger onCreate em posts/{postId}
- `cleanupExpiredNotifications` - Scheduled diariamente

### Opção 2: Deploy Completo (Rules + Indexes + Functions)
```bash
firebase deploy
```

**Inclui**: Firestore rules, indexes e functions

## Verificar Deploy

### 1. Console do Firebase
Acesse: https://console.firebase.google.com/project/to-sem-banda-83e19/functions

Você deve ver:
- ✅ `onPostCreated` - Status: Running
- ✅ `cleanupExpiredNotifications` - Status: Scheduled

### 2. Testar Function

#### Via Firebase CLI
```bash
# Ver logs em tempo real
firebase functions:log --only onPostCreated

# Ver logs recentes
firebase functions:log --limit 50
```

#### Criar Post de Teste
1. Abra o app
2. Vá para SettingsPage
3. Configure raio de 50km
4. Ative "Notificar sobre posts próximos"
5. Troque de perfil
6. Crie um novo post
7. Volte para o perfil original
8. Verifique NotificationsPage

### 3. Verificar Notificação Criada

**Via Firebase Console:**
1. Acesse: https://console.firebase.google.com/project/to-sem-banda-83e19/firestore
2. Abra collection `notifications`
3. Procure por tipo `nearbyPost`
4. Verifique campos:
   - `recipientProfileId` - ID do perfil que receberá
   - `type` - "nearbyPost"
   - `data.postId` - ID do post criado
   - `data.distance` - Distância em km
   - `expiresAt` - 7 dias no futuro

## Troubleshooting

### Erro: "Permission denied"
```bash
# Fazer login novamente
firebase login --reauth

# Verificar permissões do projeto
firebase projects:list
```

### Erro: "Function already exists"
```bash
# Forçar redeploy
firebase deploy --only functions --force
```

### Erro: "Missing index"
A função criará logs indicando índices faltantes. Firebase fornecerá link para criar automaticamente.

**Ou criar manualmente**:
```bash
firebase deploy --only firestore:indexes
```

### Logs Não Aparecem
```bash
# Verificar se função foi invocada
firebase functions:log --only onPostCreated --limit 100

# Verificar erros gerais
firebase functions:log --only errors
```

### Function Não Executa
1. Verificar trigger no console: https://console.firebase.google.com/project/to-sem-banda-83e19/functions/logs
2. Criar post de teste manualmente no Firestore Console
3. Verificar se `location` é GeoPoint válido
4. Confirmar que existe profile com `notificationRadiusEnabled: true`

## Custo Estimado

### Free Tier (Spark Plan)
- ❌ **Cloud Functions não disponível no plano gratuito**
- Necessário upgrade para Blaze (pay-as-you-go)

### Blaze Plan (Pay-as-you-go)
- **Invocações grátis**: 2 milhões/mês
- **Custo após limite**: $0.40 por milhão
- **Network**: $0.12 por GB

**Estimativa 100 posts/dia**:
- 3.000 invocações/mês
- Custo: **R$ 0,00** (dentro do limite gratuito)

**Estimativa 1000 posts/dia**:
- 30.000 invocações/mês
- Custo: **R$ 0,05/mês**

## Monitoramento

### Dashboard do Firebase
https://console.firebase.google.com/project/to-sem-banda-83e19/functions

Métricas disponíveis:
- Invocações por hora/dia
- Tempo médio de execução
- Taxa de erro
- Uso de memória

### Alertas (Configurar no Console)
1. Acesse Functions → Alertas
2. Criar alerta para:
   - Taxa de erro > 5%
   - Tempo de execução > 5 segundos
   - Invocações > 10.000/dia

## Rollback

### Se houver problemas após deploy
```bash
# Deletar função específica
firebase functions:delete onPostCreated

# Ou desabilitar no Console
# Functions → onPostCreated → Desabilitar
```

### Reverter para código anterior
```bash
git log functions/index.js  # Ver commits
git checkout <commit-hash> functions/index.js
firebase deploy --only functions
```

## Próximos Passos

Após deploy bem-sucedido:

1. ✅ **Testar end-to-end**:
   - Configurar raio em 2 perfis diferentes
   - Criar post com 1 perfil
   - Verificar notificação no outro perfil

2. ✅ **Monitorar logs** (primeiras 24h):
   ```bash
   firebase functions:log --only onPostCreated
   ```

3. ✅ **Verificar performance**:
   - Tempo médio de execução (esperado: < 3s)
   - Taxa de erro (esperado: < 1%)
   - Notificações criadas corretamente

4. ✅ **Ajustar raio padrão** se necessário:
   - Editar `lib/models/user_profile.dart`
   - Alterar `notificationRadiusKm: 20.0` (padrão atual)

5. ✅ **Rate limiting** (opcional):
   - Adicionar limite de notificações/dia por usuário
   - Ver seção "Atualizações Futuras" em `NEARBY_POST_NOTIFICATIONS.md`

---

**Dúvidas?** Consulte: `NEARBY_POST_NOTIFICATIONS.md` (guia completo)

**Logs de erro?** Enviar para: wagner@tosembanda.com
