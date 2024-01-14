import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/constants/constants.dart';
import 'package:untitled/model/community_model.dart';

import '../../../core/utils.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/community_repo.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  return ref.watch(communityControllerProvider.notifier).getCommunities();
});
final communityNameProvider =
    StreamProvider.family((ref, String communityName) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityName(communityName);
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  return CommunityController(
      communityRepo: ref.watch(communityRepoProvider), ref: ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepo _communityRepo;
  final Ref _ref;

  CommunityController({
    required CommunityRepo communityRepo,
    required Ref ref,
  })  : _communityRepo = communityRepo,
        _ref = ref,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final userUid = _ref.read(userProvider)?.uid ?? "";
    Community community = Community(
        id: name,
        name: name,
        banner: Constants.bannerDefault,
        avatar: Constants.avatarDefault,
        members: [userUid],
        mods: [userUid]);
    final res = await _communityRepo.createCommunity(community);
    res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => {
              showSnackBar(context, "Community created."),
              Routemaster.of(context).pop()
            });
    state = false;
  }

  Stream<List<Community>> getCommunities() {
    final userUid = _ref.read(userProvider)?.uid ?? "";
    return _communityRepo.getCommunities(userUid);
  }

  Stream<Community> getCommunityName(String communityName) {
    return _communityRepo.getCommunityName(communityName);
  }
}
