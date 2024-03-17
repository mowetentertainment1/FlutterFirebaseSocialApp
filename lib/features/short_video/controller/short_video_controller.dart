import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/model/notification_model.dart';
import 'package:uuid/uuid.dart';
import '../../../core/enums/notification_enums.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../model/comment_model.dart';
import '../../../model/short_video_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../notification/repository/notification_repo.dart';
import '../repository/short_video_repo.dart';
import 'package:video_compress_plus/video_compress_plus.dart';

final shortVideoControllerProvider =
    StateNotifierProvider<ShortVideoController, bool>((ref) {
  final shortVideoRepo = ref.watch(shortVideoRepoProvider);
  final notificationRepo = ref.watch(notificationRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return ShortVideoController(
    shortVideoRepo: shortVideoRepo,
    notificationRepo: notificationRepo,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getUserShortVideosProvider = StreamProvider<List<ShortVideoModel>>((ref) {
  final storyController = ref.watch(shortVideoControllerProvider.notifier);
  return storyController.getShortVideos();
});
final getUserShortVideosUidProvider = StreamProvider.family((ref, String uid) {
  return ref.read(shortVideoControllerProvider.notifier).getShortVideosByUid(uid);
});
final getUserShortVideoByIdProvider = StreamProvider.family((ref, String uid) {
  return ref.read(shortVideoControllerProvider.notifier).getShortVideoById(uid);
});
// final guestShortVideosProvider = StreamProvider((ref) {
//   return ref.read(postControllerProvider.notifier).getGuestShortVideos();
// });
// final getShortVideoByIdProvider = StreamProvider.family<ShortVideoModel, String>((ref, videoId) {
//   return ref.watch(postControllerProvider.notifier).getShortVideo(videoId);
// });
final getShortVideoCommentsProvider = StreamProvider.family((ref, String videoId) {
  final postController = ref.watch(shortVideoControllerProvider.notifier);
  return postController.fetchShortVideoComments(videoId);
});

class ShortVideoController extends StateNotifier<bool> {
  final ShortVideoRepo _shortVideoRepo;
  final NotificationRepo _notificationRepo;
  final Ref _ref;
  final StorageRepository _storageRepository;

  ShortVideoController({
    required ShortVideoRepo shortVideoRepo,
    required Ref ref,
    required StorageRepository storageRepository,
    required NotificationRepo notificationRepo,
  })  : _shortVideoRepo = shortVideoRepo,
        _notificationRepo = notificationRepo,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);
  _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }
  void uploadShortVideo({
    required BuildContext context,
    required String caption,
    required String songName,
    required File? file,
    required String videoPath,
  }) async {
    state = true;
    String videoId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final videoRes = await _storageRepository.storeVideo(
      path: 'shortVideos/videoRes/${user.name}/$videoId/',
      file: file!,
    );
    File thumbnail = await _getThumbnail(videoPath);
    final thumbnailRes = await _storageRepository.storeFile(
      path: 'shortVideos/thumbnailRes/${user.name}',
      id: videoId,
      file: thumbnail,
    );

    videoRes.fold((l) => showSnackBar(context, l.message), (r) async {
      thumbnailRes.fold((l) => showSnackBar(context, l.message), (thumbnailUrl) async {
        final ShortVideoModel video = ShortVideoModel(
          id: videoId,
          commentCount: 0,
          songName: songName,
          caption: caption,
          videoUrl: r,
          thumbnail: thumbnailUrl,
          createdAt: DateTime.now(),
          upVotes: [],
          downVotes: [],
          userName: user.name,
          userUid: user.uid,
          userProfilePic: user.profilePic,
        );

        final res = await _shortVideoRepo.uploadVideo(video);
        state = false;
        res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Successfully!');
          Routemaster.of(context).pop();
          for (var uid in user.followers) {
            final NotificationModel notification = NotificationModel(
              id: videoId,
              type: NotificationEnum.post,
              name: user.name,
              createdAt: DateTime.now(),
              uid: uid,
              profilePic: user.profilePic,
              text: '${user.name} posted a new short video',
              isRead: false,
            );
            if (user.uid != uid) {
              _notificationRepo.sendNotification(
                notification: notification,
              );
            }
          }
        });
      });
    });
  }


  void deleteShortVideo(ShortVideoModel videoModel, BuildContext context) async {
    state = true;
    List<String> urls = [videoModel.videoUrl, videoModel.thumbnail];
    final res = await _shortVideoRepo.deleteShortVideo(videoModel);
    final imageDelRes = await _storageRepository.deleteMultipleFiles(
      urls: urls,
    );
    state = false;
    imageDelRes.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'File Deleted');
    });
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Deleted successfully!');
    });
  }

  void upVoteShortVideo(ShortVideoModel video) async {
    final user = _ref.read(userProvider)!;
    final res = await _shortVideoRepo.upVoteShortVideo(video, user.uid);
    final NotificationModel notification = NotificationModel(
      id: video.id,
      type: NotificationEnum.video,
      name: video.userName,
      createdAt: DateTime.now(),
      uid: video.userUid,
      profilePic: video.userProfilePic,
      text: '${user.name} upvoted your video',
      isRead: false,
    );
    res.fold((l) => (l), (r) {
      if (video.userUid != user.uid) {
        _notificationRepo.sendNotification(
          notification: notification,
        );
      }
    });
  }

  void downVoteShortVideo(ShortVideoModel video) async {
    final user = _ref.read(userProvider)!;
    final res = await _shortVideoRepo.downVoteShortVideo(video, user.uid);
    final NotificationModel notification = NotificationModel(
      id: video.id,
      type: NotificationEnum.video,
      name: video.userName,
      createdAt: DateTime.now(),
      uid: video.userUid,
      profilePic: '',
      text: '${user.name} downvoted your video',
      isRead: false,
    );
    res.fold((l) => (l), (r) {
      if (video.userUid != user.uid) {
        _notificationRepo.sendNotification(
          notification: notification,
        );
      }
    });
  }

  Stream<List<ShortVideoModel>> getShortVideosByUid(String uid) {
    try {
      return _shortVideoRepo.getShortVideosByUid(uid);
    } catch (e) {
      return Stream.empty();
    }
  }
  Stream<ShortVideoModel> getShortVideoById(String uid) {
    try {
      return _shortVideoRepo.getShortVideoById(uid);
    } catch (e) {
      return Stream.empty();
    }
  }
  Stream<List<ShortVideoModel>> getShortVideos() {
    final user = _ref.read(userProvider)!;
    return _shortVideoRepo.getShortVideos(user.following);
  }
  // Stream<List<ShortVideoModel>> getGuestShortVideos() {
  //   return _shortVideoRepo.getGuestShortVideos();
  // }
  //
  // Stream<ShortVideoModel> getShortVideo(String videoId) {
  //   return _shortVideoRepo.getShortVideoById(videoId);
  // }
  //
  Stream<List<CommentModel>> fetchShortVideoComments(String videoId) {
    return _shortVideoRepo.getCommentsOfShortVideo(videoId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required ShortVideoModel post,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    CommentModel comment = CommentModel(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: user.name,
      profilePic: user.profilePic,
    );
    final res = await _shortVideoRepo.addComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      final NotificationModel notification = NotificationModel(
        id: post.id,
        type: NotificationEnum.video,
        name: user.name,
        createdAt: DateTime.now(),
        uid: post.userUid,
        profilePic: post.userProfilePic,
        text: '${user.name} commented on your video: $text',
        isRead: false,
      );
      if (post.userUid != user.uid) {
        _notificationRepo.sendNotification(
          notification: notification,
        );
      }
    });
  }
  void deleteComment(CommentModel comment, BuildContext context) async {
    final res = await _shortVideoRepo.deleteComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Comment Deleted');
    });
  }
  // void updateShortVideo({
  //   required BuildContext context,
  //   required ShortVideoModel postModel,
  //   required String title,
  //   required CommunityModel selectedCommunity,
  //
  // }) async {
  //   state = true;
  //   final ShortVideoModel post = postModel.copyWith(
  //     title: title,
  //     communityName: selectedCommunity.name,
  //     communityProfilePic: selectedCommunity.avatar,
  //     createdAt: DateTime.now(),
  //   );
  //
  //   final res = await _shortVideoRepo.updateShortVideo(post);
  //   state = false;
  //   res.fold((l) => showSnackBar(context, l.message), (r) {
  //     showSnackBar(context, 'Updated.');
  //   });
  // }
}
