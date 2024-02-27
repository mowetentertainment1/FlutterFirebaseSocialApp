import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/features/chat/controller/community_chat_controller.dart';
import 'my_community_message_card.dart';
import 'other_community_message_card.dart';

class CommunityChatList extends ConsumerStatefulWidget {
  final String receiverId;
  const CommunityChatList({super.key, required this.receiverId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommunityChatListState();
}

class _CommunityChatListState extends ConsumerState<CommunityChatList> {
  final ScrollController scrollController = ScrollController();
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityChatControllerProvider);
    return isLoading
        ? const Loader()
        : ref.watch(communityChatStream(widget.receiverId)).when(
              data: (chatList) {
                if (chatList.isEmpty) {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  controller: scrollController,
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final message = chatList[index];
                    final isMyMessage =
                        message.senderId == FirebaseAuth.instance.currentUser!.uid;
                    return isMyMessage
                        ? MyCommunityMessageCard(
                            message: message.text,
                            receiverId: widget.receiverId,
                            date: formatDate(message.timeSent, [HH, ':', nn]),
                            type: message.type,
                            senderName: message.senderUsername,
                            senderUid: message.senderId,
                            senderProfilePic: message.senderProfilePic,
                          )
                        : OtherCommunityMessageCard(
                      message: message.text,
                      receiverId: widget.receiverId,
                      date: formatDate(message.timeSent, [HH, ':', nn]),
                      type: message.type,
                      senderName: message.senderUsername,
                      senderUid: message.senderId,
                      senderProfilePic: message.senderProfilePic,
                          );
                  },
                );
              },
              loading: () => const Loader(),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            );
  }
}
