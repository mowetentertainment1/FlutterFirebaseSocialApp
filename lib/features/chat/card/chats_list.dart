import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } else {
          ref.read(chatControllerProvider.notifier).chatStream(widget.receiverId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref.read(chatControllerProvider.notifier).chatStream(widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        // });

        return ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data?.length ?? 0,
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
