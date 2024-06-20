import 'dart:convert';
import 'dart:io';

import 'package:bbmp_reporter/constants/cloud.dart';
import 'package:bbmp_reporter/constants/location.dart';
import 'package:bbmp_reporter/constants/prefernces.dart';
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

  Map<String, dynamic> data = {
    'name': 'Loading...',
    'phone': 'Loading...',
  };

  @override
  void initState() {
    LocationHelper().getCurrentCoordinates().then((position){
      data['location'] = [position.latitude, position.longitude];
    });
    getDetails();
    super.initState();
  }

  Future<Position> getLocation() async {
    Position position = await LocationHelper().getCurrentCoordinates();
    data['location'] = [position.latitude, position.longitude];
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
                    future: getLocation(),
                    builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
                      if(snapshot.connectionState != ConnectionState.done){
                        return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                        );
                      }
                      locationController.text = "Current location";
                      return TextField(
                        controller: locationController,
                      );
                    }
                ),
                SizedBox(height: 30,),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: (){
                      data['timestamp'] = DateTime.timestamp();
                      FirebaseHelper().uploadReport(data, widget.image);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                      ),
                      child: const SizedBox(
                        width: 200,
                        height: 45,
                        child: Center(
                          child: Text("Upload report", style: TextStyle(color: Colors.white),),
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
