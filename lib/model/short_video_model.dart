class ShortVideoModel {
  final String id;
  final List<String> upVotes;
  final List<String> downVotes;
  final int commentCount;
  final String userName;
  final String userUid;
  final String userProfilePic;
  final String songName;
  final String caption;
  final String videoUrl;
  final String thumbnail;
  final DateTime createdAt;

//<editor-fold desc="Data Methods">
  const ShortVideoModel({
    required this.id,
    required this.upVotes,
    required this.downVotes,
    required this.commentCount,
    required this.userName,
    required this.userUid,
    required this.userProfilePic,
    required this.songName,
    required this.caption,
    required this.videoUrl,
    required this.thumbnail,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShortVideoModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          upVotes == other.upVotes &&
          downVotes == other.downVotes &&
          commentCount == other.commentCount &&
          userName == other.userName &&
          userUid == other.userUid &&
          userProfilePic == other.userProfilePic &&
          songName == other.songName &&
          caption == other.caption &&
          videoUrl == other.videoUrl &&
          thumbnail == other.thumbnail &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      upVotes.hashCode ^
      downVotes.hashCode ^
      commentCount.hashCode ^
      userName.hashCode ^
      userUid.hashCode ^
      userProfilePic.hashCode ^
      songName.hashCode ^
      caption.hashCode ^
      videoUrl.hashCode ^
      thumbnail.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'ShortVideoModel{ id: $id, upVotes: $upVotes, downVotes: $downVotes, commentCount: $commentCount, userName: $userName, userUid: $userUid, userProfilePic: $userProfilePic, songName: $songName, caption: $caption, videoUrl: $videoUrl, thumbnail: $thumbnail, createdAt: $createdAt,}';
  }

  ShortVideoModel copyWith({
    String? id,
    List<String>? upVotes,
    List<String>? downVotes,
    int? commentCount,
    String? userName,
    String? userUid,
    String? userProfilePic,
    String? songName,
    String? caption,
    String? videoUrl,
    String? thumbnail,
    DateTime? createdAt,
  }) {
    return ShortVideoModel(
      id: id ?? this.id,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      commentCount: commentCount ?? this.commentCount,
      userName: userName ?? this.userName,
      userUid: userUid ?? this.userUid,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      songName: songName ?? this.songName,
      caption: caption ?? this.caption,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'upVotes': upVotes,
      'downVotes': downVotes,
      'commentCount': commentCount,
      'userName': userName,
      'userUid': userUid,
      'userProfilePic': userProfilePic,
      'songName': songName,
      'caption': caption,
      'videoUrl': videoUrl,
      'thumbnail': thumbnail,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ShortVideoModel.fromMap(Map<String, dynamic> map) {
    return ShortVideoModel(
      id: map['id'] ?? '',
      upVotes: List<String>.from(map['upVotes']),
      downVotes: List<String>.from(map['downVotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      userName: map['userName']?? '',
      userUid: map['userUid'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      songName: map['songName'] ?? '',
      caption: map['caption'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      createdAt:DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

//</editor-fold>
}
