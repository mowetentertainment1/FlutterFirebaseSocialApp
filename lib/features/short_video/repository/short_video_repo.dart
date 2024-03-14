import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/type_defs.dart';
import 'package:untitled/model/community_model.dart';
import 'package:untitled/model/short_video_model.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../model/comment_model.dart';
import '../../../model/post_model.dart';

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

  // upload video
  FutureVoid uploadVideo(ShortVideoModel video) async {
    try {
      return right(FirebaseFirestore.instance
          .collection('shortvideos').doc(video.userUid).set(
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
}
