import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/features/home/delegates/search_community_delegates.dart';
import 'package:untitled/features/home/drawers/community_list_drawer.dart';
import 'package:untitled/features/home/drawers/profile_drawner.dart';

import '../../../theme/pallete.dart';
import '../../auth/controller/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;
void onPageChange(int index){
  setState(() {
    _page = index;
  });
}
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final currenrTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileDrawer(),
      bottomNavigationBar: CupertinoTabBar(
        activeColor: currenrTheme.iconTheme.color,
        backgroundColor: currenrTheme.backgroundColor,
        border: const Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home'
          ),
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
        onTap: onPageChange ,
      ),
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
