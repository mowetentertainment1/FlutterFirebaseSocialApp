import 'dart:io';
import 'dart:typed_data';

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
final postControllerProvider = StateNotifierProvider<PostController, bool>((ref) {
  final postRepo = ref.watch(postRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepo: postRepo,
    storageRepository: storageRepository,
    ref: ref,
  );
});
final userPostsProvider = StreamProvider.family<List<Post>, List<Community>>((ref, communities) {
  return ref.read(postControllerProvider.notifier).getPosts(communities);
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
      _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted.');
        Routemaster.of(context).push('/');
      });
    });
  }
}
  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
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
      awards: [],
      description: description, linkImage: [],
    );

    final res = await _postRepo.addPost(post);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted.');
      Routemaster.of(context).push('/');
    });
  }
  void deletePost(Post post, BuildContext context) async {
    state = true;
    final res = await _postRepo.deletePost(post);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.deletePost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Post deleted.');
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
  Stream<Post>
      getPost(String postId) {
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
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }
}