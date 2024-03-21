import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/community/screens/add_mods_sreen.dart';
import 'package:untitled/features/community/screens/community_screen.dart';
import 'package:untitled/features/community/screens/create_community_screen.dart';
import 'package:untitled/features/community/screens/edit_community_screen.dart';
import 'package:untitled/features/community/screens/mod_tool_screen.dart';
import 'package:untitled/features/home/screens/tab_bar.dart';
import 'package:untitled/features/home/user_profile/screens/edit_profile_screen.dart';
import 'package:untitled/features/home/user_profile/screens/user_profile_screen.dart';
import 'package:untitled/features/post/screens/create_post_screen.dart';
import 'package:untitled/features/post/screens/comment_screen.dart';
import 'package:untitled/features/post/screens/edit_post_screen.dart';
import 'package:untitled/features/short_video/screens/user_short_video.dart';
import 'package:untitled/features/story/screens/create_story_screen.dart';
import 'package:untitled/features/story/screens/story_view_screen.dart';
import 'core/common/photo_view.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/chat/screens/mobile_community_chatbox.dart';
import 'features/chat/screens/mobile_contact_chatbox.dart';
import 'features/short_video/screens/create_short_video_screen.dart';
import 'features/short_video/screens/short_video.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const MaterialPage(child: CreateCommunityScreen()),
  '/add-post': (_) => const MaterialPage(child: CreatePostScreen()),
  '/r/:communityName': (route) => MaterialPage(
      child: CommunityScreen(communityName: route.pathParameters['communityName']!)),
  '/r/:communityName/mod-tools': (routeData) => MaterialPage(
      child: ModToolScreen(communityName: routeData.pathParameters['communityName']!)),
  '/r/:communityName/mod-tools/edit-community': (routeData) => MaterialPage(
      child:
          EditCommunityScreen(communityName: routeData.pathParameters['communityName']!)),
  '/r/:communityName/mod-tools/add_mods': (routeData) => MaterialPage(
      child: AddModsScreen(communityName: routeData.pathParameters['communityName']!)),
  '/u/:name/:uid/:token': (routeData) => MaterialPage(
        child: UserProfileScreen(
          uid: routeData.pathParameters['uid']!,
          name: routeData.pathParameters['name']!,
          token: routeData.pathParameters['token']!,
        ),
      ),
  '/edit-profile/:uid': (routeData) =>
      MaterialPage(child: EditProfileScreen(uid: routeData.pathParameters['uid']!)),
  '/post/:postId/comments': (routeData) =>
      MaterialPage(child: CommentsScreen(postId: routeData.pathParameters['postId']!)),
  '/post/img': (routeData) {
    final List<String> imageUrls = routeData.queryParameters['imageUrls']!.split(',');
    final int initialIndex = int.parse(routeData.queryParameters['initialIndex']!);
    return MaterialPage(
      child: ImageZoomScreen(
        initialIndex: initialIndex,
        imageUrls: imageUrls,
      ),
    );
  },
  '/post/edit/:postId': (routeData) =>
      MaterialPage(child: EditPostScreen(postId: routeData.pathParameters['postId']!)),
  '/create-story': (_) => const MaterialPage(child: CreateStoryScreen()),
  '/story-view/:storyId': (routeData) => MaterialPage(
        child: StoryViewScreen(storyId: routeData.pathParameters['storyId']!),
      ),
  '/chat/:name/:uid/:token': (routeData) => MaterialPage(
        child: MobileContactChatScreen(
          uid: routeData.pathParameters['uid']!,
          name: routeData.pathParameters['name']!,
          token: routeData.pathParameters['token']!,
        ),
      ),
  '/community-chat/:name': (routeData) => MaterialPage(
        child: MobileCommunityChatScreen(
          name: routeData.pathParameters['name']!,
        ),
      ),
  '/create-short-video': (_) => const MaterialPage(child: CreateShortVideoScreen()),
  '/short-video/:uid/:index': (routeData) => MaterialPage(
        child: UserShortVideo(
          uid: routeData.pathParameters['uid']!,
          index: int.parse(routeData.pathParameters['index']!),
        ),
      ),
  '/short-video/:uid/': (routeData) => MaterialPage(
        child: ShortVideo(
          uid: routeData.pathParameters['uid']!,
        ),
      ),
});
