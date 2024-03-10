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

  CollectionReference get _shortVideo => _firestore.collection(FirebaseConstants.shortVideosCollection);
  CollectionReference get _comments => _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _user => _firestore.collection(FirebaseConstants.usersCollection);



  // upload video
  FutureVoid uploadVideo(ShortVideoModel video) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
      await _user.doc(uid).get();
      // get id
      var allDocs = await _shortVideo.get();
      int len = allDocs.docs.length;
      // String videoUrl = await _uploadVideoToStorage("Video $len", videoPath);
      // String thumbnail = await _uploadImageToStorage("Video $len", videoPath);

      // ShortVideoModel video = ShortVideoModel(
      //   username: (userDoc.data()! as Map<String, dynamic>)['name'],
      //   uid: uid,
      //   id: "Video $len",
      //   likes: [],
      //   commentCount: 0,
      //   shareCount: 0,
      //   songName: songName,
      //   caption: caption,
      //   videoUrl: videoUrl,
      //   profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
      //   thumbnail: thumbnail,
      // );

     return right(_shortVideo.doc(video.id).set(
       video.toMap(),)
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

}
