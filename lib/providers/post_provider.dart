import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import 'dart:async';
import '../repositories/post_repository.dart';

class PostNotifier extends AsyncNotifier<List<Post>> {
  late final IPostRepository _repo;

  @override
  FutureOr<List<Post>> build() async {
    _repo = ref.read(postRepositoryProvider);
    return _repo.getPosts();
  }

  Future<void> refresh() async {
    state = AsyncValue.data(await _repo.getPosts());
  }
}

final postProvider =
    AsyncNotifierProvider<PostNotifier, List<Post>>(PostNotifier.new);
