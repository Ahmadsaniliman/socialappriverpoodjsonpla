import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jsonapp/Models/user.dart';
import 'package:jsonapp/Services/network.dart';
import 'package:jsonapp/Storage/local_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

class UsersNotifier extends AsyncNotifier<List<User>> {
  late ApiClient _apiClient;
  late LocalStorage _localStorage;

  @override
  Future<List<User>> build() async {
    _apiClient = ref.read(apiClientProvider);
    _localStorage = ref.read(localStorageProvider);
    
    try {
      // Try to fetch from API first
      final users = await _apiClient.getUsers();
      await _localStorage.saveUsers(users);
      return users;
    } catch (e) {
      // If network fails, fallback to cached data
      final cachedUsers = await _localStorage.getUsers();
      if (cachedUsers.isNotEmpty) {
        return cachedUsers;
      }
      // If no cached data, rethrow the error
      throw Exception('No internet connection and no cached data available');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final users = await _apiClient.getUsers();
        await _localStorage.saveUsers(users);
        return users;
      } catch (e) {
        // Return cached data if available during refresh
        final cachedUsers = await _localStorage.getUsers();
        if (cachedUsers.isNotEmpty) {
          return cachedUsers;
        }
        rethrow;
      }
    });
  }

  User? getUserById(int userId) {
    final users = state.value;
    if (users == null) return null;
    
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return const User(
        id: 0,
        name: 'Unknown User',
        username: 'unknown',
        email: '',
        phone: '',
        website: '',
        address: Address(
          street: '',
          suite: '',
          city: '',
          zipcode: '',
          geo: Geo(lat: '0', lng: '0'),
        ),
        company: Company(name: '', catchPhrase: '', bs: ''),
      );
    }
  }
}

final usersProvider = AsyncNotifierProvider<UsersNotifier, List<User>>(
  () => UsersNotifier(),
);
