import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import 'dart:async';
import '../repositories/conversation_repository.dart';

class ConversationNotifier extends AsyncNotifier<List<Conversation>> {
  late final IConversationRepository _repo;

  @override
  FutureOr<List<Conversation>> build() async {
    _repo = ref.read(conversationRepositoryProvider);
    return _repo.getConversations();
  }

  Future<void> refresh() async {
    state = AsyncValue.data(await _repo.getConversations());
  }
}

final conversationProvider =
    AsyncNotifierProvider<ConversationNotifier, List<Conversation>>(ConversationNotifier.new);
