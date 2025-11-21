// conversation.dart
// Modelo mínimo para restaurar build e dependências

class Conversation {
  final String id;
  final List<String> participantProfileIds;
  final DateTime lastMessageAt;

  Conversation({
    required this.id,
    required this.participantProfileIds,
    required this.lastMessageAt,
  });
}
