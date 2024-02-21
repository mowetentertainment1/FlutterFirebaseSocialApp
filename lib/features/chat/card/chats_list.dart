import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/features/chat/card/sender_message_card.dart';
import '../controller/chat_controller.dart';
import 'my_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String receiverId;
  const ChatList({super.key, required this.receiverId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController scrollController = ScrollController();
  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(chatControllerProvider);
    return isLoading
        ? const Loader()
        : ref.watch(chatStream(widget.receiverId)).when(
              data: (chatList) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final message = chatList[index];
                    final isMyMessage =
                        message.senderId == FirebaseAuth.instance.currentUser!.uid;
                    return isMyMessage
                        ? MyMessageCard(
                            message: message.text,
                            date: formatDate(message.timeSent, [HH, ':', nn]),
                            type: message.type,
                          )
                        : SenderMessageCard(
                            message: message.text,
                            date: formatDate(message.timeSent, [HH, ':', nn]),
                      type: message.type,
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
