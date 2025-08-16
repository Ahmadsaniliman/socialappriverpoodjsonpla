import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jsonapp/Features/connectivity_provider.dart';
import 'package:jsonapp/Features/user_providers.dart';
import 'package:jsonapp/Models/post.dart';
import 'package:jsonapp/Services/network.dart';
import 'package:jsonapp/Storage/local_storage.dart';

class PostsNotifier extends AsyncNotifier<List<Post>> {
  late ApiClient _apiClient;
  late LocalStorage _localStorage;

  @override
  Future<List<Post>> build() async {
    _apiClient = ref.read(apiClientProvider);
    _localStorage = ref.read(localStorageProvider);
    
    final isConnected = await ref.watch(connectivityProvider.future);
    
    if (isConnected) {
      try {
        final posts = await _apiClient.getPosts();
        await _localStorage.savePosts(posts);
        return posts;
      } catch (e) {
        return await _localStorage.getPosts();
      }
    } else {
      return await _localStorage.getPosts();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final posts = await _apiClient.getPosts();
      await _localStorage.savePosts(posts);
      return posts;
    });
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  () => PostsNotifier(),
);
