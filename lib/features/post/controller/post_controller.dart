import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/enums/enums.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../model/comment_model.dart';
import '../../../model/community_model.dart';
import '../../../model/post_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../home/user_profile/controller/user_profile_controller.dart';
import '../repository/post_repo.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepo = ref.watch(postRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepo: postRepo,
    storageRepository: storageRepository,
    ref: ref,
  );
});
final userPostsProvider =
    StreamProvider.family<List<Post>, List<Community>>((ref, communities) {
  return ref.read(postControllerProvider.notifier).getPosts(communities);
});
final guestPostsProvider = StreamProvider((ref) {
  return ref.read(postControllerProvider.notifier).getGuestPosts();
});
final getPostByIdProvider = StreamProvider.family<Post, String>((ref, postId) {
  return ref.watch(postControllerProvider.notifier).getPost(postId);
});
final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
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
        linkVideo: '',
        linkImage: urls,
        awards: [],
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
    required Community selectedCommunity,
    required String linkVideo,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

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
      type: 'text',
      createdAt: DateTime.now(),
      linkVideo: linkVideo,
      linkImage: [], awards: [],
    );

    final res = await _postRepo.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted.');

    });
  }
  void shareVideoPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}/$postId/',
      file: file,
      id: postId,
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
        type: 'video',
        createdAt: DateTime.now(),
        linkVideo: r,
        linkImage: [],
        awards: [],
      );

      final res = await _postRepo.addPost(post);
      _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted successfully!');
        Routemaster.of(context).pop();
      });
    });
  }

  void deletePost(List<String> urls, Post post, BuildContext context
      ) async {
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

  void upVotePost(Post post) async {
    final userId = _ref.read(userProvider)!.uid;
    _postRepo.upVotePost(post, userId);
  }

  void downVotePost(Post post) async {
    final userId = _ref.read(userProvider)!.uid;
    _postRepo.downVotePost(post, userId);
  }

  Stream<List<Post>> getPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepo.getPosts(communities);
    } else {
      return const Stream.empty();
    }
  }

  Stream<List<Post>> getGuestPosts() {
    return _postRepo.getGuestPosts();
  }

  Stream<Post> getPost(String postId) {
    return _postRepo.getPostById(postId);
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepo.getCommentsOfPost(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: user.name,
      profilePic: user.profilePic,
    );
    final res = await _postRepo.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }
}
