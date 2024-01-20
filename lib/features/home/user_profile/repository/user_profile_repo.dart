import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/constants/firebase_constants.dart';
import 'package:untitled/model/user.dart';

import '../../../../core/failure.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/type_defs.dart';


final userProfileRepoProvider = Provider((ref) {
  return UserProfileRepo(firestore: ref.watch(firestoreProvider));
});
class UserProfileRepo {
  final FirebaseFirestore _firestore;


  UserProfileRepo({required FirebaseFirestore firestore}) : _firestore = firestore;
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
}