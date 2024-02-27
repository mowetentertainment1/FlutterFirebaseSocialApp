import 'package:flutter/material.dart';

import '../../../core/enums/message_enum.dart';
import '../display_message_type.dart';

class OtherCommunityMessageCard extends StatelessWidget {
  const OtherCommunityMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.senderName,
    required this.senderUid,
    required this.isMods,
    required this.senderProfilePic,
  });
  final String message;
  final String senderName;
  final String senderUid;
  final bool isMods;
  final String senderProfilePic;
  final String date;
  final MessageEnum type;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 5,
        ),
        CircleAvatar(
          backgroundImage: NetworkImage(senderProfilePic),
          radius: 15,
        ),
        const SizedBox(
          width: 5,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 45, minWidth: 120),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 30,
                        top: 5,
                        bottom: 20,
                      ),
                      child: DisplayMessageType(
                        message: message,
                        type: type,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 10,
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }
}
