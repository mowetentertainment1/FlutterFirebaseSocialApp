import 'package:flutter/foundation.dart';

class StoryModel {
  final String id;
  final String title;
  final List<String> linkImage;

  final List<String> upVotes;
  final List<String> downVotes;
  final String username;
  final String userUid;
  final String userProfilePic;

  final DateTime createdAt;
  StoryModel({
    required this.id,
    required this.title,
    required this.linkImage,
    required this.upVotes,
    required this.downVotes,
    required this.username,
    required this.userUid,
    required this.userProfilePic,
    required this.createdAt,
  });

  StoryModel copyWith({
    String? id,
    String? title,
    List<String>? linkImage,
    List<String>? upVotes,
    List<String>? downVotes,
    String? username,
    String? userUid,
    String? userProfilePic,
    DateTime? createdAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      linkImage: linkImage ?? this.linkImage,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      username: username ?? this.username,
      userUid: username ?? this.userUid,
      userProfilePic: username ?? this.userProfilePic,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'linkImage': linkImage,
      'upVotes': upVotes,
      'downVotes': downVotes,
      'username': username,
      'userUid': userUid,
      'userProfilePic': userProfilePic,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      linkImage: List<String>.from(map['linkImage']),
      upVotes: List<String>.from(map['upVotes']),
      downVotes: List<String>.from(map['downVotes']),
      username: map['username'] ?? '',
      userUid: map['userUid'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, linkImage: $linkImage, upVotes: $upVotes, downVotes: $downVotes, username: $username, userUid: $userUid, userProfilePic: $userProfilePic, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryModel &&
        other.id == id &&
        other.title == title &&
        listEquals(other.linkImage, linkImage) &&
        listEquals(other.upVotes, upVotes) &&
        listEquals(other.downVotes, downVotes) &&
        other.username == username &&
        other.userUid == userUid &&
        other.userProfilePic == userProfilePic &&
    other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    linkImage.hashCode ^
    upVotes.hashCode ^
    downVotes.hashCode ^
    username.hashCode ^
    userUid.hashCode ^
    userProfilePic.hashCode ^
    createdAt.hashCode;
  }
}
