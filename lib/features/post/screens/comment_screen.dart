import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/core/common/post_card.dart';

import '../../../core/common/loader.dart';
import '../../../model/post_model.dart';
import '../controller/post_controller.dart';
import '../widget/comment_card.dart';

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

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          text: _commentController.text.trim(),
          post: post,
        );
    setState(() {
      _commentController.text = '';
    });
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
                  // if (!isGuest)
                  //   Responsive(
                  //     child:
                  SizedBox(
                    height: 50,
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        hintText: 'Add a comment',
                        suffixIcon: GestureDetector(
                            onTap: () {
                              addComment(post);
                            },
                            child: const Icon(Icons.send, color: Colors.blue)),
                      ),
                      onSubmitted: (value) {
                        addComment(post);
                      },
                    ),
                  ),
                  // ),
                  ref.watch(getPostCommentsProvider(widget.postId)).when(
                        data: (data) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = data[index];
                                return CommentCard(comment: comment);
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) {
                          return ErrorText(
                            error: error.toString(),
                          );
                        },
                        loading: () => const Loader(),
                      ),
                ],
              );
              ;
            },
            error: (Object error, StackTrace stackTrace) {
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader()));
  }
}
