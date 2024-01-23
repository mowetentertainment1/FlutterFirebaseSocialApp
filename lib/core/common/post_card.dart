import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/model/post_model.dart';
import 'package:untitled/theme/pallete.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final currentTheme = ref.watch(themeNotifierProvider);
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
              color: currentTheme.drawerTheme.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4)
                            .copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      NetworkImage(post.communityProfilePic),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'r/${post.communityName}',
                                        style: currentTheme.textTheme.bodyText2!
                                            .copyWith(
                                          color: currentTheme
                                              .textTheme.bodyText2!.color!
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      Text(
                                        'u/${post.username}',
                                        style: currentTheme.textTheme.bodyText2!
                                            .copyWith(
                                          color: currentTheme
                                              .textTheme.bodyText2!.color!
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              post.title,
                              style: currentTheme.textTheme.bodyText2!.copyWith(
                                color: currentTheme.textTheme.bodyText2!.color!
                                    .withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (isTypeImage)
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                child: Image.network(post.linkImage[0]),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.arrow_upward),
                                    ),
                                    Text(
                                      post.upvotes.length.toString(),
                                      style: currentTheme.textTheme.bodyText2!
                                          .copyWith(
                                        color: currentTheme
                                            .textTheme.bodyText2!.color!
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.arrow_downward),
                                    ),
                                    Text(
                                      post.downvotes.length.toString(),
                                      style: currentTheme.textTheme.bodyText2!
                                          .copyWith(
                                        color: currentTheme
                                            .textTheme.bodyText2!.color!
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.comment),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ],
    );
  }
}
