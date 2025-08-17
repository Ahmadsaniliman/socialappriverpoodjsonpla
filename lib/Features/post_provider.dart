import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    
    try {
      // Try to fetch from API first
      final posts = await _apiClient.getPosts();
      await _localStorage.savePosts(posts);
      return posts;
    } catch (e) {
      // If network fails, fallback to cached data
      final cachedPosts = await _localStorage.getPosts();
      if (cachedPosts.isNotEmpty) {
        return cachedPosts;
      }
      // If no cached data, rethrow the error
      throw Exception('No internet connection and no cached data available');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final posts = await _apiClient.getPosts();
        await _localStorage.savePosts(posts);
        return posts;
      } catch (e) {
        // Return cached data if available during refresh
        final cachedPosts = await _localStorage.getPosts();
        if (cachedPosts.isNotEmpty) {
          return cachedPosts;
        }
        rethrow;
      }
    });
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  () => PostsNotifier(),
);