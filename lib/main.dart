import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/auth/screens/login_screen.dart';
import 'package:untitled/router.dart';
import 'package:untitled/theme/pallete.dart';

import 'firebase_options.dart';

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SocialApp Demo',
      theme: Pallete.darkModeAppTheme,
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) => loggedOutRoute),
      routeInformationParser: const RoutemasterParser(),);
  }
}
