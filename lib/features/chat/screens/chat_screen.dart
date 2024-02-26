import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/features/chat/screens/select_contact_screen.dart';

import '../../auth/controller/auth_controller.dart';
import '../../home/delegates/search_delegates.dart';
import '../../home/drawers/community_list_drawer.dart';
import '../../home/drawers/profile_drawer.dart';
import 'community_chat_list.dart';
import 'contacts_list.dart';
import '../../../core/colors.dart';
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
@override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => displayDrawer(context),
            );
          },
        ),
        title: Text('Chats', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            onPressed: () {
              showSearch(context: context, delegate: SearchCommunityScreen(ref: ref));
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePic),
                  ),
                ),
                onPressed: () => displayEndDrawer(context),
              );
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: tabColor,
          indicatorWeight: 4,
          labelColor: tabColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              text: 'CHATS',
            ),
            Tab(
              text: 'COMMUNITIES',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ContactsList(),
          CommunityChatList(),
        ],
      ),
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
    );
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }
}
