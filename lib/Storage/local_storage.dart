import 'dart:convert';

import 'package:jsonapp/Models/comment.dart';
import 'package:jsonapp/Models/post.dart';
import 'package:jsonapp/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _usersKey = 'users';
  static const String _postsKey = 'posts';
  static const String _commentsKey = 'comments';

  Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = users.map((user) => user.toJson()).toList();
    await prefs.setString(_usersKey, jsonEncode(jsonList));
  }

  Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_usersKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => User.fromJson(json)).toList();
  }

  Future<void> savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = posts.map((post) => post.toJson()).toList();
    await prefs.setString(_postsKey, jsonEncode(jsonList));
  }

  Future<List<Post>> getPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_postsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Post.fromJson(json)).toList();
  }

  Future<void> saveComments(int postId, List<Comment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = comments.map((comment) => comment.toJson()).toList();
    await prefs.setString('${_commentsKey}_$postId', jsonEncode(jsonList));
  }

  Future<List<Comment>> getComments(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_commentsKey}_$postId');
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Comment.fromJson(json)).toList();
  }
}
