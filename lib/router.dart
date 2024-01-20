import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/community/screens/add_mods_sreen.dart';
import 'package:untitled/features/community/screens/community_screen.dart';
import 'package:untitled/features/community/screens/create_community_screen.dart';
import 'package:untitled/features/community/screens/edit_community_screen.dart';
import 'package:untitled/features/community/screens/mod_tool_screen.dart';
import 'package:untitled/features/home/screens/home_screen.dart';
import 'package:untitled/features/home/user_profile/screens/edit_profile_screen.dart';
import 'package:untitled/features/home/user_profile/screens/user_profile_screen.dart';

import 'features/auth/screens/login_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) =>
      const MaterialPage(child: CreateCommunityScreen()),
  '/r/:communityName': (route) => MaterialPage(
      child: CommunityScreen(
          communityName: route.pathParameters['communityName']!)),
  '/mod-tools/:communityName': (routeData) => MaterialPage(
      child: ModToolScreen(
          communityName: routeData.pathParameters['communityName']!)),
  '/edit-community/:communityName': (routeData) => MaterialPage(
      child: EditCommunityScreen(
          communityName: routeData.pathParameters['communityName']!)),
  '/add_mods/:communityName': (routeData) => MaterialPage(
      child: AddModsScreen(
          communityName: routeData.pathParameters['communityName']!)),
  '/u/:uid': (routeData) => MaterialPage(
      child: UserProfileScreen(uid: routeData.pathParameters['uid']!)),
  '/edit-profile/:uid': (routeData) => MaterialPage(
      child: EditProfileScreen(uid: routeData.pathParameters['uid']!)),
});
