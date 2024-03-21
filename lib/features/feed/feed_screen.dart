import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/features/story/screens/story_list_screen.dart';
import 'package:untitled/responsive/responsive.dart';

import '../../core/common/posts/post_card.dart';
import '../../core/constants/constants.dart';
import '../../theme/palette.dart';
import '../auth/controller/auth_controller.dart';
import '../community/controller/community_controller.dart';
import '../home/delegates/search_delegates.dart';
import '../home/drawers/community_list_drawer.dart';
import '../home/drawers/profile_drawer.dart';
import '../post/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Responsive(
      child: Scaffold(
          drawer: isGuest ? null : const CommunityListDrawer(),
          endDrawer: const ProfileDrawer(),
          appBar: AppBar(
            leading: Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => displayDrawer(context),
              );
            }),
            title: Text('Home', style: GoogleFonts.poppins()),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.search),
                onPressed: () {
                  showSearch(context: context, delegate: SearchCommunityScreen(ref: ref));
                },
              ),
              Builder(builder: (context) {
                return IconButton(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePic),
                    ),
                  ),
                  onPressed: () => displayEndDrawer(context),
                );
              })
            ],
          ),
          body: ref.watch(userCommunitiesProvider).when(
                data: (communities) {
                  if (isGuest) {
                    return ref.watch(guestPostsProvider).when(
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
                            return ErrorText(error: e.toString());
                          },
                        );
                  }
                  return NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return [
                         SliverToBoxAdapter(
                          child: GestureDetector(
                            onTap: () {
                              Routemaster.of(context).push('/add-post');
                            },
                            child: isGuest
                                ? const SizedBox()
                                : Container(
                              color: currentTheme.backgroundColor,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [12, 4],
                                  strokeCap: StrokeCap.round,
                                  color: currentTheme.textTheme.bodyMedium!.color!,
                                  child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const SizedBox(width: 10),
                                           CircleAvatar(
                                            backgroundImage: Image.asset(Constants.loginEmotePath).image,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'What\'s on your mind?',
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5 ),
                                          const Icon(
                                            CupertinoIcons.add_circled,
                                            color: Colors.grey,
                                          )
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: StoryListScreen(),
                        ),
                      ];
                    },
                    body: ref.watch(userPostsProvider(communities)).when(
                      data: (posts) {
                        if (posts.isEmpty) {
                          return const Center(
                            child: Text(
                              'No posts yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return PostCard(post: post);
                          },
                        );
                      },
                      loading: () {
                        if (communities.isEmpty) {
                          return const Center(
                            child: Text(
                              'Please join a community to see posts',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const Loader();
                      },
                      error: (e, s) {
                        return ErrorText(error: e.toString());
                      },
                    ),
                  );
                },
                loading: () => const Loader(),
                error: (e, s) => ErrorText(error: e.toString()),
              )),
    );
  }
}
