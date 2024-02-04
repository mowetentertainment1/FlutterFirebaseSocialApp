import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/features/home/delegates/search_community_delegates.dart';
import 'package:untitled/features/home/drawers/community_list_drawer.dart';
import 'package:untitled/features/home/drawers/profile_drawner.dart';

import '../../../core/constants/constants.dart';
import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;

  void onPageChange(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    final isGuest = !user!.isAuthenticated;
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) async {
        if (!didPop) {
          final shouldPop = await showCupertinoDialog<bool>(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text('Exit App'),
                content: const Text('Are you sure you want to exit the app?'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
          if (shouldPop != null) {
            await SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        drawer: isGuest ? null : const CommunityListDrawer(),
        endDrawer: const ProfileDrawer(),
        body: Constants.tabWidgets[_page],
        bottomNavigationBar: isGuest
            ? null
            : CupertinoTabBar(
                height: 60,
                currentIndex: _page,
                activeColor: currentTheme.iconTheme.color,
                backgroundColor: currentTheme.colorScheme.background,
                border: const Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.home), label: 'Home'),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.add),
                    label: 'Create',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.chat_bubble),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.bell),
                    label: 'Notification',
                  ),
                ],
                onTap: onPageChange,
              ),
      ),
    );
  }
}
