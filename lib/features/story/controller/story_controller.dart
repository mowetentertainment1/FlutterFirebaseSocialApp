import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/core/utils.dart';
import 'package:untitled/features/auth/controller/auth_controller.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/storage_repository_provider.dart';
import '../../../model/story_model.dart';
import '../../notification/repository/notification_repo.dart';
import '../repository/story_repo.dart';

final storyControllerProvider = StateNotifierProvider<StoryController, bool>((ref) {
  final storyRepository = ref.read(storyRepoProvider);
  final notificationRepo = ref.watch(notificationRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return StoryController(
    storyRepo: storyRepository,
    notificationRepo: notificationRepo,
    storageRepository: storageRepository,
    ref: ref,
  );
});
final userStoryProvider = StreamProvider<List<StoryModel>>((ref) {
  final storyController = ref.watch(storyControllerProvider.notifier);
  return storyController.getStories();
});

class StoryController extends StateNotifier<bool> {
  final StoryRepo _storyRepo;
  final Ref _ref;
  final NotificationRepo _notificationRepo;
  final StorageRepository _storageRepository;

  StoryController({
    required NotificationRepo notificationRepo,
    required StorageRepository storageRepository,
    required StoryRepo storyRepo,
    required Ref ref,
  })  : _storyRepo = storyRepo,
        _notificationRepo = notificationRepo,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void saveStory({
    required BuildContext context,
    required String title,
    required List<File> files,
  }) async {
    state = true;
    String storyId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    List<String> urls = [];
    try {
      final imageRes = await _storageRepository.storeMultipleFiles(
        path: 'story/${user.name}/$storyId/',
        files: files,
      );
      imageRes.fold(
        (l) => throw l,
        (r) => urls = r,
      );
      final StoryModel story = StoryModel(
        id: user.uid,
        title: title,
        createdAt: DateTime.now(),
        linkImage: urls,
        upVotes: [],
        downVotes: [],
        username: user.name,
        userUid: user.uid,
        userProfilePic: user.profilePic,
      );
      final res = await _storyRepo.addOrUpdateStory(story);
      res.fold(
        (l) => throw l,
        (r) async {
         Routemaster.of(context).pop();
         showSnackBar(context, "Story created.");
          state = false;
        },
      );
    } catch (e) {
      state = false;
    }
  }

  Stream<List<StoryModel>> getStories() {
    final user = _ref.read(userProvider)!;
    return _storyRepo.getStories(user.following);
  }
}
