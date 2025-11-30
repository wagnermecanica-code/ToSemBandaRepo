# ⚡ Quick Guide: Xcode Schemes Setup

## 🚀 Comando Rápido

```bash
open /Users/wagneroliveira/to_sem_banda/packages/app/ios/Runner.xcworkspace
```

---

## ✅ Checklist Visual

### 1️⃣ Criar 3 Schemes (2 minutos cada)

**Atalho:** No topo do Xcode → Runner → Manage Schemes

| Scheme     | Nome                | Build Config  | Pre-action Script                  | Arguments                      |
| ---------- | ------------------- | ------------- | ---------------------------------- | ------------------------------ |
| 🟢 DEV     | `Runner-dev`        | Debug-dev     | `scripts/copy-firebase-dev.sh`     | `--dart-define=FLAVOR=dev`     |
| 🟡 STAGING | `Runner-staging`    | Debug-staging | `scripts/copy-firebase-staging.sh` | `--dart-define=FLAVOR=staging` |
| 🔴 PROD    | `Runner` (original) | Debug         | `scripts/copy-firebase-prod.sh`    | `--dart-define=FLAVOR=prod`    |

---

## 📝 Passo-a-Passo Simplificado

### Para Cada Scheme:

1. **Duplicar Scheme**
   - Xcode → Runner (topo) → Manage Schemes → + (ou ⌘+D)
2. **Renomear**

   - `Runner-dev`, `Runner-staging`, ou manter `Runner`

3. **Configurar Pre-action**
   - Edit Scheme (⌘+<) → Run → Pre-actions → + → New Run Script
   - **Provide build settings from:** Runner
   - **Script:** Cole o conteúdo de `ios/scripts/copy-firebase-[flavor].sh`
4. **Adicionar Arguments**

   - Run → Arguments → Arguments Passed On Launch → +
   - `--dart-define=FLAVOR=dev` (ou staging/prod)

5. **Salvar**
   - Close

---

## 🎯 Alternativa: Copiar Scripts Inline

Se preferir não usar arquivos .sh externos, cole direto no Xcode:

### DEV Pre-action:

```bash
echo "🔧 DEV flavor..."
cp "${SRCROOT}/Firebase/GoogleService-Info-dev.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
echo "✅ Done"
```

### STAGING Pre-action:

```bash
echo "🔧 STAGING flavor..."
cp "${SRCROOT}/Firebase/GoogleService-Info-staging.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
echo "✅ Done"
```

### PROD Pre-action:

```bash
echo "🔧 PROD flavor..."
cp "${SRCROOT}/Firebase/GoogleService-Info-prod.plist" "${SRCROOT}/Runner/GoogleService-Info.plist"
echo "✅ Done"
```

---

## ✅ Testar

1. Selecione **Runner-dev** no topo do Xcode
2. Pressione **⌘+R**
3. Verifique o console: `✅ GoogleService-Info-dev.plist copiado com sucesso`
4. Repita para STAGING e PROD

---

## 📸 Screenshots das Etapas

### Manage Schemes

```
Xcode (topo) → "Runner" → "Manage Schemes..."
```

### Edit Scheme

```
Scheme selecionado → Botão "Edit Scheme..." (ou ⌘+<)
```

### Pre-actions

```
Sidebar esquerda: Run → Expandir "Pre-actions" → "+"
```

### Arguments

```
Sidebar esquerda: Run → Aba "Arguments" → "Arguments Passed On Launch"
```

---

## 🎊 Resultado

Depois de configurar, o seletor de schemes mostrará:

```
Runner-dev      ← DEV environment
Runner-staging  ← STAGING environment
Runner          ← PROD environment (padrão)
```

---

**Tempo:** ~6 minutos (2 min × 3 schemes)  
**Guia Completo:** `ios/XCODE_SCHEMES_SETUP.md`
