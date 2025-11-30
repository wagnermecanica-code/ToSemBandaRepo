# Plano de Ação: 100% Boas Práticas

**Objetivo:** Atingir 100% de implementação das 7 boas práticas de desenvolvimento  
**Status Atual:** 86% (veja `BOAS_PRATICAS_ANALISE_2025-11-30.md`)  
**Prazo Estimado:** 4-5 semanas  
**Última Atualização:** 30 de novembro de 2025

---

## 📊 Progresso por Prática

| #   | Prática                            | Atual | Meta | Gap | Prioridade  |
| --- | ---------------------------------- | ----- | ---- | --- | ----------- |
| 1   | Feature-first + Clean Architecture | 95%   | 100% | 5%  | 🟡 Baixa    |
| 2   | Riverpod como padrão               | 90%   | 100% | 10% | 🟡 Baixa    |
| 3   | Código 100% gerado                 | 65%   | 100% | 35% | 🔴 Alta     |
| 4   | Lint strict + Conventional Commits | 80%   | 100% | 20% | 🟠 Média    |
| 5   | Testes em use cases e providers    | 75%   | 95%  | 20% | 🔴 Alta     |
| 6   | Rotas tipadas (go_router)          | 100%  | 100% | 0%  | ✅ Completo |
| 7   | Design system separado             | 100%  | 100% | 0%  | ✅ Completo |

---

## 🎯 FASE 1: Quick Wins (1 semana - 40h)

**Meta:** 86% → 92% (+6%)  
**ROI:** Alto (impacto imediato com pouco esforço)

### Task 1.1: Configurar Conventional Commits (2h)

**Objetivo:** Automatizar validação de commits

**Subtarefas:**

- [ ] Instalar `commitlint` e `husky`
  ```bash
  npm install --save-dev @commitlint/cli @commitlint/config-conventional husky
  npx husky install
  ```
- [ ] Criar `.commitlintrc.json`
  ```json
  {
    "extends": ["@commitlint/config-conventional"],
    "rules": {
      "type-enum": [
        2,
        "always",
        ["feat", "fix", "docs", "style", "refactor", "test", "chore"]
      ]
    }
  }
  ```
- [ ] Configurar hook `commit-msg`
  ```bash
  npx husky add .husky/commit-msg 'npx --no -- commitlint --edit $1'
  ```
- [ ] Criar `CONTRIBUTING.md` com guidelines
- [ ] Testar com commits de exemplo

**Entregáveis:**

- ✅ Commits validados automaticamente
- ✅ Mensagens de erro claras
- ✅ Documentação no repo

**Progresso:** Conventional Commits 0% → 100%

---

### Task 1.2: Habilitar Regras de Lint Strict (8h)

**Objetivo:** Ativar regras desabilitadas e corrigir warnings

**Subtarefas:**

- [ ] Atualizar `analysis_options.yaml`
  ```yaml
  linter:
    rules:
      always_specify_types: true # De false → true
      require_trailing_commas: true # De false → true
      prefer_const_constructors: true # Adicionar
      prefer_const_literals_to_create_immutables: true
  ```
- [ ] Executar `flutter analyze` e listar todos os issues
- [ ] Corrigir issues por categoria:
  - [ ] `directives_ordering` (40 issues) - Automático via formatter
  - [ ] `public_member_api_docs` (20 issues) - Adicionar /// comments
  - [ ] `use_build_context_synchronously` (15 issues) - Adicionar if(mounted)
  - [ ] Outros (43 issues) - Case by case
- [ ] Configurar CI/CD check
  ```yaml
  # .github/workflows/lint.yml
  name: Lint
  on: [pull_request]
  jobs:
    analyze:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - uses: subosito/flutter-action@v2
        - run: flutter pub get
        - run: flutter analyze --fatal-infos
  ```

**Entregáveis:**

- ✅ 0 lint issues
- ✅ CI check configurado
- ✅ Código mais consistente

**Progresso:** Lint 85% → 95%

---

### Task 1.3: Testes Básicos (Use Cases Críticos) (30h)

**Objetivo:** Cobrir use cases de features críticas (Post, Messages)

**Subtarefas:**

#### Post Use Cases (12h)

- [ ] `create_post_usecase_test.dart` (6 testes)
  - [ ] Should create post with valid data
  - [ ] Should throw when description > 1000 chars
  - [ ] Should throw when location is (0,0)
  - [ ] Should throw when authorProfileId is empty
  - [ ] Should set expiresAt to 30 days from now
  - [ ] Should validate instruments/genres lists
- [ ] `update_post_usecase_test.dart` (4 testes)
  - [ ] Should update post when user is owner
  - [ ] Should throw when user is not owner
  - [ ] Should validate updated data
  - [ ] Should not change authorProfileId
- [ ] `delete_post_usecase_test.dart` (3 testes)
  - [ ] Should delete post when user is owner
  - [ ] Should throw when user is not owner
  - [ ] Should delete associated interests
- [ ] `toggle_interest_usecase_test.dart` (5 testes)
  - [ ] Should add interest when not exists
  - [ ] Should remove interest when exists
  - [ ] Should throw on self-interest
  - [ ] Should validate profile ownership
  - [ ] Should not duplicate interests

#### Messages Use Cases (12h)

- [ ] `send_message_usecase_test.dart` (5 testes)
  - [ ] Should send message with valid text
  - [ ] Should throw when text is empty
  - [ ] Should throw when text is whitespace only
  - [ ] Should trim message text
  - [ ] Should increment unread count for recipient
- [ ] `load_messages_usecase_test.dart` (3 testes)
  - [ ] Should load messages ordered by createdAt
  - [ ] Should filter by conversationId
  - [ ] Should handle empty conversation
- [ ] `mark_as_read_usecase_test.dart` (4 testes)
  - [ ] Should reset unread count to 0
  - [ ] Should update readAt timestamp
  - [ ] Should only affect recipient's side
  - [ ] Should handle already-read conversation

#### Home Use Cases (6h)

- [ ] `search_posts_usecase_test.dart` (4 testes)
  - [ ] Should filter by instruments
  - [ ] Should filter by genres
  - [ ] Should filter by distance
  - [ ] Should combine multiple filters

**Entregáveis:**

- ✅ 29 novos testes
- ✅ Cobertura Use Cases: 75% → 90%

**Progresso:** Testes 75% → 85%

---

## 🏗️ FASE 2: Fundação (2 semanas - 80h)

**Meta:** 92% → 98% (+6%)  
**ROI:** Muito Alto (fundação para qualidade de longo prazo)

### Task 2.1: Code Generation Completo - Entities (20h)

**Objetivo:** Migrar todas entities para Freezed + json_serializable

**Subtarefas:**

#### Identificar entities sem Freezed (2h)

- [ ] Fazer grep de todas classes sem `@freezed`
- [ ] Listar classes candidatas:
  - [ ] `SearchParams` (home_page.dart)
  - [ ] `ProfileState` (profile_providers.dart)
  - [ ] `FilterOptions` (home)
  - [ ] `ChatState` (messages)
  - [ ] `NotificationSettings` (settings)

#### Migrar entities para Freezed (12h)

- [ ] `SearchParams` → `search_params.dart` + `search_params.freezed.dart`
  ```dart
  @freezed
  class SearchParams with _$SearchParams {
    const factory SearchParams({
      required String query,
      required List<String> instruments,
      required List<String> genres,
      required double maxDistanceKm,
      required GeoPoint location,
    }) = _SearchParams;

    factory SearchParams.fromJson(Map<String, dynamic> json) =>
        _$SearchParamsFromJson(json);
  }
  ```
- [ ] Repetir para todas entities identificadas
- [ ] Executar `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Substituir usos antigos por novos

#### Adicionar JSON serialization (6h)

- [ ] Garantir que todas entities tem `fromJson` / `toJson`
- [ ] Adicionar `@JsonSerializable()` onde falta
- [ ] Testar serialization/deserialization
- [ ] Documentar formato JSON esperado

**Entregáveis:**

- ✅ 100% entities com Freezed
- ✅ 100% entities com JSON serialization
- ✅ Type-safety completo

**Progresso:** Code Generation 65% → 80%

---

### Task 2.2: DTOs e Mappers (20h)

**Objetivo:** Separar Entity (domain) de DTO (data layer)

**Subtarefas:**

#### Criar DTOs (12h)

- [ ] Estrutura de pastas
  ```
  features/
  └── profile/
      ├── domain/
      │   └── entities/
      │       └── profile_entity.dart    # Domain (já existe)
      └── data/
          ├── models/
          │   └── profile_dto.dart        # Novo (Data Transfer Object)
          └── mappers/
              └── profile_mapper.dart     # Novo (conversão)
  ```
- [ ] Criar DTOs para features principais:
  - [ ] `ProfileDTO` (mirror ProfileEntity + Firestore fields)
  - [ ] `PostDTO` (mirror PostEntity + Firestore fields)
  - [ ] `MessageDTO`
  - [ ] `ConversationDTO`
  - [ ] `NotificationDTO`

#### Implementar Mappers (8h)

- [ ] `ProfileMapper`
  ```dart
  class ProfileMapper {
    static ProfileEntity toEntity(ProfileDTO dto) {
      return ProfileEntity(
        profileId: dto.id,
        name: dto.name,
        // ... conversão de campos
      );
    }

    static ProfileDTO toDTO(ProfileEntity entity) {
      return ProfileDTO(
        id: entity.profileId,
        name: entity.name,
        // ... conversão de campos
      );
    }
  }
  ```
- [ ] Repetir para todas entities
- [ ] Atualizar Repositories para usar DTOs

  ```dart
  // ANTES
  Future<ProfileEntity> getProfile(String id);

  // DEPOIS
  Future<ProfileEntity> getProfile(String id) async {
    final dto = await dataSource.getProfile(id);
    return ProfileMapper.toEntity(dto);
  }
  ```

**Entregáveis:**

- ✅ Separação clara domain/data
- ✅ Mappers testados
- ✅ Repositories refatorados

**Progresso:** Code Generation 80% → 90%

---

### Task 2.3: Testes Avançados - Providers (20h)

**Objetivo:** Cobrir todos providers com testes

**Subtarefas:**

#### Post Providers (8h)

- [ ] `post_providers_test.dart` (15 testes)
  - [ ] postRemoteDataSourceProvider returns singleton
  - [ ] postRepositoryNewProvider returns PostRepository
  - [ ] All UseCases depend on repository
  - [ ] UseCases return same instance (singleton)
  - [ ] Can override repository for testing
  - [ ] postListProvider returns empty list initially
  - [ ] postListProvider reacts to repository changes
  - [ ] Providers auto-dispose when container disposed

#### Messages Providers (6h)

- [ ] `messages_providers_test.dart` (12 testes)
  - Similar structure to post_providers_test.dart
  - Test conversationListProvider
  - Test unreadMessageCountProvider
  - Test markAsReadUseCase integration

#### Notifications Providers (6h)

- [ ] `notifications_providers_test.dart` (10 testes)
  - Test notificationStreamProvider
  - Test unreadNotificationCountProvider
  - Test markAsReadUseCase integration
  - Test notification filtering

**Entregáveis:**

- ✅ 37 novos testes de providers
- ✅ Cobertura Providers: 40% → 80%

**Progresso:** Testes 85% → 92%

---

### Task 2.4: Testes de Integração (20h)

**Objetivo:** Testar fluxos completos end-to-end

**Subtarefas:**

#### Setup (4h)

- [ ] Instalar `integration_test` package
- [ ] Configurar Firebase Test Lab (opcional)
- [ ] Criar mocks de Firebase para testes

#### Fluxos críticos (16h)

- [ ] **Fluxo 1: Autenticação completa** (6h)
  - [ ] Sign up com email
  - [ ] Criar primeiro perfil
  - [ ] Logout
  - [ ] Login novamente
  - [ ] Verificar perfil carregado
- [ ] **Fluxo 2: Criar e interagir com post** (6h)
  - [ ] Login
  - [ ] Criar post
  - [ ] Buscar post no feed
  - [ ] Enviar interesse
  - [ ] Receber notificação
  - [ ] Abrir chat
- [ ] **Fluxo 3: Multi-profile** (4h)
  - [ ] Criar 3 perfis
  - [ ] Trocar perfil ativo
  - [ ] Verificar posts filtrados por perfil
  - [ ] Deletar perfil
  - [ ] Verificar activeProfile atualizado

**Entregáveis:**

- ✅ 3 testes de integração
- ✅ Confidence em refactorings

**Progresso:** Testes 92% → 95%

---

## 🎨 FASE 3: Excelência (1 semana - 40h)

**Meta:** 98% → 100% (+2%)  
**ROI:** Médio (polish final)

### Task 3.1: Refatorar Settings Feature (12h)

**Objetivo:** Aplicar Clean Architecture em Settings

**Subtarefas:**

#### Criar camadas (8h)

- [ ] **Domain Layer**
  ```
  features/settings/
  ├── domain/
  │   ├── entities/
  │   │   └── user_settings_entity.dart  # Freezed
  │   ├── repositories/
  │   │   └── settings_repository.dart   # Interface
  │   └── usecases/
  │       ├── get_settings_usecase.dart
  │       ├── update_theme_usecase.dart
  │       └── update_notifications_usecase.dart
  ```
- [ ] **Data Layer**
  ```
  features/settings/
  └── data/
      ├── datasources/
      │   └── settings_local_datasource.dart  # SharedPreferences
      └── repositories/
          └── settings_repository_impl.dart
  ```

#### Migrar para Riverpod (4h)

- [ ] Criar `settings_providers.dart`
- [ ] Substituir setState por AsyncNotifier
- [ ] Adicionar testes (10 testes)

**Entregáveis:**

- ✅ Settings com Clean Architecture
- ✅ 100% Riverpod usage

**Progresso:**

- Clean Architecture 95% → 98%
- Riverpod 90% → 95%

---

### Task 3.2: Refatorar Home Page (16h)

**Objetivo:** Quebrar home_page.dart (1600 linhas) em features menores

**Subtarefas:**

#### Análise (2h)

- [ ] Identificar responsabilidades:
  - Feed/Carousel
  - Map/Markers
  - Search/Filters
  - Geolocation
  - Profile switcher

#### Extrair sub-features (12h)

- [ ] **MapFeature** (4h)
  - [ ] `map_widget.dart`
  - [ ] `map_controller.dart`
  - [ ] `marker_builder.dart`
- [ ] **FeedFeature** (4h)
  - [ ] `feed_carousel.dart`
  - [ ] `post_card.dart`
  - [ ] `feed_controller.dart`
- [ ] **SearchFeature** (4h)
  - [ ] `search_bar_widget.dart`
  - [ ] `filter_dialog.dart`
  - [ ] `search_controller.dart`

#### Testar refactor (2h)

- [ ] Executar app e verificar funcionalidade
- [ ] Adicionar testes unitários (5 testes por feature)

**Entregáveis:**

- ✅ home_page.dart: 1600 → 400 linhas
- ✅ 3 features isoladas e testáveis

**Progresso:** Clean Architecture 98% → 100%

---

### Task 3.3: Code Generation Final (12h)

**Objetivo:** Atingir 100% code generation

**Subtarefas:**

#### Estados de UI (4h)

- [ ] Criar `ui_states.dart` com Freezed
  ```dart
  @freezed
  class UIState<T> with _$UIState<T> {
    const factory UIState.initial() = Initial;
    const factory UIState.loading() = Loading;
    const factory UIState.loaded(T data) = Loaded;
    const factory UIState.error(String message) = Error;
  }
  ```
- [ ] Substituir classes manuais

#### Results/Either (4h)

- [ ] Usar `fpdart` ou criar `Result<T, E>` com Freezed
  ```dart
  @freezed
  class Result<T, E> with _$Result<T, E> {
    const factory Result.success(T value) = Success;
    const factory Result.failure(E error) = Failure;
  }
  ```
- [ ] Refatorar UseCases para retornar `Result`

#### Documentação (4h)

- [ ] Atualizar README com code generation setup
- [ ] Documentar padrões de entities/DTOs
- [ ] Criar guia de contribuição

**Entregáveis:**

- ✅ 100% classes geradas
- ✅ Documentação completa

**Progresso:** Code Generation 90% → 100%

---

## 🤖 CI/CD Setup

### Task 4.1: GitHub Actions (8h)

**Workflows a criar:**

#### 1. Lint + Analyze

```yaml
name: Code Quality
on: [pull_request, push]
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze --fatal-infos
      - run: dart format --set-exit-if-changed .
```

#### 2. Tests + Coverage

```yaml
name: Tests
on: [pull_request, push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

#### 3. Build

```yaml
name: Build
on: [push]
jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

**Entregáveis:**

- ✅ 3 workflows funcionando
- ✅ Badge de status no README
- ✅ Code coverage reports

---

## 📋 Checklist Final (100%)

### 1. Feature-first + Clean Architecture ✅ 100%

- [x] 7 features com structure consistente
- [x] Domain/Data/Presentation layers
- [x] Settings refatorado
- [x] Home quebrado em sub-features

### 2. Riverpod como Padrão ✅ 100%

- [x] 6 features com providers
- [x] AsyncNotifierProvider onde apropriado
- [x] Settings migrado para Riverpod
- [x] Zero uso de setState em features principais

### 3. Código 100% Gerado ✅ 100%

- [x] Todas entities com Freezed
- [x] DTOs separados de Entities
- [x] Mappers implementados
- [x] JSON serialization completo
- [x] Estados de UI com Freezed
- [x] Result types com Freezed

### 4. Lint Strict + Conventional Commits ✅ 100%

- [x] very_good_analysis habilitado
- [x] 0 lint issues
- [x] commitlint configurado
- [x] Husky hooks ativos
- [x] CI check funcionando

### 5. Testes ✅ 95%

- [x] Use Cases: 95% cobertura
- [x] Providers: 80% cobertura
- [x] Repositories: 80% cobertura
- [x] 3 testes de integração
- [x] 200+ testes individuais

### 6. Rotas Tipadas ✅ 100%

- [x] go_router com code generation
- [x] Type-safe navigation extensions
- [x] Deep linking configurado
- [x] Analytics tracking automático

### 7. Design System Separado ✅ 100%

- [x] core_ui package isolado
- [x] Theme tokens definidos
- [x] 15+ widgets reutilizáveis
- [x] Documentação completa

---

## 📊 Cronograma Resumido

| Fase                   | Duração   | Progresso  | Entregas                           |
| ---------------------- | --------- | ---------- | ---------------------------------- |
| **Fase 1: Quick Wins** | 1 semana  | 86% → 92%  | Commits + Lint + Testes básicos    |
| **Fase 2: Fundação**   | 2 semanas | 92% → 98%  | Code gen + DTOs + Testes avançados |
| **Fase 3: Excelência** | 1 semana  | 98% → 100% | Refactors + Polish final           |
| **CI/CD**              | Paralelo  | -          | Automação completa                 |

**Total:** 4-5 semanas (160-200h)

---

## 🎯 KPIs de Sucesso

### Métricas Quantitativas

- [ ] **Lint Issues:** 118 → 0
- [ ] **Test Coverage:** 50% → 95%
- [ ] **Code Generation:** 65% → 100%
- [ ] **Conventional Commits:** 0% → 100%

### Métricas Qualitativas

- [ ] **Onboarding:** Novo dev produtivo em 1 dia
- [ ] **Confidence:** Deploy sem medo de quebrar
- [ ] **Velocity:** Features novas 30% mais rápidas
- [ ] **Bugs:** 50% menos regressões

---

## 🚀 Como Executar Este Plano

### Para cada Task:

1. **Criar branch:** `git checkout -b task-X.Y-description`
2. **Implementar:** Seguir subtarefas
3. **Testar:** Executar testes localmente
4. **Commitar:** Seguir Conventional Commits
5. **PR:** Criar com checklist da task
6. **Review:** Peer review obrigatório
7. **Merge:** Squash and merge
8. **Deploy:** Automatic via CI/CD

### Daily Checklist:

- [ ] `git pull origin main`
- [ ] `flutter pub get`
- [ ] `flutter test`
- [ ] `flutter analyze`
- [ ] Commit com mensagem conventional

### Weekly Review:

- [ ] Atualizar este documento com progresso
- [ ] Calcular % atual de cada prática
- [ ] Ajustar prioridades se necessário
- [ ] Celebrar entregas! 🎉

---

## 📚 Recursos e Referências

### Documentação Interna

- `BOAS_PRATICAS_ANALISE_2025-11-30.md` - Análise detalhada
- `SESSION_14_MULTI_PROFILE_REFACTORING.md` - Clean Architecture patterns
- `SESSION_15_BADGE_COUNTER_BEST_PRACTICES.md` - Provider patterns

### Packages Key

- [freezed](https://pub.dev/packages/freezed) - Code generation
- [riverpod_annotation](https://pub.dev/packages/riverpod_annotation) - Providers
- [go_router](https://pub.dev/packages/go_router) - Navigation
- [very_good_analysis](https://pub.dev/packages/very_good_analysis) - Lint

### External Resources

- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture/)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/about_code_generation)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)

---

**Mantido por:** Equipe de Desenvolvimento  
**Última Revisão:** 30/11/2025  
**Próxima Revisão:** Semanalmente até 100%
