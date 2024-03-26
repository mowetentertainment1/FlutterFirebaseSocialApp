import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/constants/firebase_constants.dart';
import 'package:untitled/model/user_model.dart';

import '../../../../core/failure.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/type_defs.dart';
import '../../../../model/post_model.dart';

final userProfileRepoProvider = Provider((ref) {
  return UserProfileRepo(
      firestore: ref.watch(
        firestoreProvider,
      ),
      auth: ref.watch(authProvider));
});

class UserProfileRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserProfileRepo({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;
  CollectionReference get _posts => _firestore.collection("posts");

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid editUser(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<PostModel>> getUserPosts(String uid) {
    return _posts
        .where("userUid", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => PostModel.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({"karma": user.karma}));
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
        )
        .snapshots()
        .map((event) {
      List<UserModel> users = [];
      for (var doc in event.docs) {
        if (doc.id != _auth.currentUser!.uid) {
          users.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
        }
      }
      return users;
    });
  }

  void followUser(String uid, String followUid) async {
    try {
      await _users.doc(uid).update({
        "following": FieldValue.arrayUnion([followUid])
      });
      await _users.doc(followUid).update({
        "followers": FieldValue.arrayUnion([uid])
      });
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  void unFollowUser(String uid, String followUid) async {
    try {
      await _users.doc(uid).update({
        "following": FieldValue.arrayRemove([followUid])
      });
      await _users.doc(followUid).update({
        "followers": FieldValue.arrayRemove([uid])
      });
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw Failure(e.toString());
    }
  }
  Stream<List<UserModel>> getUserFollowers(String uid) {
    return _users
        .where("followers", arrayContains: uid)
        .snapshots()
        .map((event) => event.docs
            .map((e) => UserModel.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }


}
