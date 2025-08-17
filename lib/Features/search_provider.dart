import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jsonapp/Features/post_provider.dart';
import 'package:jsonapp/Features/user_providers.dart';
import 'package:jsonapp/Models/post.dart';
import 'package:jsonapp/Models/user.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredPostsProvider = Provider<List<Post>>((ref) {
  final posts = ref.watch(postsProvider).value ?? [];
  final users = ref.watch(usersProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  
  if (query.isEmpty) return posts;
  
  return posts.where((post) {
    User? user;
    try {
      user = users.firstWhere((u) => u.id == post.userId);
    } catch (e) {
      user = const User(
        id: 0, name: '', username: '', email: '', phone: '', website: '',
        address: Address(street: '', suite: '', city: '', zipcode: '', geo: Geo(lat: '0', lng: '0')),
        company: Company(name: '', catchPhrase: '', bs: ''),
      );
    }
    
    return post.title.toLowerCase().contains(query) ||
           post.body.toLowerCase().contains(query) ||
           user.name.toLowerCase().contains(query) ||
           user.username.toLowerCase().contains(query);
  }).toList();
});

final filteredUsersProvider = Provider<List<User>>((ref) {
  final users = ref.watch(usersProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  
  if (query.isEmpty) return users;
  
  return users.where((user) {
    return user.name.toLowerCase().contains(query) ||
           user.username.toLowerCase().contains(query) ||
           user.email.toLowerCase().contains(query);
  }).toList();
});
