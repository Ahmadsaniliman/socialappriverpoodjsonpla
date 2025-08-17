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
    
    // Add interceptor for better error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          String errorMessage = 'Network error occurred';
          
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
              errorMessage = 'Connection timeout - please check your internet connection';
              break;
            case DioExceptionType.receiveTimeout:
              errorMessage = 'Request timeout - server is taking too long to respond';
              break;
            case DioExceptionType.connectionError:
              errorMessage = 'No internet connection available';
              break;
            case DioExceptionType.badResponse:
              errorMessage = 'Server error: ${e.response?.statusCode}';
              break;
            default:
              errorMessage = 'Failed to connect to server';
          }
          
          handler.next(DioException(
            requestOptions: e.requestOptions,
            message: errorMessage,
            type: e.type,
          ));
        },
      ),
    );
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<List<Post>> getPosts() async {
    try {
      final response = await _dio.get('/posts');
      return (response.data as List)
          .map((json) => Post.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: ${e.toString()}');
    }
  }

  Future<List<Comment>> getComments(int postId) async {
    try {
      final response = await _dio.get('/posts/$postId/comments');
      return (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch comments: ${e.toString()}');
    }
  }

  Future<User> getUser(int userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }
}
