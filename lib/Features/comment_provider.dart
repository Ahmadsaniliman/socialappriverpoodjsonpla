import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jsonapp/Features/connectivity_provider.dart';
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

    final isConnected = await ref.read(connectivityProvider.future);
    
    List<Comment> comments;
    if (isConnected) {
      try {
        comments = await _apiClient.getComments(postId);
        await _localStorage.saveComments(postId, comments);
      } catch (e) {
        comments = await _localStorage.getComments(postId);
      }
    } else {
      comments = await _localStorage.getComments(postId);
    }

    state = AsyncValue.data({...currentState, postId: comments});
    return comments;
  }
}

final commentsProvider = AsyncNotifierProvider<CommentsNotifier, Map<int, List<Comment>>>(
  () => CommentsNotifier(),
);
