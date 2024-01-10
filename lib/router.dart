import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'features/auth/screens/login_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage<void>(child: LoginScreen()),
  // '/home': (_) => MaterialPage<void>(child: HomeScreen()),
  // '/profile': (_) => MaterialPage<void>(child: ProfileScreen()),
  // '/settings': (_) => MaterialPage<void>(child: SettingsScreen()),
});