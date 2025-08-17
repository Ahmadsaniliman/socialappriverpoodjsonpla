import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jsonapp/Features/user_providers.dart';
import 'package:jsonapp/Models/comment.dart';
import 'package:jsonapp/Services/network.dart';
import 'package:jsonapp/Storage/local_storage.dart';

class CommentsNotifier extends AsyncNotifier<Map<int, List<Comment>>> {
  late ApiClient _apiClient;
  late LocalStorage _localStorage;

  @override
  Future<Map<int, List<Comment>>> build() async {
    _apiClient = ref.read(apiClientProvider);
    _localStorage = ref.read(localStorageProvider);
    return {};
  }

  Future<List<Comment>> getComments(int postId) async {
    final currentState = state.value ?? <int, List<Comment>>{};
    
    if (currentState.containsKey(postId)) {
      return currentState[postId]!;
    }

    List<Comment> comments;
    try {
      // Try to fetch from API first
      comments = await _apiClient.getComments(postId);
      await _localStorage.saveComments(postId, comments);
    } catch (e) {
      // If network fails, fallback to cached data
      comments = await _localStorage.getComments(postId);
    }

    state = AsyncValue.data({...currentState, postId: comments});
    return comments;
  }
}

final commentsProvider = AsyncNotifierProvider<CommentsNotifier, Map<int, List<Comment>>>(
  () => CommentsNotifier(),
);