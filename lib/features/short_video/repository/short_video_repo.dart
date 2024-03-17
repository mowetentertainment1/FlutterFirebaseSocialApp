import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/type_defs.dart';
import 'package:untitled/model/short_video_model.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../model/comment_model.dart';

final shortVideoRepoProvider = Provider((ref) {
  return ShortVideoRepo(firestore: ref.watch(firestoreProvider));
});

class ShortVideoRepo {
  final FirebaseFirestore _firestore;

  ShortVideoRepo({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _shortVideo =>
      _firestore.collection(FirebaseConstants.shortVideosCollection);
  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _user =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid uploadVideo(ShortVideoModel video) async {
    try {
      return right(FirebaseFirestore.instance
          .collection('shortvideos').doc(video.id).set(
            video.toMap(),
          ));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<List<ShortVideoModel>> getShortVideos(List<String> followingUids) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    followingUids.add(currentUserUid);
    return FirebaseFirestore.instance
        .collection('shortvideos')
        .where('userUid', whereIn: followingUids)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => ShortVideoModel.fromMap(doc.data())).toList();
      } catch (e) {
        print('Error fetching and mapping data: $e');
        return [];
      }
    });
  }
  Stream<List<ShortVideoModel>> getShortVideosByUid(String uid) {
    return _shortVideo
        .where("userUid", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) => event.docs
        .map((e) => ShortVideoModel.fromMap(e.data() as Map<String, dynamic>))
        .toList());
  }
  FutureVoid upVoteShortVideo(ShortVideoModel video, String userId) async {
    try {
      if (video.downVotes.contains(userId)) {
        _shortVideo.doc(video.id).update({
          'downVotes': FieldValue.arrayRemove([userId]),
        });
      }
      if (video.upVotes.contains(userId)) {
        _shortVideo.doc(video.id).update({
          'upVotes': FieldValue.arrayRemove([userId]),
        });
      } else {
        _shortVideo.doc(video.id).update({
          'upVotes': FieldValue.arrayUnion([userId]),
        });
      }
      return right(unit);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  FutureVoid downVoteShortVideo(ShortVideoModel video, String userId) async {
    try {
      if (video.upVotes.contains(userId)) {
        _shortVideo.doc(video.id).update({
          'upVotes': FieldValue.arrayRemove([userId]),
        });
      }

      if (video.downVotes.contains(userId)) {
        _shortVideo.doc(video.id).update({
          'downVotes': FieldValue.arrayRemove([userId]),
        });
      } else {
        _shortVideo.doc(video.id).update({
          'downVotes': FieldValue.arrayUnion([userId]),
        });
      }
      return right(unit);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<List<CommentModel>> getCommentsOfShortVideo(String postId) {
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

      return right(_shortVideo.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  FutureVoid deleteComment(CommentModel comment) async {
    try {
      await _comments.doc(comment.id).delete();

      return right(_shortVideo.doc(comment.postId).update({
        'commentCount': FieldValue.increment(-1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
