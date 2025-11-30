# 🎯 START HERE: Configuração Xcode Schemes

O Xcode já está abrindo! Siga este guia simplificado.

---

## ⚡ 3 Passos Principais

### 1. Criar Schemes (2× apenas - DEV e STAGING)

**No topo do Xcode:**

**Opção A (Xcode 15+):**

```
"Runner" → "Edit Scheme..." → Botão de engrenagem ⚙️ → "Duplicate Scheme"
```

**Opção B (Xcode 14 ou anterior):**

```
"Runner" → "Manage Schemes..." → "+"
```

**Alternativa rápida:**

```
Product (menu) → Scheme → Edit Scheme... → ⌘+D (duplicar)
```

Crie 2 novos:

- **Runner-dev**
- **Runner-staging**

(O Runner original será PROD)

---

### 2. Configurar Cada Scheme

Para **cada** scheme (Runner-dev, Runner-staging, Runner):

**a) Abrir editor:**

```
Clique no nome do scheme (Runner/Runner-dev/Runner-staging) no topo
→ "Edit Scheme..."
```

Ou use o menu: **Product → Scheme → Edit Scheme...**  
Ou atalho: **⌘+<**

**b) Adicionar Pre-action Script:**

```
Sidebar → "Run" → Expandir "Pre-actions" → "+" → "New Run Script Action"
```

**c) Configurar script:**

- **Provide build settings from:** Runner ✅ (dropdown inferior)
- **Script:** Copie e cole:

**Para Runner-dev:**

```bash
cp "${SRCROOT}/Firebase/GoogleService-Info-dev.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
echo "✅ DEV Firebase configurado"
```

**Para Runner-staging:**

```bash
cp "${SRCROOT}/Firebase/GoogleService-Info-staging.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
echo "✅ STAGING Firebase configurado"
```

**Para Runner (PROD):**

```bash
cp "${SRCROOT}/Firebase/GoogleService-Info-prod.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
echo "✅ PROD Firebase configurado"
```

**d) Adicionar Arguments:**

```
Sidebar → "Run" → Aba "Arguments" → "Arguments Passed On Launch" → "+"
```

Adicione:

- **Runner-dev:** `--dart-define=FLAVOR=dev`
- **Runner-staging:** `--dart-define=FLAVOR=staging`
- **Runner:** `--dart-define=FLAVOR=prod`

**e) Salvar:**

```
Clique "Close"
```

---

### 3. Testar

1. Selecione **Runner-dev** no topo do Xcode
2. Pressione **⌘+R** para rodar
3. Verifique no console (⌘+Shift+Y): `✅ DEV Firebase configurado`
4. Teste STAGING e PROD também

---

## 📋 Checklist Rápido

Depois de configurar, verifique:

- [ ] ✅ 3 schemes aparecem no seletor: Runner-dev, Runner-staging, Runner
- [ ] ✅ Cada scheme tem pre-action script configurado
- [ ] ✅ Cada scheme tem `--dart-define=FLAVOR=...`
- [ ] ✅ Build roda sem erros (⌘+R)
- [ ] ✅ Console mostra mensagem de sucesso

---

## 🐛 Problemas Comuns

### "GoogleService-Info.plist not found"

**Solução:** Verifique se os arquivos existem:

```bash
ls -la ios/Firebase/
```

### Script não executa

**Solução:** Confirme que "Provide build settings from" = **Runner**

### App crasha ao abrir

**Solução:** Force clean: **⌘+Shift+K** e rode novamente

---

## 📚 Guias Completos

- **Guia Detalhado:** `ios/XCODE_SCHEMES_SETUP.md`
- **Quick Reference:** `ios/XCODE_QUICK_SETUP.md`

---

## ⏱️ Tempo Estimado

- Scheme DEV: 2 min
- Scheme STAGING: 2 min
- Scheme PROD: 2 min
- **Total:** ~6 minutos

---

**Boa configuração! 🚀**
