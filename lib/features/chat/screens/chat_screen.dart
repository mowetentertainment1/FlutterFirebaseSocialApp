import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/controller/auth_controller.dart';
import '../../home/delegates/search_community_delegates.dart';
import 'contacts_list.dart';
import '../../../core/colors.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: const ContactsList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
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
