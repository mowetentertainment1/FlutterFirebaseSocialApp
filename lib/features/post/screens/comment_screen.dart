import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/core/common/post_card.dart';

import '../../../core/common/loader.dart';
import '../controller/post_controller.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
        ),
        body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              return Column(
                children: [
                      PostCard(post: post),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text('Comment $index'),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Container(
                        decoration:
                            BoxDecoration(color: Theme.of(context).cardColor),
                        child: IconTheme(
                          data: IconThemeData(
                              color: Theme.of(context).colorScheme.secondary),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: const InputDecoration(
                                      hintText: 'Add a comment...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {}),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
              );
            },
            error: (Object error, StackTrace stackTrace) {
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader()));
  }
}
