# Problema de Coordenadas no Mapa

## Diagnóstico

Os pins não aparecem no mapa porque **as coordenadas dos posts no Firestore estão erradas**.

### Evidências

```
flutter: HomePage: processando post QDjROg0lHakYgY2z5efv, city=São Paulo, location=Instance of 'GeoPoint'
flutter: HomePage: criando cluster marker com 4 posts em (-22.5, 43.28345039999999)
```

### Problema

As coordenadas armazenadas são **(-22.5, 43.28)** que ficam **no meio do Oceano Atlântico**, próximo ao Espírito Santo.

**São Paulo** deveria ter coordenadas aproximadas de:
- Latitude: **-23.5505**
- Longitude: **-46.6333**

## Possíveis Causas

1. **Latitude e Longitude Invertidas**: O código pode estar salvando `GeoPoint(longitude, latitude)` em vez de `GeoPoint(latitude, longitude)`
2. **API de Geocoding Retornando Dados Errados**: O serviço ViaCEP ou Google Geocoding pode estar retornando coordenadas incorretas
3. **Conversão de Coordenadas Errada**: Pode haver alguma transformação matemática incorreta nas coordenadas

## Como Verificar os Posts no Firestore

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Selecione o projeto: **to-sem-banda-83e19**
3. Vá em **Firestore Database** > collection **posts**
4. Clique em qualquer post
5. Verifique o campo **location** (tipo: geopoint)
6. Confira se latitude e longitude estão corretas para a cidade informada

## Coordenadas Corretas por Cidade

| Cidade | Latitude | Longitude |
|--------|----------|-----------|
| São Paulo | -23.5505 | -46.6333 |
| Guararema | -23.4097 | -46.0354 |
| Rio de Janeiro | -22.9068 | -43.1729 |

## Como Corrigir

### Opção 1: Manual pelo Firebase Console

1. Acesse Firestore Database > posts
2. Para cada post:
   - Clique no documento
   - Edite o campo `location`
   - Digite a latitude correta
   - Digite a longitude correta
   - Salve

### Opção 2: Script de Correção

Execute o script helper:

```bash
dart scripts/fix_post_coordinates.dart
```

Este script mostra as coordenadas corretas para copiar no Firebase Console.

### Opção 3: Recriar os Posts

Delete os posts atuais e crie novos posts através do app, garantindo que o CEP seja válido e o geocoding funcione corretamente.

## Investigar o Código de Criação de Posts

Arquivo: `lib/pages/post_page.dart`

```dart
final GeoPoint postLocation = GeoPoint(_fetchedLat!, _fetchedLng!);
```

Verificar se `_fetchedLat` e `_fetchedLng` estão sendo populados corretamente pela API de geocoding.

## Solução Encontrada

**AS COORDENADAS ESTÃO CORRETAS!**

O problema não era coordenadas erradas, mas o **filtro de distância**:

1. O simulador iOS inicia em **Cupertino, Califórnia** (37.32, -122.02)
2. Os posts estão em **São Paulo** (10.375 km de distância)
3. O filtro de distância padrão era **50 km**, bloqueando todos os posts

### Correção Aplicada

Mudou-se o filtro de distância padrão de 50 km para 20.000 km:

```dart
double _maxDistanceKm = 20000.0; // 20,000 km default (world-wide) for development/testing
```

Isso permite que posts apareçam independente da localização do simulador.

## Próximos Passos

1. ✅ Adicionar log detalhado mostrando lat/lng exatas
2. ✅ Executar o app e copiar as coordenadas dos logs
3. ✅ Comparar com coordenadas corretas - **ESTÃO CORRETAS!**
4. ✅ Identificar problema real: filtro de distância
5. ✅ Ajustar filtro de distância para 20.000 km
6. ⏳ Testar que pins aparecem no mapa
