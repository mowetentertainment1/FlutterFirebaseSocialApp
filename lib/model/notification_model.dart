import '../core/enums/notification_enums.dart';

class NotificationModel {
  final String profilePic;
  final String name;
  final String text;
  final String uid;
  final String id;
  final bool isRead;
  final NotificationEnum type;
  final DateTime createdAt;

//<editor-fold desc="Data Methods">
  const NotificationModel({
    required this.profilePic,
    required this.name,
    required this.text,
    required this.uid,
    required this.id,
    required this.isRead,
    required this.type,
    required this.createdAt,
  });

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     (other is NotificationModel &&
  //         runtimeType == other.runtimeType &&
  //         profilePic == other.profilePic &&
  //         name == other.name &&
  //         text == other.text &&
  //         uid == other.uid &&
  //         id == other.id &&
  //         isRead == other.isRead &&
  //         type == other.type &&
  //         createdAt == other.createdAt);
  //
  // @override
  // int get hashCode =>
  //     profilePic.hashCode ^
  //     name.hashCode ^
  //     text.hashCode ^
  //     uid.hashCode ^
  //     id.hashCode ^
  //     isRead.hashCode ^
  //     type.hashCode ^
  //     createdAt.hashCode;

  @override
  String toString() {
    return 'NotificationModel{ profilePic: $profilePic, name: $name, text: $text, uid: $uid, id: $id, isRead: $isRead, type: $type, createdAt: $createdAt,}';
  }

  NotificationModel copyWith({
    String? profilePic,
    String? name,
    String? text,
    String? uid,
    String? id,
    bool? isRead,
    NotificationEnum? type,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      profilePic: profilePic ?? this.profilePic,
      name: name ?? this.name,
      text: text ?? this.text,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profilePic': profilePic,
      'name': name,
      'text': text,
      'uid': uid,
      'id': id,
      'isRead': isRead,
      'type': type.type,
      'createdAt': createdAt,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      profilePic: map['profilePic'] as String,
      name: map['name'] as String,
      text: map['text'] as String,
      uid: map['uid'] as String,
      id: map['id'] as String,
      isRead: map['isRead'] as bool,
      type: (map['type'] as String).toEnum(),
      createdAt: map['createdAt'] as DateTime,
    );
  }
}
