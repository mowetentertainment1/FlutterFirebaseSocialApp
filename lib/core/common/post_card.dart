  import 'package:dotted_border/dotted_border.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
  import 'package:untitled/core/common/photo_view.dart';
  import 'package:untitled/model/post_model.dart';
  import 'package:untitled/theme/pallete.dart';

  import '../../features/auth/controller/auth_controller.dart';

  class PostCard extends ConsumerWidget {
    final Post post;

    const PostCard({super.key, required this.post});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final isTypeImage = post.type == 'image';
      final isTypeText = post.type == 'text';
      final user = ref.watch(userProvider)!;
      final currentTheme = ref.watch(themeNotifierProvider);
      return Column(
        children: [
          Container(
              decoration: BoxDecoration(
                color: currentTheme.textTheme.bodyText2!.color!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        NetworkImage(post.communityProfilePic),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'r/${post.communityName}',
                                          style: currentTheme.textTheme.bodyText2!
                                              .copyWith(
                                            color: currentTheme
                                                .textTheme.bodyText2!.color!
                                                .withOpacity(0.8),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'u/${post.username}',
                                          style: currentTheme.textTheme.bodyText2!
                                              .copyWith(
                                            color: currentTheme
                                                .textTheme.bodyText2!.color!
                                                .withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (post.uid == user.uid)
                                    PopupMenuButton(
                                        itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         EditPostScreen(post: post),
                                            //   ),
                                            // );
                                          } else {
                                            // _ref
                                            //     .read(postControllerProvider.notifier)
                                            //     .deletePost(post.id);
                                          }
                                        }),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post.title,
                                style: GoogleFonts.poppins().copyWith(
                                  color: currentTheme.textTheme.bodyText2!.color,
                                  fontSize: 16,
                                    letterSpacing: 0.5,

                                ),
                              ),
                              const SizedBox(height: 10),
                              if (isTypeImage)
                                SizedBox(
                                  height: 300,
                                  child: GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                    ),
                                    itemCount: post.linkImage.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(10),
                                          dashPattern: const [12, 4],
                                          strokeCap: StrokeCap.round,
                                          color: currentTheme
                                              .textTheme.bodyText2!.color!,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageZoomScreen(
                                                    imageUrls: post.linkImage,
                                                    initialIndex: index,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              width: double.infinity,
                                              child: Image.network(
                                                post.linkImage[index],

                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
