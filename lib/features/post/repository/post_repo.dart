import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/type_defs.dart';
import 'package:untitled/model/community_model.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../model/comment_model.dart';
import '../../../model/post_model.dart';

final postRepoProvider = Provider((ref) {
  return PostRepo(firestore: ref.watch(firestoreProvider));
});

class PostRepo {
  final FirebaseFirestore _firestore;

  PostRepo({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _posts => _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments => _firestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid addPost(PostModel post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<PostModel>> getPosts(List<CommunityModel> communities) {
    return _posts
        .where("communityName",
            whereIn: communities.map((e) => e.name).toList())
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => PostModel.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }
  Stream<List<PostModel>> getGuestPosts() {
    return _posts
        .orderBy("createdAt", descending: true).limit(10)
        .snapshots()
        .map((event) => event.docs
            .map((e) => PostModel.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid deletePost(PostModel post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid upVotePost(PostModel post, String userId) async {
    try {
      if (post.downvotes.contains(userId)) {
        _posts.doc(post.id).update({
          'downvotes': FieldValue.arrayRemove([userId]),
        });
      }

      if (post.upvotes.contains(userId)) {
        _posts.doc(post.id).update({
          'upvotes': FieldValue.arrayRemove([userId]),
        });
      } else {
        _posts.doc(post.id).update({
          'upvotes': FieldValue.arrayUnion([userId]),
        });
      }
      return right(unit);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  FutureVoid downVotePost(PostModel post, String userId) async {
    try {
      if (post.upvotes.contains(userId)) {
        _posts.doc(post.id).update({
          'upvotes': FieldValue.arrayRemove([userId]),
        });
      }

      if (post.downvotes.contains(userId)) {
        _posts.doc(post.id).update({
          'downvotes': FieldValue.arrayRemove([userId]),
        });
      } else {
        _posts.doc(post.id).update({
          'downvotes': FieldValue.arrayUnion([userId]),
        });
      }
      return right(unit);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<PostModel> getPostById(String postId) {
    return _posts.doc(postId).snapshots().map(
        (event) => PostModel.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<List<CommentModel>> getCommentsOfPost(String postId) {
    return _comments.where('postId', isEqualTo: postId).orderBy('createdAt', descending: true).snapshots().map(
          (event) => event.docs
          .map(
            (e) => CommentModel.fromMap(
          e.data() as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
  FutureVoid addComment(CommentModel comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
