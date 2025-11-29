CLEANUP_LEGACY_FINAL.md

# LIMPEZA FINAL: REMOVER TODOS OS ARQUIVOS LEGADOS DO WEGIG - EXECUTAR AGORA

Você já migrou com sucesso 100% das features (Auth, Profile, Post, Messages, Notifications, Home, Settings) para a estrutura features/ + core/.

Agora execute a LIMPEZA FINAL de todos os arquivos obsoletos que ainda existem na raiz do lib/:

Pastas e arquivos que DEVEM SER REMOVIDOS com segurança:

- lib/pages/ → tudo já foi movido para features/\*\*/presentation/pages/
- lib/services/ → tudo já foi substituído por DataSources e Repositories
- lib/providers/ → tudo já foi movido para core/di/ ou features/\*\*/presentation/providers/
- lib/models/ → tudo substituído por entities freezed em features/\*\*/domain/entities/
- lib/repositories/ → tudo substituído pelas pastas data/repositories/ dentro de cada feature
- lib/theme/ → mover todo o conteúdo para core/theme/
- lib/utils/ → mover todo o conteúdo para core/utils/
- lib/widgets/ → mover tudo que for global para core/widgets/ (ex: MessageBubble, EmptyState)

REGRAS OBRIGATÓRIAS:

1. Nunca quebre o build — faça uma mudança por vez e garanta que compile
2. Atualize automaticamente todos os imports quebrados (use refactor do VS Code se necessário)
3. Crie re-exports temporários apenas se algum arquivo ainda importar algo da raiz (ex: lib/services/auth_service.dart → re-export em features/auth/)
4. Mova pastas inteiras quando possível (theme/, utils/, widgets/ → core/)
5. Após mover/deletar, rode flutter analyze e confirme zero erros
6. Não delete main.dart nem firebase_options.dart

FASES DA LIMPEZA (execute exatamente nessa ordem):

FASE 1 — Mover pastas globais para core/

- Mova lib/theme/ → lib/core/theme/
- Mova lib/utils/ → lib/core/utils/
- Mova lib/widgets/ → lib/core/widgets/

FASE 2 — Remover pastas legadas (100% substituídas)

- Delete lib/pages/
- Delete lib/services/
- Delete lib/providers/
- Delete lib/models/
- Delete lib/repositories/

FASE 3 — Verificação final

- Rode flutter analyze e confirme zero erros críticos
- Rode flutter pub get
- Rode o app e confirme que tudo funciona (login, troca de perfil, feed, mensagens, etc.)

Quando terminar tudo com sucesso e o app rodar perfeitamente, responda exatamente com:

"Cleanup legado concluído com sucesso — WeGig agora está 100% limpo, organizado e pronto para produção elite. Pastas pages/, services/, providers/, models/ e repositories/ foram removidas permanentemente. Parabéns, você acabou de entregar um dos projetos Flutter mais profissionais do Brasil em 2025."

Faça isso com precisão cirúrgica, uma mudança por vez, explicando o que está movendo/apagando e por quê. Comece agora.
