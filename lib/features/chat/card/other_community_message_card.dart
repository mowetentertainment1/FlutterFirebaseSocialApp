import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/core/common/loader.dart';
import '../../../core/enums/message_enum.dart';
import '../display_message_type.dart';
import '../../community/controller/community_controller.dart';

class OtherCommunityMessageCard extends ConsumerWidget {
  final String message;
  final String senderName;
  final String senderUid;
  final String receiverId;
  final String senderProfilePic;
  final String date;
  final MessageEnum type;
  const OtherCommunityMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.senderName,
    required this.senderUid,
    required this.senderProfilePic,
    required this.receiverId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
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
            Row(
              children: [
                Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ref.watch(communityNameProvider(receiverId)).when(
                    data: (community) => community.mods.contains(senderUid)
                        ? const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.blue,
                              size: 15,
                            ),
                          )
                        : const SizedBox(),
                    loading: () => const Loader(),
                    error: (error, stack) => const SizedBox()),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 45, minWidth: 120),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.only(top: 5, bottom: 5).copyWith(right: 80),
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
