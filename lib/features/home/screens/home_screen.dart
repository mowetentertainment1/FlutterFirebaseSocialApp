import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/features/home/delegates/search_community_delegates.dart';
import 'package:untitled/features/home/drawers/community_list_drawer.dart';
import 'package:untitled/features/home/drawers/profile_drawner.dart';

import '../../auth/controller/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Scaffold(
      drawer: const CommunityListDrawer(),
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
              showSearch(
                  context: context, delegate: SearchCommunityScreen(ref: ref));
            },
          ),
          Builder(builder: (context) {
            return IconButton(
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user!.profilePic),
                ),
              ),
              onPressed: () => displayEndDrawer(context),
            );
          })
        ],
      ),
    );
  }
}
