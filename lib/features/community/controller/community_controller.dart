import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/constants/constants.dart';
import 'package:untitled/model/community_model.dart';
import 'package:untitled/model/post_model.dart';

import '../../../core/enums/enums.dart';
import '../../../core/enums/notification_enums.dart';
import '../../../core/failure.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../model/notification_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../home/user_profile/controller/user_profile_controller.dart';
import '../../notification/repository/notification_repo.dart';
import '../repository/community_repo.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  return ref.watch(communityControllerProvider.notifier).getCommunities();
});
final communityNameProvider = StreamProvider.family((ref, String communityName) {
  return ref.watch(communityControllerProvider.notifier).getCommunityName(communityName);
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
      communityRepo: ref.watch(communityRepoProvider),
      ref: ref,
      notificationRepo: ref.watch(notificationRepoProvider),
      storageRepository: ref.watch(storageRepositoryProvider));
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref.watch(communityControllerProvider.notifier).getCommunityName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepo _communityRepo;
  final NotificationRepo _notificationRepo;

  final Ref _ref;

  final StorageRepository _storageRepository;

  CommunityController({
    required CommunityRepo communityRepo,
    required Ref ref,
    required StorageRepository storageRepository,
    required NotificationRepo notificationRepo,
  })  : _communityRepo = communityRepo,
        _ref = ref,
        _storageRepository = storageRepository,
        _notificationRepo = notificationRepo,
        super(false);

  void createCommunity(String name, String des, BuildContext context) async {
    state = true;
    final userUid = _ref.read(userProvider)?.uid ?? "";
    CommunityModel community = CommunityModel(
        id: name,
        name: name,
        description: des,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [userUid],
        mods: [userUid]);
    final res = await _communityRepo.createCommunity(community);
    res.fold(
        (l) => showSnackBar(context, l.message),
        (r) =>
            {showSnackBar(context, "Community created."), Routemaster.of(context).pop()});
    state = false;
  }

  void joinCommunity(CommunityModel community, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepo.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepo.joinCommunity(community.name, user.uid);
      res.fold(
          (l) => showSnackBar(context, l.message),
          (r) => {
                if (community.members.contains(user.uid))
                  {
                    showSnackBar(context, "Leaved community ${community.name}"),
                  }
                else
                  {
                    showSnackBar(context, " Joined community ${community.name}"),
                  }
              });
    }
  }

  Stream<List<CommunityModel>> getCommunities() {
    final userUid = _ref.read(userProvider)?.uid ?? "";
    return _communityRepo.getCommunities(userUid);
  }

  Stream<CommunityModel> getCommunityName(String communityName) {
    return _communityRepo.getCommunityName(communityName);
  }

  void editCommunity(
      {required File? avatarFile,
      required File? bannerFile,
      required BuildContext context,
      required CommunityModel community,
      required String description}) async {
    state = true;

    if (avatarFile != null) {
      final res = await _storageRepository.storeFile(
          file: avatarFile,
          id: community.name,
          path: "community/${community.name}/avatar");
      res.fold((l) => showSnackBar(context, l.message),
          (r) => community = community.copyWith(avatar: r));
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          file: bannerFile,
          id: community.name,
          path: "community/${community.name}/banner");
      res.fold((l) => showSnackBar(context, l.message),
          (r) => community = community.copyWith(banner: r));
    }
    if (description != community.description) {
      community = community.copyWith(description: description);
    }
    final res = await _communityRepo.editCommunity(community);
    state = false;
    res.fold(
        (l) => showSnackBar(context, l.message),
        (r) =>
            {showSnackBar(context, "Community edited."), Routemaster.of(context).pop()});
  }

  void deleteCommunity(String communityName, BuildContext context) async {
    state = true;
    final res = await _communityRepo.deleteCommunity(communityName);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    final delBanner = await _storageRepository.deleteFile(
        path: "community/$communityName/banner", id: communityName);
    final delAvatar = await _storageRepository.deleteFile(
        path: "community/$communityName/avatar", id: communityName);
    delBanner.fold((l) => showSnackBar(context, l.message), (r) => {});
    delAvatar.fold((l) => showSnackBar(context, l.message), (r) => {});
    state = false;
    res.fold(
        (l) => showSnackBar(context, l.message),
        (r) =>
            {showSnackBar(context, "Community deleted."), Routemaster.of(context).pop()});
  }

  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _communityRepo.searchCommunity(query);
  }

  void inviteUser(String communityName, List<String> uids, BuildContext context) async {
    state = true;
    final user = _ref.read(userProvider)!;
    for (var uid in uids) {
      final NotificationModel notification = NotificationModel(
        id: communityName,
        type: NotificationEnum.invite,
        name: user.name,
        createdAt: DateTime.now(),
        uid: uid,
        profilePic: user.profilePic,
        text: '${user.name} invited you to join $communityName.',
        isRead: false,
      );
      final res = await _notificationRepo.sendNotification(
        notification: notification,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          state = false;
          showSnackBar(context, "Invitation sent.");
          Routemaster.of(context).pop();
        },
      );
    }
  }

  void addMods(String communityName, List<String> uids, BuildContext context) async {
    state = true;
    final res = await _communityRepo.addMod(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      final user = _ref.read(userProvider)!;

      for (var uid in uids) {
        final NotificationModel notification = NotificationModel(
          id: communityName,
          type: NotificationEnum.invite,
          name: user.name,
          createdAt: DateTime.now(),
          uid: uid,
          profilePic: user.profilePic,
          text: '${user.name} added you as mod to $communityName.',
          isRead: false,
        );
        _notificationRepo.sendNotification(
          notification: notification,
        );
      }
      showSnackBar(context, "Mod added.");
      Routemaster.of(context).pop();
    });
    state = false;
  }

  Stream<List<PostModel>> getCommunityPosts(String communityName) {
    return _communityRepo.getCommunityPosts(communityName);
  }
}
