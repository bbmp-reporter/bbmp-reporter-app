import 'dart:convert';

import 'package:bbmp_reporter/constants/prefernces.dart';
import 'package:bbmp_reporter/homescreen.dart';
import 'package:bbmp_reporter/screens/detailsscreen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants/globals.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  cameras = await availableCameras();
  await LocalStorage().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

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
        future: verifyDetails(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.connectionState != ConnectionState.done){
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if(snapshot.data == true){
            return const HomeScreen();
          }
          else{
            return const DetailScreen();
          }
        }
      )
    );
  }
}

Future<bool> verifyDetails() async {
  SharedPreferences storage = await SharedPreferences.getInstance();
  String? detailsRaw = storage.getString("details");
  if(detailsRaw == null){
    return false;
  }
  Map<String, dynamic> detailsParsed = jsonDecode(detailsRaw);
  if(!detailsParsed.containsKey('name')){
    return false;
  }
  if(!detailsParsed.containsKey('phone')){
    return false;
  }
  return true;
}
