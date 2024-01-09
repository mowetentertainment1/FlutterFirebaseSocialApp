// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

class UserModel {
  final String uid;
  final String name;
  final String profilePic;
  final String banner;
  final String isAuth; // if guest or not
  final int karma;
  final List<String> awards;

  UserModel({
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.banner,
    required this.isAuth,
    required this.karma,
    required this.awards,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? profilePic,
    String? banner,
    String? isAuth,
    int? karma,
    List<String>? awards,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      isAuth: isAuth ?? this.isAuth,
      karma: karma ?? this.karma,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'profilePic': profilePic,
      'banner': banner,
      'isAuth': isAuth,
      'karma': karma,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        uid: map['uid'] as String,
        name: map['name'] as String,
        profilePic: map['profilePic'] as String,
        banner: map['banner'] as String,
        isAuth: map['isAuth'] as String,
        karma: map['karma'] as int,
        awards: List<String>.from(
          (map['awards'] as List<String>),
        ));
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, profilePic: $profilePic, banner: $banner, isAuth: $isAuth, karma: $karma, awards: $awards)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.uid == uid &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.banner == banner &&
        other.isAuth == isAuth &&
        other.karma == karma &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        profilePic.hashCode ^
        banner.hashCode ^
        isAuth.hashCode ^
        karma.hashCode ^
        awards.hashCode;
  }
}
