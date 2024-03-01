import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/loader.dart';
import 'package:untitled/core/enums/message_enums.dart';
import 'package:untitled/features/chat/display_message_type.dart';

import '../../../core/colors.dart';
import '../../community/controller/community_controller.dart';

class MyCommunityMessageCard extends ConsumerWidget {
  final String message;
  final String senderName;
  final String receiverId;
  final String senderUid;
  final String senderProfilePic;
  final String date;
  final MessageEnum type;

  const MyCommunityMessageCard(
      {super.key,
      required this.message,
      required this.date,
      required this.type,
      required this.senderName,
      required this.receiverId,
      required this.senderUid,
      required this.senderProfilePic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ref.watch(communityNameProvider(receiverId)).when(
                  data: (community) => community.mods.contains(senderUid)
                      ? const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.blue,
                            size: 15,
                          ),
                        )
                      : const SizedBox(),
                  loading: () => const Loader(),
                  error: (error, stack) => const SizedBox()),

              Text(
                senderName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(senderProfilePic),
                radius: 10,
              ),
              const SizedBox(
                width: 5,
              ),
            ],

          ),
          const SizedBox(
            height: 3,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45,
              minWidth: 120,
            ),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              color: messageColor,
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
                    bottom: 4,
                    right: 10,
                    child: Row(
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Icon(
                          Icons.done_all,
                          size: 20,
                          color: Colors.white60,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  }
}
