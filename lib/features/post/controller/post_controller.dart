import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:untitled/model/notification_model.dart';
import 'package:uuid/uuid.dart';

import '../../../core/enums/enums.dart';
import '../../../core/enums/notification_enums.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../model/comment_model.dart';
import '../../../model/community_model.dart';
import '../../../model/post_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../home/user_profile/controller/user_profile_controller.dart';
import '../../notification/repository/notification_repo.dart';
import '../repository/post_repo.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>((ref) {
  final postRepo = ref.watch(postRepoProvider);
  final notificationRepo = ref.watch(notificationRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepo: postRepo,
    notificationRepo: notificationRepo,
    storageRepository: storageRepository,
    ref: ref,
  );
});
final userPostsProvider =
    StreamProvider.family<List<PostModel>, List<CommunityModel>>((ref, communities) {
  return ref.read(postControllerProvider.notifier).getPosts(communities);
});
final guestPostsProvider = StreamProvider((ref) {
  return ref.read(postControllerProvider.notifier).getGuestPosts();
});
final getPostByIdProvider = StreamProvider.family<PostModel, String>((ref, postId) {
  return ref.watch(postControllerProvider.notifier).getPost(postId);
});
final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepo _postRepo;
  final NotificationRepo _notificationRepo;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepo postRepo,
    required Ref ref,
    required StorageRepository storageRepository,
    required NotificationRepo notificationRepo,
  })  : _postRepo = postRepo,
        _notificationRepo = notificationRepo,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void shareImagePost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required List<File> files,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    List<String> urls = [];

    try {
      final imageRes = await _storageRepository.storeMultipleFiles(
        path: 'posts/${selectedCommunity.name}/$postId/',
        files: files,
      );

      imageRes.fold(
        (l) => showSnackBar(context, l.message),
        (r) => urls = r,
      );
      final PostModel post = PostModel(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        type: 'image',
        createdAt: DateTime.now(),
        linkVideo: '',
        linkImage: urls,
        awards: [],
        userUid: user.uid,
        userProfilePic: user.profilePic,
      );

      final res = await _postRepo.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {

          Routemaster.of(context).push('/');
          showSnackBar(context, 'Posted.');
          for (var uid in selectedCommunity.members) {
            final NotificationModel notification = NotificationModel(
              id: uid,
              type: NotificationEnum.post,
              name: selectedCommunity.name,
              createdAt: DateTime.now(),
              uid: postId,
              profilePic: selectedCommunity.avatar,
              text: '${user.name} posted in ${selectedCommunity.name}',
              isRead: false,
            );
            _notificationRepo.sendNotification(
              notification: notification,
            );
          }
        },
      );
    } catch (e) {
      state = false;
      showSnackBar(context, 'Error sharing image post: $e');
    }
  }

  void shareTextPost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required String linkVideo,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final PostModel post = PostModel(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      type: 'text',
      createdAt: DateTime.now(),
      linkVideo: linkVideo,
      linkImage: [],
      awards: [],
      userUid: user.uid,
      userProfilePic: user.profilePic,
    );

    final res = await _postRepo.addPost(post);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted.');
      for (var uid in selectedCommunity.members) {
        final NotificationModel notification = NotificationModel(
          id: uid,
          type: NotificationEnum.post,
          name: selectedCommunity.name,
          createdAt: DateTime.now(),
          uid: postId,
          profilePic: selectedCommunity.avatar,
          text: '${user.name} posted in ${selectedCommunity.name}',
          isRead: false,
        );
        _notificationRepo.sendNotification(
          notification: notification,
        );
      }
    });
  }

  void shareVideoPost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required File? file,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeVideo(
      path: 'posts/${selectedCommunity.name}/$postId/',
      file: file,
    );
    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final PostModel post = PostModel(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        type: 'video',
        createdAt: DateTime.now(),
        linkVideo: r,
        linkImage: [],
        awards: [],
        userUid: user.uid,
        userProfilePic: user.profilePic,
      );

      final res = await _postRepo.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted successfully!');
        Routemaster.of(context).pop();
        for (var uid in selectedCommunity.members) {
          final NotificationModel notification = NotificationModel(
            id: uid,
            type: NotificationEnum.post,
            name: selectedCommunity.name,
            createdAt: DateTime.now(),
            uid: postId,
            profilePic: selectedCommunity.avatar,
            text: '${user.name} posted in ${selectedCommunity.name}',
            isRead: false,
          );
          _notificationRepo.sendNotification(
            notification: notification,
          );
        }
      });
    });
  }

  void deletePost(List<String> urls, PostModel post, BuildContext context) async {
    state = true;
    final res = await _postRepo.deletePost(post);
    final imageDelRes = await _storageRepository.deleteMultipleFiles(
      urls: urls,
    );
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    state = false;
    imageDelRes.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'File Deleted');
    });
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Deleted successfully!');
    });
  }

  void upVotePost(PostModel post) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepo.upVotePost(post, user.uid);
    final NotificationModel notification = NotificationModel(
      id: post.userUid,
      type: NotificationEnum.post,
      name: post.id,
      createdAt: DateTime.now(),
      uid: post.userUid,
      profilePic: '',
      text: '${user.name} upvoted your post',
      isRead: false,
    );
    res.fold((l) => (l), (r) {
      if (post.userUid != user.uid) {
        _notificationRepo.sendNotification(
          notification: notification,
        );
      }
    });
  }

  void downVotePost(PostModel post) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepo.downVotePost(post, user.uid);
    final NotificationModel notification = NotificationModel(
      id: post.userUid,
      type: NotificationEnum.post,
      name: post.id,
      createdAt: DateTime.now(),
      uid: post.userUid,
      profilePic: '',
      text: '${user.name} downvoted your post',
      isRead: false,
    );
    res.fold((l) => (l), (r) {
      if (post.userUid != user.uid) {
        _notificationRepo.sendNotification(
          notification: notification,
        );
      }
    });
  }

  Stream<List<PostModel>> getPosts(List<CommunityModel> communities) {
    if (communities.isNotEmpty) {
      return _postRepo.getPosts(communities);
    } else {
      return const Stream.empty();
    }
  }

  Stream<List<PostModel>> getGuestPosts() {
    return _postRepo.getGuestPosts();
  }

  Stream<PostModel> getPost(String postId) {
    return _postRepo.getPostById(postId);
  }

  Stream<List<CommentModel>> fetchPostComments(String postId) {
    return _postRepo.getCommentsOfPost(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required PostModel post,
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
    final res = await _postRepo.addComment(comment);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      final NotificationModel notification = NotificationModel(
        id: post.userUid,
        type: NotificationEnum.comment,
        name: post.id,
        createdAt: DateTime.now(),
        uid: post.userUid,
        profilePic: '',
        text: '${user.name} commented on your post',
        isRead: false,
      );
      if (post.userUid != user.uid) {
        _notificationRepo.sendNotification(
          notification: notification,
        );
      }
    });
  }
}
