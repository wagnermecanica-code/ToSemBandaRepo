import '../models/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IPostRepository {
  Future<List<Post>> getPosts();
}

class PostRepository implements IPostRepository {
  @override
  Future<List<Post>> getPosts() async {
    // TODO: Implement Firestore query
    throw UnimplementedError();
  }
}

final postRepositoryProvider = Provider<IPostRepository>((ref) {
  return PostRepository();
});
