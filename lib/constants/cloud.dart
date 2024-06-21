import 'dart:convert';
import 'dart:io';

import 'package:bbmp_reporter/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class FirebaseHelper {
  static final FirebaseHelper _instance = FirebaseHelper._internal();
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  factory FirebaseHelper() {
    return _instance;
  }

  FirebaseHelper._internal();

  Future<bool> uploadReport(Map<String, dynamic> data, File image) async {

    String fileName = "${getRandomString(10, _chars)}${p.extension(image.path)}";
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

  Future<void> sendFcmMessage(List<String> tokens, String message) async {
    // Replace with your FCM server key and FCM endpoint
    const String serverKey = 'YOUR_FCM_SERVER_KEY';
    const String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final payload = {
      'notification': {
        'title': 'Your App Name',
        'body': message,
      },
      'priority': 'high',
      'registration_ids': tokens,
    };

    try {
      final response = await http.post(Uri.parse(fcmEndpoint),
          headers: headers, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        print('FCM request sent successfully');
      } else {
        print('Error sending FCM request: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error sending FCM request: $e');
    }
  }


}