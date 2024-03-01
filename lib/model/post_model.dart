import 'package:flutter/foundation.dart';

class PostModel {
  final String id;
  final String title;
  final List<String> linkImage;
  final String linkVideo;
  final String communityName;
  final String communityProfilePic;

  final List<String> upvotes;
  final List<String> downvotes;
  final int commentCount;
  final String username;
  final String userUid;
  final String userProfilePic;

  final String type;
  final DateTime createdAt;
  final List<String> awards;
  PostModel({
    required this.id,
    required this.title,
    required this.linkImage,
    required this.linkVideo,
    required this.communityName,
    required this.communityProfilePic,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.username,
    required this.userUid,
    required this.userProfilePic,
    required this.type,
    required this.createdAt,
    required this.awards,
  });

  PostModel copyWith({
    String? id,
    String? title,
    List<String>? linkImage,
    String? linkVideo,
    String? communityName,
    String? communityProfilePic,
    List<String>? upvotes,
    List<String>? downvotes,
    int? commentCount,
    String? username,
    String? userUid,
    String? userProfilePic,
    String? type,
    DateTime? createdAt,
    List<String>? awards,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      linkImage: linkImage ?? this.linkImage,
      linkVideo: linkVideo ?? this.linkVideo,
      communityName: communityName ?? this.communityName,
      communityProfilePic: communityProfilePic ?? this.communityProfilePic,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      username: username ?? this.username,
      userUid: username ?? this.userUid,
      userProfilePic: username ?? this.userProfilePic,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'linkImage': linkImage,
      'linkVideo': linkVideo,
      'communityName': communityName,
      'communityProfilePic': communityProfilePic,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'username': username,
      'userUid': userUid,
      'userProfilePic': userProfilePic,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'awards': awards,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      linkImage: List<String>.from(map['linkImage']),
      linkVideo: map['linkVideo'],
      communityName: map['communityName'] ?? '',
      communityProfilePic: map['communityProfilePic'] ?? '',
      upvotes: List<String>.from(map['upvotes']),
      downvotes: List<String>.from(map['downvotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      username: map['username'] ?? '',
      userUid: map['userUid'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      type: map['type'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      awards: List<String>.from(map['awards']),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, linkImage: $linkImage, linkVideo: $linkVideo, communityName: $communityName, communityProfilePic: $communityProfilePic, upvotes: $upvotes, downvotes: $downvotes, commentCount: $commentCount, username: $username, userUid: $userUid, userProfilePic: $userProfilePic, type: $type, createdAt: $createdAt, awards: $awards)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostModel &&
        other.id == id &&
        other.title == title &&
        listEquals(other.linkImage, linkImage) &&
        other.linkVideo == linkVideo &&
        other.communityName == communityName &&
        other.communityProfilePic == communityProfilePic &&
        listEquals(other.upvotes, upvotes) &&
        listEquals(other.downvotes, downvotes) &&
        other.commentCount == commentCount &&
        other.username == username &&
        other.userUid == userUid &&
        other.userProfilePic == userProfilePic &&
        other.type == type &&
        other.createdAt == createdAt &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    linkImage.hashCode ^
    linkVideo.hashCode ^
    communityName.hashCode ^
    communityProfilePic.hashCode ^
    upvotes.hashCode ^
    downvotes.hashCode ^
    commentCount.hashCode ^
    username.hashCode ^
    userUid.hashCode ^
    userProfilePic.hashCode ^
    type.hashCode ^
    createdAt.hashCode ^
    awards.hashCode;
  }
}
