import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/constants.dart';
import '../../../theme/palette.dart';
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
    return Scaffold(
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
      );
  }
}
