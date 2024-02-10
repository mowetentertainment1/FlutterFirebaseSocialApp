import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import '../../../core/colors.dart';
import '../../../core/common/loader.dart';
import '../../../model/chat_contact.dart';
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

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatContactData = snapshot.data![index];

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Routemaster.of(context).push('/chat/${chatContactData.name}/${chatContactData.contactId}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text(
                                  'u/${chatContactData.name}',
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
