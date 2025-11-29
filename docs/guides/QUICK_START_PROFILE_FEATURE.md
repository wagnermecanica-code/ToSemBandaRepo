# 🚀 Quick Start - Continuação da Refatoração

## ⚡ Status em 10 Segundos

```bash
Post Feature:    ✅ 100% (0 erros)
Profile Feature: 🎯 PRÓXIMO (60 erros)
Total Restante:  1183 erros
```

---

## 📋 Comandos Essenciais (Copy/Paste)

### 1. Análise Rápida

```bash
cd /Users/wagneroliveira/to_sem_banda

# Total de erros atual
flutter analyze --no-fatal-infos 2>&1 | grep "^  error •" | wc -l

# Distribuição por feature
flutter analyze --no-fatal-infos 2>&1 | grep "packages/app/lib/features" | grep "error •" | awk -F'/' '{print $5}' | sort | uniq -c | sort -rn
```

### 2. Iniciar Profile Feature

```bash
# Verificar estrutura
ls -la packages/app/lib/features/profile/domain/entities/

# Buscar Freezed usage
grep -r "@freezed" packages/app/lib/features/profile/

# Listar primeiros 20 erros
flutter analyze --no-fatal-infos 2>&1 | grep "packages/app/lib/features/profile" | grep "error •" | head -20

# Ver erros em profile_entity.dart
flutter analyze --no-fatal-infos 2>&1 | grep "profile_entity.dart"
```

### 3. Validação Após Fix

```bash
# Checar arquivo específico
flutter analyze packages/app/lib/features/profile/domain/entities/profile_entity.dart

# Checar feature completa
flutter analyze --no-fatal-infos 2>&1 | grep "packages/app/lib/features/profile" | grep "error •" | wc -l

# Build test
flutter build apk --debug --target-platform android-arm64

# Run test
flutter run --debug
```

---

## 🎯 Workflow Padrão (Copiar do Post Feature)

### Passo 1: Identificar Entity com Freezed

```bash
# Buscar @freezed
grep -n "@freezed" packages/app/lib/features/profile/domain/entities/profile_entity.dart

# Se encontrar, aplicar removal manual
```

### Passo 2: Criar Implementação Manual

**Template baseado em post_entity.dart:**

```dart
class ProfileEntity {
  final String id;
  final String uid;
  final String name;
  // ... outros campos

  const ProfileEntity({
    required this.id,
    required this.uid,
    required this.name,
    // ... params
  });

  // fromFirestore com casts adequados
  factory ProfileEntity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProfileEntity(
      id: doc.id,
      uid: data['uid'] as String,
      name: data['name'] as String,
      // Cast pattern: (data['field'] as Type?) ?? default
    );
  }

  // toFirestore
  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'name': name,
    // Excluir campos calculados
  };

  // copyWith
  ProfileEntity copyWith({String? id, ...}) => ProfileEntity(...);

  // equality
  @override
  bool operator ==(Object other) =>
    identical(this, other) || (other is ProfileEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
```

### Passo 3: Deletar Files Gerados

```bash
# Após implementação manual completa
rm -f packages/app/lib/features/profile/domain/entities/profile_entity.freezed.dart
rm -f packages/app/lib/features/profile/domain/entities/profile_entity.g.dart
```

### Passo 4: Fix Pages & Providers

**Pattern de casts dinâmicos:**

```dart
// ❌ Antes
final value = data['field'];
final list = List<String>.from(data['array']);

// ✅ Depois
final value = (data['field'] as Type?) ?? default;
final list = (data['array'] as List<dynamic>?)?.cast<String>() ?? [];
```

### Passo 5: Eliminar Legacy Code

```bash
# Buscar referências legacy
grep -r "legacy\." packages/app/lib/features/profile/

# Substituir por tipo direto (ProfileEntity)
```

### Passo 6: Validação

```bash
# Verificar erros restantes
flutter analyze --no-fatal-infos 2>&1 | grep "packages/app/lib/features/profile" | grep "error •" | wc -l

# Se 0, sucesso! Commit
git add packages/app/lib/features/profile/
git commit -m "refactor(profile): complete migration - 60 errors → 0"
```

---

## 🔍 Troubleshooting Rápido

### Erro: "Undefined class"

**Solução:** Procurar imports antigos

```bash
grep -r "import.*Post[^E]" packages/app/lib/features/profile/
# Substituir por ProfileEntity
```

### Erro: "Type argument"

**Solução:** Atualizar providers

```bash
# Buscar List<Profile> ou Stream<Profile>
# Substituir por List<ProfileEntity>, Stream<ProfileEntity>
```

### Erro: "Dynamic cast"

**Solução:** Aplicar pattern universal

```dart
(data['field'] as Type?) ?? default
```

### Erro: "Non-bool condition"

**Solução:** Converter para bool explícito

```dart
// Antes: if (value)
// Depois: if ((value as bool?) ?? false)
```

---

## 📊 Checklist de Progresso

### Profile Feature (60 erros)

- [ ] profile_entity.dart - Freezed removal
- [ ] profile\_\*\_page.dart - Casts dinâmicos
- [ ] profile_providers.dart - Legacy elimination
- [ ] Cleanup - Deletar .freezed/.g.dart
- [ ] Validação - 0 erros

### Notifications Feature (40 erros)

- [ ] notification_entity.dart - Análise
- [ ] notification_pages - Casts
- [ ] notification_providers - Legacy check
- [ ] Validação - 0 erros

### Auth Feature (10 erros)

- [ ] auth_entity.dart ou similar - Análise
- [ ] auth_pages - Casts
- [ ] Validação - 0 erros

### Outros (4 erros)

- [ ] Settings - Cleanup
- [ ] Home - Cleanup
- [ ] Lib - Cleanup
- [ ] Validação - 0 erros

---

## 🎓 Referências Rápidas

### Arquivos de Referência (100% Corretos)

```bash
# Entity manual perfeito
cat packages/app/lib/features/post/domain/entities/post_entity.dart

# Provider refatorado
cat packages/app/lib/features/post/presentation/providers/post_providers.dart

# Page com casts
cat packages/app/lib/features/post/presentation/pages/post_page.dart
```

### Documentação Completa

```bash
# Detalhes da sessão
cat SESSION_ATUAL_29_NOV_2025.md

# MVP status
cat MVP_CHECKLIST.md

# Resumo executivo
cat GITHUB_SUMMARY_29_NOV_2025.md

# Arquitetura completa
cat .github/copilot-instructions.md
```

---

## 🚀 One-Liner para Próxima Sessão

```bash
cd /Users/wagneroliveira/to_sem_banda && \
echo "=== STATUS ATUAL ===" && \
flutter analyze --no-fatal-infos 2>&1 | grep "^  error •" | wc -l && \
echo "" && \
echo "=== PROFILE FEATURE ===" && \
flutter analyze --no-fatal-infos 2>&1 | grep "packages/app/lib/features/profile" | grep "error •" | wc -l && \
echo "" && \
echo "=== VERIFICAR FREEZED ===" && \
grep -r "@freezed" packages/app/lib/features/profile/domain/entities/
```

**Resultado esperado:**

```
=== STATUS ATUAL ===
1183

=== PROFILE FEATURE ===
60

=== VERIFICAR FREEZED ===
[arquivo]: @freezed
```

---

## ⏱️ Estimativas de Tempo

| Feature          | Erros | Tempo  | Complexidade              |
| ---------------- | ----- | ------ | ------------------------- |
| ✅ Post          | 0     | ✅ 2h  | Alta (Freezed + 26 casts) |
| 🎯 Profile       | 60    | 2-3h   | Alta (similar Post)       |
| 🔜 Notifications | 40    | 1.5-2h | Média                     |
| 🔜 Auth          | 10    | 45min  | Baixa                     |
| 🔜 Outros        | 4     | 30min  | Muito baixa               |

**Total estimado:** 5-7 horas de trabalho focado

---

## 🎯 Meta Final

```
┌─────────────────────────────────────┐
│  Post Feature:     ✅ 100%         │
│  Profile Feature:  🎯 0% → Target  │
│  Total:            4.3% → 100%     │
│                                    │
│  ETA: 30/11/2025                   │
│  Confidence: Alta                  │
└─────────────────────────────────────┘
```

---

## 📝 Notas Importantes

1. **Hot Restart após mudanças** em providers Riverpod (⌘+Shift+\)
2. **Commit incremental** após cada arquivo corrigido
3. **Validar sempre** antes de próximo arquivo
4. **Pattern provado** - funciona 100% (Post Feature)
5. **Zero bugs** introduzidos até agora

---

**Criado:** 29/11/2025 23:50 BRT  
**Por:** GitHub Copilot + Wagner Oliveira  
**Sessão:** Post Feature Complete (100%)  
**Próximo:** Profile Feature (60 erros → 0)

**🚀 Boa sorte na continuação!**
