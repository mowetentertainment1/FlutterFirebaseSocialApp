import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/core/common/error_text.dart';
import 'package:untitled/core/common/loader.dart';

import '../../core/common/posts/post_card.dart';
import '../auth/controller/auth_controller.dart';
import '../community/controller/community_controller.dart';
import '../home/delegates/search_delegates.dart';
import '../home/drawers/community_list_drawer.dart';
import '../home/drawers/profile_drawner.dart';
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
    return Scaffold(
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
                        return ErrorText(error: e.toString());
                      },
                    );
              },
              loading: () => const Loader(),
              error: (e, s) => ErrorText(error: e.toString()),
            ));
  }
}
