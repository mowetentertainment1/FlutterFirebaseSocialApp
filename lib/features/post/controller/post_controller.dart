import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../model/community_model.dart';
import '../../../model/post_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/post_repo.dart';
final postControllerProvider = StateNotifierProvider<PostController, bool>((ref) {
  final postRepo = ref.watch(postRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepo: postRepo,
    storageRepository: storageRepository,
    ref: ref,
  );
});

class PostController extends StateNotifier<bool> {
  final PostRepo _postRepo;

  final Ref _ref;

  final StorageRepository _storageRepository;

  PostController({
    required PostRepo postRepo,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepo = postRepo,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);
  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required List<File> file,
    // required Uint8List? webFile,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    for (var i = 0; i < file.length; i++) {

    final imageRes = await _storageRepository.storeMultipleFiles(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      files: file,
      // webFile: webFile,
    );
    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        linkImage: r,
      );

      final res = await _postRepo.addPost(post);
      // _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted successfully!');
        Routemaster.of(context).pop();
      });
    });
  }
}}