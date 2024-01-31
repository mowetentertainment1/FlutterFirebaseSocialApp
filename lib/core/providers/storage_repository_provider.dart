import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/providers/firebase_providers.dart';
import 'package:untitled/core/type_defs.dart';
import 'package:uuid/uuid.dart';

import '../failure.dart';

final storageRepositoryProvider = Provider(
    (ref) => StorageRepository(firebaseStorage: ref.watch(storageProvider)));

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  FutureEither<String> storeFile(
      {required String path, required String id, required File? file}) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);
      UploadTask uploadTask = ref.putFile(file!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      return right(url);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  FutureEither<String> storeVideo(
      {required String path,  required File? file}) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child('${const Uuid().v4()}.mp4');
      UploadTask uploadTask = ref.putFile(file!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      return right(url);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Future<Either<Failure, List<String>>> storeMultipleFiles(
      {required String path, required List<File> files}) async {
    try {
      List<String> urls = [];
      for (File file in files) {
        final ref = _firebaseStorage.ref().child(path).child(file.uri.pathSegments.last);
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;
        String url = await taskSnapshot.ref.getDownloadURL();
        urls.add(url);
      }     return right(urls);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }


  FutureVoid deleteFile({required String path, required String id}) async {
    try {
      final ref = _firebaseStorage.ref().child(path);
      return right(ref.delete());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  FutureVoid deleteMultipleFiles({required List<String> urls}) async {
    try {
      for (String url in urls) {
        final ref = _firebaseStorage.refFromURL(url);
        await ref.delete();
      }
      return right(unit);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
