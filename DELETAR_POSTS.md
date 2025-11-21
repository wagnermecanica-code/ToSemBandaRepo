# 🗑️ GUIA: Como Deletar Posts Antigos (Opção A)

## Método 1: Console Web do Firebase (RECOMENDADO - Mais Fácil)

### Passos:

1. **Abra o Console do Firebase:**
   ```
   https://console.firebase.google.com/project/to-sem-banda-83e19/firestore/data/posts
   ```

2. **Para cada documento na coleção `posts`:**
   - Clique no documento
   - Verifique se existe o campo `location` (tipo: geopoint)
   - Se NÃO existir, clique no botão de 3 pontos (⋮) no canto superior direito
   - Selecione "Delete document"
   - Confirme a deleção

3. **Repita até que todos os posts sem `location` sejam deletados**

---

## Método 2: Firebase CLI (Via Terminal)

Se você preferir usar a linha de comando:

```bash
# Execute o script que criei:
./scripts/delete_posts_cli.sh
```

⚠️ **Nota:** O método CLI pode não funcionar perfeitamente porque a Firebase CLI tem limitações para queries complexas.

---

## Método 3: Via Código (Mais Técnico)

Se você quiser deletar programaticamente de dentro do app:

1. Adicione este botão temporário em alguma página admin
2. Execute uma vez
3. Remova o código

```dart
// Código exemplo (NÃO adicione ainda - vou criar se você quiser)
Future<void> deletePostsWithoutLocation() async {
  final posts = await FirebaseFirestore.instance.collection('posts').get();
  for (final doc in posts.docs) {
    if (!doc.data().containsKey('location')) {
      await doc.reference.delete();
    }
  }
}
```

---

## ✅ Após Deletar os Posts Antigos:

1. Execute o app: `flutter run`
2. Crie um NOVO post
3. O novo post terá o campo `location` automaticamente
4. Verifique se ele aparece:
   - HomePage (mapa com marcadores)
   - Perfil → Aba Posts

---

## 🔍 Para Verificar se Ainda Existem Posts Sem Location:

Acesse o Firestore e procure por documentos que NÃO tenham o campo `location`.

Console: https://console.firebase.google.com/project/to-sem-banda-83e19/firestore/data/posts
