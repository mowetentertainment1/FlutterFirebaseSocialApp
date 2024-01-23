import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/core/common/loader.dart';

import '../../core/common/post_card.dart';
import '../community/controller/community_controller.dart';
import '../post/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userCommunitiesProvider).when(
          data: (communities) {
            return ref.watch(userPostsProvider(communities)).when(
                  data: (posts) {
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(post: post);
                      },
                    );
                  },
                  loading: () => const Loader(),
                  error: (e, s) {
                    // print(e);
                    return ErrorText(error: e.toString());
                  },
                );
          },
          loading: () => const Loader(),
          error: (e, s) => ErrorText(error: e.toString()),
        );
  }
}
