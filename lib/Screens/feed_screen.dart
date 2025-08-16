import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jsonapp/Features/connectivity_provider.dart';
import 'package:jsonapp/Features/post_provider.dart';
import 'package:jsonapp/Features/user_providers.dart';
import 'package:jsonapp/Models/user.dart';
import 'package:jsonapp/Widgets/postcard.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    final usersAsync = ref.watch(usersProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          connectivityAsync.when(
            data: (isConnected) => Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: isConnected ? Colors.green : Colors.red,
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Icon(Icons.error, color: Colors.red),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.refresh(postsProvider.future),
            ref.refresh(usersProvider.future),
          ]);
        },
        child: postsAsync.when(
          data: (posts) => usersAsync.when(
            data: (users) => ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                User? user;
                try {
                  user = users.firstWhere((u) => u.id == post.userId);
                } catch (e) {
                  user = users.isNotEmpty ? users.first : const User(
                    id: 0, name: 'Unknown', username: 'unknown', email: '', phone: '', website: '',
                    address: Address(street: '', suite: '', city: '', zipcode: '', geo: Geo(lat: '0', lng: '0')),
                    company: Company(name: '', catchPhrase: '', bs: ''),
                  );
                }
                return PostCard(post: post, user: user);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading users: $error'),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(usersProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading posts: $error'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(postsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
