import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/chat/controller/community_chat_controller.dart';
import 'package:untitled/model/community_chat_model.dart';
import '../../../core/colors.dart';
import '../../../core/common/loader.dart';
import '../controller/chat_controller.dart';

class CommunityChatList extends ConsumerWidget {
  const CommunityChatList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<CommunityChatModel>>(
                stream:
                    ref.watch(communityChatControllerProvider.notifier).chatContacts(),
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
                                    content: const Text(
                                        'Are you sure you want to delete this chat?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete',
                                            style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                          ref
                                              .read(chatControllerProvider.notifier)
                                              .deleteChat(
                                                  chatContactData.communityId, context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onTap: () {
                              Routemaster.of(context)
                                  .push('/chat/${chatContactData.communityId}');
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
                                    chatContactData.groupPic,
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
