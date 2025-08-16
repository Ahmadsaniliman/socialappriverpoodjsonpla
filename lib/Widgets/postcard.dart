import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jsonapp/Features/comment_provider.dart';
import 'package:jsonapp/Models/post.dart';
import 'package:jsonapp/Models/user.dart';

import '../Models/comment.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  final User user;

  const PostCard({
    super.key,
    required this.post,
    required this.user,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _showComments = false;
  List<Comment> _comments = [];
  bool _isLoadingComments = false;

  Future<void> _toggleComments() async {
    if (_showComments) {
      setState(() {
        _showComments = false;
      });
    } else {
      setState(() {
        _isLoadingComments = true;
        _showComments = true;
      });

      try {
        final comments = await ref
            .read(commentsProvider.notifier)
            .getComments(widget.post.id);
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                widget.user.name.isNotEmpty 
                    ? widget.user.name[0].toUpperCase() 
                    : 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(widget.user.name),
            subtitle: Text('@${widget.user.username}'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.post.body),
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton.icon(
                onPressed: _toggleComments,
                icon: Icon(_showComments ? Icons.expand_less : Icons.expand_more),
                label: Text(_showComments ? 'Hide Comments' : 'Show Comments'),
              ),
            ],
          ),
          if (_showComments) ...[
            const Divider(),
            if (_isLoadingComments)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ..._comments.map((comment) => _buildCommentTile(comment)),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Text(
              comment.name.isNotEmpty ? comment.name[0].toUpperCase() : 'C',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  comment.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.body,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

