import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/features/chat/screens/select_contact_screen.dart';

import '../../auth/controller/auth_controller.dart';
import '../../home/delegates/search_delegates.dart';
import '../../home/drawers/community_list_drawer.dart';
import '../../home/drawers/profile_drawer.dart';
import 'contacts_list.dart';
import '../../../core/colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;
  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
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
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const CommunityListDrawer(),
        endDrawer: const ProfileDrawer(),
        appBar: AppBar(
          leading: Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => displayDrawer(context),
            );
          }),
          title: Text('Chats', style: GoogleFonts.poppins()),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.search),
              onPressed: () {
                showSearch(context: context, delegate: SearchCommunityScreen(ref: ref));
              },
            ),
            Builder(builder: (context) {
              return IconButton(
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePic),
                  ),
                ),
                onPressed: () => displayEndDrawer(context),
              );
            })
          ],
          bottom: const TabBar(
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'COMMUNITIES',
              ),
            ],
          ),
        ),
        body: const ContactsList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showSearch(context: context, delegate: SelectContactScreen(ref: ref));
          },
          backgroundColor: tabColor,
          child: const Icon(
            Icons.comment,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
