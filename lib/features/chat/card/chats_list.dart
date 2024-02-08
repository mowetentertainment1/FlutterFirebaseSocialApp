import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/features/chat/card/sender_message_card.dart';

import '../../../core/info.dart';
import '../controller/chat_controller.dart';
import 'my_message_card.dart';

class ChatList extends ConsumerWidget {
  final String receiverId;
  const ChatList({super.key, required this.receiverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: ref.read(chatControllerProvider.notifier).chatStream(receiverId),
        builder: (context, snapshot) {
          return ListView.builder(
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
        });
  }
}
