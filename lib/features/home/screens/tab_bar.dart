import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/constants.dart';
import '../../../theme/palette.dart';
import '../../auth/controller/auth_controller.dart';
import '../../chat/controller/chat_controller.dart';
import '../../notification/controller/notification_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;
  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    ref.read(notificationController.notifier).requestPermission();
    ref.read(notificationController.notifier).getToken().then((value) {
      ref.read(notificationController.notifier).updateToken(value);
    });
    ref.read(notificationController.notifier).onMessage(context);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider.notifier).setUserState(true);
        break;
      case AppLifecycleState.inactive:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;
      case AppLifecycleState.detached:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;
      case AppLifecycleState.paused:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;
      case AppLifecycleState.hidden:
        ref.read(authControllerProvider.notifier).setUserState(false);
        break;
    }
  }


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
          ? CupertinoTabBar(
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
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ondemand_video_rounded),
            label: 'Video',
          ),
        ],
        onTap: onPageChange,
      )
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
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.ondemand_video_rounded),
                  label: 'Video',
                ),
                 BottomNavigationBarItem(
                  icon: ref.watch(getUnreadMessagesCount).when(
                    data: (count) {
                      return count == 0
                          ? const Icon(CupertinoIcons.bubble_left_bubble_right)
                          : Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(CupertinoIcons.bubble_left_bubble_right),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Icon(CupertinoIcons.bell),
                    error: (error, stackTrace) => const Icon(CupertinoIcons.bell),
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                    icon: ref.watch(unreadNotificationsCount).when(
                          data: (count) {
                            return count == 0
                                ? const Icon(CupertinoIcons.bell)
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(CupertinoIcons.bell),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 12,
                                            minHeight: 12,
                                          ),
                                          child: Text(
                                            count.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                          },
                          loading: () => const Icon(CupertinoIcons.bell),
                          error: (error, stackTrace) => const Icon(CupertinoIcons.bell),
                        ),
                    label: 'Notification'),
              ],
              onTap: onPageChange,
            ),
    );
  }
}
