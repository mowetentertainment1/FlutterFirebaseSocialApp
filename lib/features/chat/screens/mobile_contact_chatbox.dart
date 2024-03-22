import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/model/user_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../bottom_chat_field.dart';
import '../card/chats_list.dart';
import '../controller/chat_controller.dart';

class MobileContactChatScreen extends ConsumerStatefulWidget {
  final String uid;
  final String name;
  final String token;
  final bool blocked;
  final bool muted;
  const MobileContactChatScreen({Key? key, required this.uid, required this.name, required this.token, required this.blocked, required this.muted}) : super(key: key);

  @override
  _MobileContactChatScreenState createState() => _MobileContactChatScreenState();
}

class _MobileContactChatScreenState extends ConsumerState<MobileContactChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Routemaster.of(context).pop();
          },
        ),
        title: StreamBuilder<UserModel>(
          stream: ref.read(authControllerProvider.notifier).getUserData(widget.uid),
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
              PopupMenuItem(
                value: widget.muted ? 'unMute' : 'mute',
                child: Text(widget.muted ? 'Unmute' : 'Mute'),
              ),
              PopupMenuItem(
                value: widget.blocked ? 'unBlock' : 'block',
                child: Text(widget.blocked ? 'Unblock' : 'Block'),
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
                                .deleteChat(widget.uid, context);
                          },
                        ),
                      ],
                    );
                  },
                );
              }
              if (value == 'block') {
                ref
                    .read(chatControllerProvider.notifier)
                    .blockUser(widget.uid);
              }
              if (value == 'mute') {
                ref
                    .read(chatControllerProvider.notifier)
                    .muteUser(widget.uid);
              }
              if (value == 'unBlock') {
                ref
                    .read(chatControllerProvider.notifier)
                    .unBlockUser(widget.uid);
              }
              if (value == 'unMute') {
                ref
                    .read(chatControllerProvider.notifier)
                    .unMuteUser(widget.uid);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(receiverId: widget.uid),
          ),
          BottomChatField(
            receiverUserId: widget.uid,
            receiverUserToken: widget.token,
            blocked: widget.blocked,
          ),
        ],
      ),
    );
  }
}
