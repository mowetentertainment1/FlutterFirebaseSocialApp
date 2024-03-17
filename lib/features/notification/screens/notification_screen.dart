import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/loader.dart';
import '../../../theme/palette.dart';
import '../../auth/controller/auth_controller.dart';
import '../../post/controller/post_controller.dart';
import '../controller/notification_controller.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({Key? key});

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
    return isLoading
        ? const Loader()
        : Scaffold(
            appBar: AppBar(
              title: Text('Notifications', style: GoogleFonts.poppins()),
              actions: [
                PopupMenuButton(
                  icon: const Icon(Icons.more_horiz_outlined),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'readAll',
                      child: Text('Read all', style: TextStyle(color: Colors.green)),
                    ),
                    const PopupMenuItem(
                      value: 'deleteAll',
                      child: Text('Delete all', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'readAll') {
                      ref.read(notificationController.notifier).readAllNotifications();
                    } else {
                      ref.read(notificationController.notifier).deleteAllNotifications();
                    }
                  },
                )
              ],
            ),
            body: ref.watch(notificationStream).when(
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return const Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Container(
                          color: notification.isRead
                              ? null
                              : currentTheme.colorScheme.background,
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(notificationController.notifier)
                                  .markAsRead(notification.id);
                              Routemaster.of(context)
                                  .push('/post/${notification.id}/comments');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(notification.profilePic),
                                ),
                                title: Text(
                                  notification.text,
                                  style: GoogleFonts.poppins(
                                      color: notification.isRead
                                          ? currentTheme.colorScheme.outline
                                          : currentTheme.colorScheme.inverseSurface),
                                ),
                                trailing: Text(
                                  formatDate(
                                    notification.createdAt,
                                    [HH, ':', nn],
                                  ),
                                  style: GoogleFonts.poppins(
                                      color:
                                          notification.isRead ? null : Colors.blueAccent),
                                ),
                              ),
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
