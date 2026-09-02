import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class CommunityPostsScreen extends StatefulWidget {
  const CommunityPostsScreen({super.key});

  @override
  State<CommunityPostsScreen> createState() => _CommunityPostsScreenState();
}

class _CommunityPostsScreenState extends State<CommunityPostsScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final list = await SupabaseService.instance.fetchPosts();
    setState(() {
      _posts = list;
      _isLoading = false;
    });
  }

  void _showCreatePostDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Post / Assistance Request'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share a community announcement or request assistance...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await SupabaseService.instance
                    .createPost(controller.text.trim());
                Navigator.pop(ctx);
                _loadPosts();
              }
            },
            child: const Text('Publish Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Posts & Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppTheme.primaryEmerald,
        icon: const Icon(Icons.edit),
        label: const Text('Create Post'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(child: Text('No community posts yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (ctx, i) {
                    final item = _posts[i];
                    final canDelete = auth.isManagement ||
                        item.userId == auth.currentProfile?.id;

                    return CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryEmerald
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  (item.authorName != null &&
                                          item.authorName!.isNotEmpty)
                                      ? item.authorName![0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryEmerald,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.authorName ?? 'Community Member',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      dateFormat.format(item.createdAt),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                  status: item.authorRole ?? 'member',
                                  isRole: true),
                              if (canDelete)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20, color: Colors.red),
                                  onPressed: () async {
                                    await SupabaseService.instance
                                        .deletePost(item.id);
                                    _loadPosts();
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.content,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
