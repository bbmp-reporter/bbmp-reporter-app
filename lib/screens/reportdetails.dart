import 'dart:convert';
import 'dart:io';

import 'package:bbmp_reporter/constants/cloud.dart';
import 'package:bbmp_reporter/constants/location.dart';
import 'package:bbmp_reporter/constants/prefernces.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ReportDetailsScreen extends StatefulWidget {
  final File image;
  const ReportDetailsScreen({super.key, required this.image});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  late Future<Position> getLocationFuture;

  Map<String, dynamic> data = {
    'name': 'Loading...',
    'phone': 'Loading...',
  };

  bool isUploading = false;


  @override
  void initState() {
    getDetails();
    getLocationFuture = getLocation();
    super.initState();
  }

  Future<Position> getLocation() async {
    Position position = await LocationHelper().getCurrentCoordinates();
    data['location'] = GeoPoint(position.latitude, position.longitude);
    return position;
  }

  Future<void> getDetails() async {
    Map<String, dynamic> localDetails = jsonDecode(LocalStorage().storage.get("details").toString());
    data['name'] = localDetails['name'];
    data['phone'] = localDetails['phone'];
  }

  @override
  Widget build(BuildContext context) {

    nameController.text = data['name'];
    phoneController.text = data['phone'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report details"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                SizedBox(
                  height: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DETAILS", style: TextStyle(fontSize: 30.0),),
                      const SizedBox(height: 30,),
                      const Text("Name", style: TextStyle(fontSize: 20.0),),
                      TextField(
                        controller: nameController,
                      ),
                      const SizedBox(height: 20,),
                      const Text("Phone", style: TextStyle(fontSize: 20.0),),
                      TextField(
                        controller: phoneController,
                      ),
                      const SizedBox(height: 20,),
                      const Text("Address", style: TextStyle(fontSize: 20.0),),
                      FutureBuilder(
                          future: getLocationFuture,
                          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
                            if(snapshot.connectionState != ConnectionState.done){
                              return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(color: Colors.black,),
                              );
                            }
                            locationController.text = "Current location";
                            return TextField(
                              controller: locationController,
                            );
                          }
                      ),
                      const SizedBox(height: 30,),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () async {
                      if(isUploading){
                        return;
                      }
                      setState(() {
                        isUploading = true;
                      });
                      data['timestamp'] = Timestamp.fromDate(DateTime.now());
                      Future reportUploadFuture = FirebaseHelper().uploadReport(data, widget.image);
                      // Future<QuerySnapshot> notificationFuture = FirebaseFirestore.instance.collection('users').where('isEmployee', isEqualTo: false).get();
                      //
                      // List<String> fcmList = [];
                      //
                      // notificationFuture.then((QuerySnapshot snapshot){
                      //   snapshot.docs.forEach((QueryDocumentSnapshot document){
                      //     fcmList.add(document.get('fcmToken'));
                      //     FirebaseMessaging.instance.
                      //   });
                      // });



                      await Future.wait([reportUploadFuture]);

                      setState(() {
                        isUploading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reported successfully!")));
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                      ),
                      child: SizedBox(
                        width: 200,
                        height: 45,
                        child: Center(
                          child: !isUploading ? const Text("Upload report", style: TextStyle(color: Colors.white),) : const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white,)),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.2,
            builder: (BuildContext context, ScrollController scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    const Icon(Icons.keyboard_arrow_up_rounded, size: 50,),
                    ClipRRect(
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(32.0), topLeft: Radius.circular(32.0)),
                        child: Image.file(widget.image)
                    )
                  ],
                ),
              );
            }
          )
          ],
        ),
    );
  }
}
