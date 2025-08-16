import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jsonapp/Features/post_provider.dart';
import 'package:jsonapp/Features/user_providers.dart';
import 'package:jsonapp/Widgets/postcard.dart';

import '../Models/user.dart';

final selectedUserProvider = StateProvider<int?>((ref) => null);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final postsAsync = ref.watch(postsProvider);
    final selectedUserId = ref.watch(selectedUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: usersAsync.when(
        data: (users) {
          if (selectedUserId == null) {
            // Show user list
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('@${user.username}'),
                        Text(user.email),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ref.read(selectedUserProvider.notifier).state = user.id;
                    },
                  ),
                );
              },
            );
          } else {
            // Show selected user profile
            User? user;
            try {
              user = users.firstWhere((u) => u.id == selectedUserId);
            } catch (e) {
              // User not found, go back to list
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(selectedUserProvider.notifier).state = null;
              });
              return const Center(child: Text('User not found'));
            }
            
            final userPosts = postsAsync.value
                    ?.where((post) => post.userId == selectedUserId)
                    .toList() ??
                [];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  ref.read(selectedUserProvider.notifier).state = null;
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: Text(
                                        user.name.isNotEmpty 
                                            ? user.name[0].toUpperCase() 
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      user.name,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    Text(
                                      '@${user.username}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 48), // Balance the back button
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoTile('Email', user.email, Icons.email),
                              _buildInfoTile('Phone', user.phone, Icons.phone),
                              _buildInfoTile('Website', user.website, Icons.web),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildAddressInfo(user),
                          const SizedBox(height: 16),
                          _buildCompanyInfo(user),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Posts (${userPosts.length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = userPosts[index];
                      return PostCard(post: post, user: user!);
                    },
                    childCount: userPosts.length,
                  ),
                ),
              ],
            );
          }
        },
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
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfo(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${user.address.street}, ${user.address.suite}'),
            Text('${user.address.city} ${user.address.zipcode}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.company.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(user.company.catchPhrase),
          ],
        ),
      ),
    );
  }
}
