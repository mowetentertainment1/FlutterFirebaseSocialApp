import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/type_defs.dart';
import 'package:untitled/model/community_model.dart';

import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../model/post_model.dart';

final postRepoProvider = Provider((ref) {
  return PostRepo(firestore: ref.watch(firestoreProvider));
});

class PostRepo {
  final FirebaseFirestore _firestore;

  PostRepo({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _posts => _firestore.collection("posts");

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getPosts(List<Community> communities) {
    return _posts
        .where("communityName",
            whereIn: communities.map((e) => e.name).toList())
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }
}
