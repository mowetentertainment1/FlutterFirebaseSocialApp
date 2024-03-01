import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/loader.dart';
import '../../../core/enums/notification_enums.dart';
import '../../../theme/palette.dart';
import '../../auth/controller/auth_controller.dart';
import '../../home/delegates/search_delegates.dart';
import '../../home/drawers/community_list_drawer.dart';
import '../../home/drawers/profile_drawer.dart';
import '../../post/controller/post_controller.dart';
import '../controller/notification_controller.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    final user = ref.watch(userProvider)!;
    return isLoading
        ? const Loader()
        : Scaffold(
            drawer: const CommunityListDrawer(),
            endDrawer: const ProfileDrawer(),
            appBar: AppBar(
              leading: Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => displayDrawer(context),
                );
              }),
              title: Text('Notifications', style: GoogleFonts.poppins()),
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
                        backgroundImage: NetworkImage(user.profilePic),
                      ),
                    ),
                    onPressed: () => displayEndDrawer(context),
                  );
                })
              ],
            ),
            body: ref.watch(notificationStream).when(
                  data: (notifications) {
                    return notifications.isEmpty
                        ? const Center(
                            child: Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              return notifications[index].type == NotificationEnum.upvote
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              notifications[index].profilePic),
                                        ),
                                        title: Text(
                                          notifications[index].text,
                                          style: GoogleFonts.poppins(),
                                        ),
                                        trailing: Text(
                                          formatDate(
                                            notifications[index].createdAt,
                                            [HH, ':', nn],
                                          ),
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                    )
                                  : notifications[index].type == NotificationEnum.comment
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.symmetric(vertical: 8.0),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  notifications[index].profilePic),
                                            ),
                                            title: Text(
                                              notifications[index].text,
                                              style: GoogleFonts.poppins(),
                                            ),
                                            trailing: Text(
                                              formatDate(
                                                notifications[index].createdAt,
                                                [HH, ':', nn],
                                              ),
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                        )
                                      : Padding(
                                          padding:
                                              const EdgeInsets.symmetric(vertical: 8.0),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  notifications[index].profilePic),
                                            ),
                                            title: Text(
                                              notifications[index].text,
                                              style: GoogleFonts.poppins(),
                                            ),
                                            trailing: Text(
                                              formatDate(
                                                notifications[index].createdAt,
                                                [HH, ':', nn],
                                              ),
                                              style: GoogleFonts.poppins(),
                                            ),
                                          ),
                                        );
                            },
                          );
                  },
                  loading: () => const Loader(),
                  error: (error, stack) {
                    return Center(
                      child: Text(
                        error.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    );
                  },
                ),
          );
  }
}
