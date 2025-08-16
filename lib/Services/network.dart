import 'package:dio/dio.dart';
import 'package:jsonapp/Models/comment.dart';
import 'package:jsonapp/Models/post.dart';
import 'package:jsonapp/Models/user.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<List<Post>> getPosts() async {
    try {
      final response = await _dio.get('/posts');
      return (response.data as List)
          .map((json) => Post.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<List<Comment>> getComments(int postId) async {
    try {
      final response = await _dio.get('/posts/$postId/comments');
      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<User> getUser(int userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }
}
