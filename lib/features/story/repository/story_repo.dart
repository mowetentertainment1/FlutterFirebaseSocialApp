import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/type_defs.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../model/story_model.dart';

final storyRepoProvider = Provider((ref) {
  return StoryRepo(firestore: ref.watch(firestoreProvider));
});

class StoryRepo {
  final FirebaseFirestore _firestore;

  StoryRepo({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _stories => _firestore.collection(FirebaseConstants.storiesCollection);

  FutureVoid addOrUpdateStory(StoryModel story) async {
    try {
      final isCollectionExists = await _stories.doc(story.id).get();
      if (!isCollectionExists.exists) {
        return right( _stories.doc(story.id).set(story.toMap()));
      } else {
        List<String> storyImageUrls = [];
        var statusesSnapshot = await _stories
            .where(
          'id',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
            .get();

          storyImageUrls = List<String>.from(statusesSnapshot.docs[0].get('linkImage'));
          for (var file in story.linkImage) {
            storyImageUrls.add(file);
          }
          return right (_stories
              .doc(statusesSnapshot.docs[0].id)
              .update({
            'linkImage': storyImageUrls,
          }));

      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  Stream<List<StoryModel>> getStories(List<String> followingUids) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    followingUids.add(currentUserUid);
    return FirebaseFirestore.instance
        .collection('stories')
        .where('userUid', whereIn: followingUids)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => StoryModel.fromMap(doc.data())).toList();
      } catch (e) {
        print('Error fetching and mapping data: $e');
        return [];
      }
    });
  }



}
