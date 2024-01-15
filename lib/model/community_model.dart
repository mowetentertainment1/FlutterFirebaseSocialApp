import 'package:flutter/foundation.dart';

class Community {
  final String id;
  final String name;

  final String description;
  final String banner;
  final String avatar;
  final List<String> members;
  final List<String> mods;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.banner,
    required this.avatar,
    required this.members,
    required this.mods,
  });

  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? banner,
    String? avatar,
    List<String>? members,
    List<String>? mods,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      banner: banner ?? this.banner,
      avatar: avatar ?? this.avatar,
      members: members ?? this.members,
      mods: mods ?? this.mods,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'banner': banner,
      'avatar': avatar,
      'members': members,
      'mods': mods,
    };
  }

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      banner: map['banner'] ?? '',
      avatar: map['avatar'] ?? '',
      members: List<String>.from(map['members']),
      mods: List<String>.from(map['mods']),
    );
  }

  @override
  String toString() {
    return 'Community(id: $id, name: $name, description: $description, banner: $banner, avatar: $avatar, members: $members, mods: $mods)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Community &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.banner == banner &&
        other.avatar == avatar &&
        listEquals(other.members, members) &&
        listEquals(other.mods, mods);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        banner.hashCode ^
        avatar.hashCode ^
        members.hashCode ^
        mods.hashCode;
  }
}
