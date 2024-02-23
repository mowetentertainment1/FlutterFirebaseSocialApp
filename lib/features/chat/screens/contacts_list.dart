import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import '../../../core/colors.dart';
import '../../../core/common/loader.dart';
import '../../../model/chat_contact.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/chat_controller.dart';

class ContactsList extends ConsumerWidget {
  const ContactsList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // StreamBuilder<List<Group>>(
            //     stream: ref.watch(chatControllerProvider).chatGroups(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Loader();
            //       }
            //
            //       return ListView.builder(
            //         shrinkWrap: true,
            //         itemCount: snapshot.data!.length,
            //         itemBuilder: (context, index) {
            //           var groupData = snapshot.data![index];
            //
            //           return Column(
            //             children: [
            //               InkWell(
            //                 onTap: () {
            //                   Navigator.pushNamed(
            //                     context,
            //                     MobileChatScreen.routeName,
            //                     arguments: {
            //                       'name': groupData.name,
            //                       'uid': groupData.groupId,
            //                       'isGroupChat': true,
            //                       'profilePic': groupData.groupPic,
            //                     },
            //                   );
            //                 },
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(bottom: 8.0),
            //                   child: ListTile(
            //                     title: Text(
            //                       groupData.name,
            //                       style: const TextStyle(
            //                         fontSize: 18,
            //                       ),
            //                     ),
            //                     subtitle: Padding(
            //                       padding: const EdgeInsets.only(top: 6.0),
            //                       child: Text(
            //                         groupData.lastMessage,
            //                         style: const TextStyle(fontSize: 15),
            //                       ),
            //                     ),
            //                     leading: CircleAvatar(
            //                       backgroundImage: NetworkImage(
            //                         groupData.groupPic,
            //                       ),
            //                       radius: 30,
            //                     ),
            //                     trailing: Text(
            //                       DateFormat.Hm().format(groupData.timeSent),
            //                       style: const TextStyle(
            //                         color: Colors.grey,
            //                         fontSize: 13,
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               const Divider(color: dividerColor, indent: 85),
            //             ],
            //           );
            //         },
            //       );
            //     }),
            StreamBuilder<List<ChatContact>>(
                stream: ref.watch(chatControllerProvider.notifier).chatContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  if (snapshot.data!.isEmpty) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text('No contacts',
                          style: TextStyle(color: Colors.grey, fontSize: 20)),
                    ));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatContactData = snapshot.data![index];

                      return Column(
                        children: [
                          InkWell(
                            onLongPress: () {
                              showDialog<void>(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Delete Chat'),
                                    content: const Text('Are you sure you want to delete this chat?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete',
                                            style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop();
                                          ref
                                              .read(chatControllerProvider.notifier)
                                              .deleteChat(chatContactData.contactId, context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onTap: () {
                              Routemaster.of(context).push(
                                  '/chat/${chatContactData.name}/${chatContactData.contactId}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  chatContactData.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    chatContactData.lastMessage,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    chatContactData.profilePic,
                                  ),
                                  radius: 30,
                                ),
                                trailing: Text(
                                  formatDate(chatContactData.timeSent, [HH, ':', nn]),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(color: dividerColor, indent: 85),
                        ],
                      );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
