import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/community/screens/community_screen.dart';
import 'package:untitled/features/community/screens/create_community_screen.dart';
import 'package:untitled/features/home/screens/home_screen.dart';

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
});
