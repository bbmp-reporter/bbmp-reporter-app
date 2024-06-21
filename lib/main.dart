import 'dart:convert';
import 'dart:math';

import 'package:bbmp_reporter/constants/prefernces.dart';
import 'package:bbmp_reporter/homescreen.dart';
import 'package:bbmp_reporter/screens/detailsscreen.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/globals.dart';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
const _nums = '1234567890';
Random _rnd = Random();

String getRandomString(int length, String space) => String.fromCharCodes(Iterable.generate(
    length, (_) => space.codeUnitAt(_rnd.nextInt(space.length))));

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);

  cameras = await availableCameras();
  await LocalStorage().initialize();

  runApp(const MyApp());
}

GeoPoint generateRandomPoint(GeoPoint center, double radiusInMeters) {
  final random = Random();

  final angle = random.nextDouble() * 2 * pi;

  final distance = sqrt(random.nextDouble()) * radiusInMeters;

  final deltaLat = distance * cos(angle) / 111320; // 111320 meters is approximately 1 degree latitude
  final deltaLng = distance * sin(angle) / (111320 * cos(center.latitude * pi / 180));

  return GeoPoint(center.latitude + deltaLat, center.longitude + deltaLng);

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  void fillers(){

    Map<String, dynamic> data = {
      'name': 'Loading...',
      'phone': 'Loading...',
    };

    for(int i = 0; i<50; i++){
      data['name'] = getRandomString(10, _chars);
      data['phone'] = getRandomString(10, _nums);
      data['timestamp'] = Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 50 - i, minutes:120 - (i * 2))));
      data['image'] = "https://firebasestorage.googleapis.com/v0/b/bbmp-reporter.appspot.com/o/uploads%2FvLuSv3lphs.jpg?alt=media&token=0a4a5edd-86a8-4cbc-a827-cff8d63454b5";
      data['location'] = generateRandomPoint(const GeoPoint(12.97, 77.59), 8000);
      FirebaseFirestore.instance.collection('reports').doc().set(data);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // fillers();

    return MaterialApp(
      title: 'BBMP Reporter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: verifyDetails(context),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.connectionState != ConnectionState.done){
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const HomeScreen();
        }
      )
    );
  }
}

Future<bool> verifyDetails(context) async {
  SharedPreferences storage = await SharedPreferences.getInstance();
  String? detailsRaw = storage.getString("details");
  if(detailsRaw == null){
    return false;
  }
  Map<String, dynamic> detailsParsed = jsonDecode(detailsRaw);
  if(!detailsParsed.containsKey('name')){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DetailScreen()));
    return false;
  }
  if(!detailsParsed.containsKey('phone')){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DetailScreen()));
    return false;
  }
  return true;
}
