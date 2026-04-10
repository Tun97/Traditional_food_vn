import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  Future<String> uploadFoodImage({
    File? file,
    Uint8List? bytes,
    required String fileName,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('foods/$fileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        if (bytes == null) {
          throw Exception("Web nhưng bytes null");
        }

        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'), // 🔥 QUAN TRỌNG
        );
      } else {
        if (file == null) {
          throw Exception("Mobile nhưng file null");
        }

        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      final snapshot = await uploadTask.timeout(const Duration(seconds: 15));
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }
}
