import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/constants/firebase_constants.dart';
import 'package:untitled/model/user.dart';

import '../../../../core/failure.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/type_defs.dart';
import '../../../../model/post_model.dart';


final userProfileRepoProvider = Provider((ref) {
  return UserProfileRepo(firestore: ref.watch(firestoreProvider));
});
class UserProfileRepo {
  final FirebaseFirestore _firestore;


  UserProfileRepo({required FirebaseFirestore firestore}) : _firestore = firestore;
  CollectionReference get _posts => _firestore.collection("posts");

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid editUser(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where("uid", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) => event.docs
        .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
        .toList());
  }
  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(
          {"karma": user.karma}
      ));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<List<UserModel>> searchUser(String query) {
    return _users
        .where(
      "name",
      isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
      isLessThan: query.isEmpty
          ? null
          : query.substring(0, query.length - 1) +
          String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
    ).where(
      "name",
      isNotEqualTo: "Guest",
    )
        .snapshots()
        .map((event) {
      List<UserModel> users = [];
      for (var doc in event.docs) {
        users.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return users;
    });
  }
  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
            (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }
}