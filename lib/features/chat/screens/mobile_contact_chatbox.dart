import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/model/user_model.dart';
import '../../../core/colors.dart';
import '../../auth/controller/auth_controller.dart';
import '../bottom_chat_field.dart';
import '../card/chats_list.dart';
import '../controller/chat_controller.dart';

class MobileContactChatScreen extends ConsumerWidget {
  final String uid;
  final String name;
  const MobileContactChatScreen({super.key, required this.uid, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<UserModel>(
          stream: ref.read(authControllerProvider.notifier).getUserData(uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (!snapshot.hasData) {
              return const Text('Loading...');
            }
            final user = snapshot.data!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Routemaster.of(context).push('/u/${user.name}/${user.uid}');
                      },
                      child: Text(
                        'u/${user.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      user.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: user.isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Mute'),
              ),
              const PopupMenuItem(
                child: Text('Block'),
              ),
              const PopupMenuItem(
                value: 'deleteChat',
                child: Text('Delete Chat', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              if (value == 'deleteChat') {
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
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                        TextButton(
                          child:
                              const Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context).pop();
                            ref
                                .read(chatControllerProvider.notifier)
                                .deleteChat(uid, context);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(receiverId: uid),
          ),
          BottomChatField(
            receiverUserId: uid,
          ),
        ],
      ),
    );
  }
}
