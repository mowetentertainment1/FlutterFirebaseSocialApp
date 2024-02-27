import '../core/enums/message_enum.dart';

class CommunityMessageModel {
  final String senderId;
  final String receiverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final String senderProfilePic;
  final String senderUsername;
  CommunityMessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.senderProfilePic,
    required this.senderUsername,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'senderProfilePic': senderProfilePic,
      'senderUsername': senderUsername,
    };
  }

  factory CommunityMessageModel.fromMap(Map<String, dynamic> map) {
    return CommunityMessageModel(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      type: (map['type'] as String).toEnum(),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      messageId: map['messageId'] ?? '',
      senderProfilePic: map['senderProfilePic'] ?? '',
      senderUsername: map['senderUsername'] ?? '',
    );
  }
}
