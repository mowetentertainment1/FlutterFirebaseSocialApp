import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/features/chat/card/community_message_list.dart';
import 'package:untitled/model/community_model.dart';
import '../../../core/colors.dart';
import '../../community/controller/community_controller.dart';
import '../card/chats_list.dart';
import '../controller/chat_controller.dart';
import 'community_bottom_chat_field.dart';

class MobileCommunityChatScreen extends ConsumerWidget {
  final String name;
  const MobileCommunityChatScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: StreamBuilder<CommunityModel>(
          stream: ref.read(communityControllerProvider.notifier).getCommunityName(name),
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
                  backgroundImage: NetworkImage(user.avatar),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Routemaster.of(context).push('/r/${user.name}');
                      },
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${user.members.length} members',
                      style: const TextStyle(
                        fontSize: 12,
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
                                .deleteChat(name, context);
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
            child: CommunityChatList(receiverId: name),
          ),
          CommunityBottomChatField(
            receiverUserId: name,
          ),
        ],
      ),
    );
  }
}
