import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/features/chat/card/sender_message_card.dart';
import '../../../model/message.dart';
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
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref.read(chatControllerProvider).chatStream(widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (!snapshot.hasData) {
          return const Loader();
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }
        SchedulerBinding.instance.addTimingsCallback((_) {
          scrollController
              .jumpTo(scrollController.position.maxScrollExtent);
        });
        return ListView.builder(
          controller: scrollController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            if (messageData.senderId == FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: formatDate(
                  messageData.timeSent,
                  [HH, ':', nn],
                ),
              );
            }
            return SenderMessageCard(
              message: messageData.text,
              date: formatDate(
                messageData.timeSent,
                [HH, ':', nn],
              ),
            );
          },
        );
      },
    );
  }
}
