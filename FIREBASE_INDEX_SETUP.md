# Firebase Index Setup

## Índice Necessário para Filtro de Cidade

Para permitir filtros eficientes por cidade com muitos usuários, é necessário criar um índice composto no Firestore.

### Opção 1: Via Console (Recomendado)
Acesse o link abaixo para criar automaticamente o índice:

https://console.firebase.google.com/v1/r/project/to-sem-banda-83e19/firestore/indexes?create_composite=ClBwcm9qZWN0cy90by1zZW0tYmFuZGEtODNlMTkvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Bvc3RzL2luZGV4ZXMvXxABGggKBGNpdHkQARoNCgljcmVhdGVkQXQQAhoNCglleHBpcmVzQXQQAhoMCghfX25hbWVfXxAC

### Opção 2: Via CLI
Execute o comando:
```bash
firebase deploy --only firestore:indexes
```

### Detalhes do Índice
- **Collection**: posts
- **Campos**:
  1. city (Ascending)
  2. expiresAt (Ascending)
  3. createdAt (Descending)

### Tempo de Criação
A criação do índice pode levar alguns minutos. Aguarde a mensagem "Building" mudar para "Enabled" no console.

### Por que é necessário?
Com muitos usuários, filtrar por cidade no lado do cliente (baixando todos os posts e filtrando localmente) causaria:
- Alto consumo de dados
- Lentidão no carregamento
- Custos elevados de leitura no Firestore

O índice permite que o Firestore filtre no servidor, retornando apenas os posts relevantes.
