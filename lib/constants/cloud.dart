import 'dart:io';

import 'package:bbmp_reporter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseHelper {
  static final FirebaseHelper _instance = FirebaseHelper._internal();
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  factory FirebaseHelper() {
    return _instance;
  }

  FirebaseHelper._internal();

  Future<bool> uploadReport(Map<String, dynamic> data, File image) async {
    String fileName = getRandomString(10, _chars);
    Reference reference = FirebaseStorage.instance.ref('uploads/$fileName');
    Future uploadFileFuture = reference.putFile(image);
    await uploadFileFuture;

    String imageUrl = await reference.getDownloadURL();
    data['image'] = imageUrl;
    Future uploadReportFuture = FirebaseFirestore.instance.collection('reports').doc().set(data);

    await Future.wait([uploadReportFuture, uploadFileFuture]);

    return true;
    // Upload file
  }

}