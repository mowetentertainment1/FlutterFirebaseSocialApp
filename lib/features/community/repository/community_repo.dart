import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/type_defs.dart';
import 'package:untitled/model/community_model.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../model/post_model.dart';

final communityRepoProvider = Provider((ref) {
  return CommunityRepo(firestore: ref.watch(firestoreProvider), storageRepository: ref.watch(storageRepositoryProvider));
});

class CommunityRepo {
  final FirebaseFirestore _firestore;
  final StorageRepository _storageRepository;

  CommunityRepo({required FirebaseFirestore firestore,required StorageRepository storageRepository})
      : _storageRepository = storageRepository,_firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw Exception("Community already exists");
      }
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getCommunities(String uid) {
    return _communities
        .where("members", arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  FutureVoid joinCommunity(String communityName, String uid) async {
    try {
      var communityDoc = await _communities.doc(communityName).get();
      if (!communityDoc.exists) {
        throw Exception("Community doesn't exists");
      }
      return right(_communities.doc(communityName).update({
        "members": FieldValue.arrayUnion([uid])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  FutureVoid leaveCommunity(String communityName, String uid) async {
    try {
      var communityDoc = await _communities.doc(communityName).get();
      if (!communityDoc.exists) {
        throw Exception("Community doesn't exists");
      }
      return right(_communities.doc(communityName).update({
        "members": FieldValue.arrayRemove([uid])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<Community> getCommunityName(String communityName) {
    return _communities.doc(communityName).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
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
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  FutureVoid addMod(String communityName, List<String> uids) async {
    try {
      var communityDoc = await _communities.doc(communityName).get();
      if (!communityDoc.exists) {
        throw Exception("Community doesn't exists");
      }
      return right(_communities.doc(communityName).update({
        "mods": uids
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<List<Post>> getCommunityPosts(String communityName) {
    return _posts
        .where("communityName", isEqualTo: communityName)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) => event.docs
        .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
        .toList());
  }
  FutureVoid deleteCommunity(String communityName) async {
    try {
      var communityDoc = await _communities.doc(communityName).get();
      var posts = await _posts.where("communityName", isEqualTo: communityName).get();

      if (!communityDoc.exists) {
        throw Exception("Community doesn't exist");
      }

      for (var post in posts.docs) {
        List<String> urls = ((post.data() as Map<String, dynamic>)["linkImage"] as List<String>?) ?? [];
        await post.reference.delete();
        // final imageDelRes = await _storageRepository.deleteMultipleFiles(urls: urls);
        // imageDelRes.fold((l) => throw Exception(l.message), (r) => {});
      }

      return right(_communities.doc(communityName).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw Failure(e.toString());
    }
  }


  CollectionReference get _posts => _firestore.collection("posts");
  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
