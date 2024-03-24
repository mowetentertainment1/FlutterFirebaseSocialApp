
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routemaster/routemaster.dart';

import '../../../theme/palette.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/story_controller.dart';

class StoryListScreen extends ConsumerStatefulWidget {
  const StoryListScreen({super.key});

  @override
  ConsumerState<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends ConsumerState<StoryListScreen> {
  void navigateToCreateStory() {
    Routemaster.of(context).push('/create-story');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return isGuest
        ? const Scaffold(
            body: Center(
              heightFactor: 10,
              child: Text('Please login to view stories'),
            ),
          )
        : Container(
            color: currentTheme.backgroundColor,
            height: MediaQuery.of(context).size.height / 4.5,
            child: Row(
              children: [
                GestureDetector(
                  onTap: navigateToCreateStory,
                  child: AspectRatio(
                    aspectRatio: 1.5 / 2,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(user.profilePic),
                            fit: BoxFit.cover,
                          ),
                          color: Colors.cyan),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.plus_circle_fill,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Create a story',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ref.watch(userStoryProvider).when(
                      data: (stories) {
                        return Expanded(
                          child: GridView.builder(
                            scrollDirection: Axis.horizontal,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                            ),
                            itemCount: stories.length,
                            itemBuilder: (context, index) {
                              final story = stories[index];
                              return GestureDetector(
                                onTap: () {
                                  Routemaster.of(context)
                                      .push('/story-view/${story.userUid}');
                                },
                                child: AspectRatio(
                                  aspectRatio: 1.5 / 2,
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image: NetworkImage(story.linkImage.last),
                                          fit: BoxFit.cover,
                                        ),
                                        color: Colors.cyan),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage: NetworkImage(
                                                          story.userProfilePic),
                                                    ),
                                                    // Text(
                                                    //   story.linkImage.length > 1
                                                    //       ? '+${story.linkImage.length}'
                                                    //       : '1 image',
                                                    //   textAlign: TextAlign.center,
                                                    //   style: GoogleFonts.poppins(
                                                    //     color: Colors.white,
                                                    //     fontSize: 16,
                                                    //     fontWeight: FontWeight.bold,
                                                    //   ),
                                                    // ),
                                                    Text(
                                                      (story.userUid == user.uid)
                                                          ? 'Your story'
                                                          : story.username,
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error: $error'),
                    ),
              ],
            ),
          );
  }
}
