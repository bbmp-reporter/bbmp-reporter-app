import 'dart:math';

import 'package:bbmp_reporter/constants/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cached_image/firebase_cached_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyTrashScreen extends StatefulWidget {
  const NearbyTrashScreen({super.key});

  @override
  State<NearbyTrashScreen> createState() => _NearbyTrashScreenState();
}

class _NearbyTrashScreenState extends State<NearbyTrashScreen> {
  List<WeightedLatLng> data = [];
  List<Map<String, dynamic>> reports = [];

  TextStyle headingStyle = const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold);

  GeoPoint selectedPoint = const GeoPoint(77.594, 12.715);
  Position? currentPosition;

  MapController mapController = MapController();

  @override
  void initState() {
    LocationHelper().getCurrentCoordinates().then((position){
      setState(() {
        currentPosition = position;
        initializeReportStream();
      });
    });
    data.add(WeightedLatLng(const LatLng(0, 0), 1));
    super.initState();
  }

  void initializeReportStream() {
    final docRef = FirebaseFirestore.instance.collection("reports").orderBy("timestamp", descending: true);
    Set<String> processedDocIds = {};

    docRef.snapshots().listen(
          (event) {
        final source = (event.metadata.hasPendingWrites) ? "Local" : "Server";
        for (var doc in event.docs) {
          if (!processedDocIds.contains(doc.id)) {
            GeoPoint location = doc.data()['location'] as GeoPoint;
            data.add(WeightedLatLng(LatLng(location.latitude, location.longitude), 1));
            if(LocationHelper().calculateDistance(location.latitude, location.longitude, currentPosition!.latitude, currentPosition!.longitude) < 2){
              reports.add(doc.data());
              selectedPoint = location;
            }
            processedDocIds.add(doc.id);
          }
        }
        setState(() {});
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<double, MaterialColor>> gradients = [
      HeatMapOptions.defaultGradient,
      {
        0.25: Colors.blue,
        0.55: Colors.red,
        0.85: Colors.pink,
        1.0: Colors.purple
      },
      {
        0.0: Colors.red,
        1.0: Colors.red
      }
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(12.981895183576972, 77.62246118564225),
              initialZoom: 12,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(-90, -180),
                  const LatLng(90, 180),
                ),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              HeatMapLayer(
                heatMapDataSource: InMemoryHeatMapDataSource(data: data),
                heatMapOptions: HeatMapOptions(gradient: gradients[1], layerOpacity: 1),
                // reset: _rebuildStream.stream,
              ),
              MarkerLayer(
                markers: [
                  Marker(point: LatLng(selectedPoint.latitude, selectedPoint.longitude), child: const Icon(Icons.location_pin)),
                  if(currentPosition!=null) Marker(point: LatLng(currentPosition!.latitude, currentPosition!.longitude), child: const Icon(Icons.man)),
                ],
              ),
              RichAttributionWidget(
                popupInitialDisplayDuration: const Duration(seconds: 5),
                animationConfig: const ScaleRAWA(),
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                  const TextSourceAttribution(
                    'This attribution is the same throughout this app, except '
                        'where otherwise specified',
                    prependCopyright: false,
                  ),
                ],
              ),
            ],
          ),
          DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.4,
              maxChildSize: 1,
              builder: (BuildContext context, ScrollController scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const Icon(Icons.keyboard_arrow_up_rounded, size: 50,),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: ListView.builder(
                            itemCount: reports.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Reported by", style: headingStyle,),
                                            Text(reports[index]['name']),
                                            SizedBox(height: 5,),
                                            Text("Timestamp", style: headingStyle,),
                                            Text(DateFormat('MMM dd h:mm a').format((reports[index]['timestamp'] as Timestamp).toDate())),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text("Phone", style: headingStyle,),
                                            Text(reports[index]['phone']),
                                            SizedBox(height: 5,),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: (){
                                                    setState(() {
                                                      selectedPoint = reports[index]['location'] as GeoPoint;
                                                      mapController.move(LatLng(selectedPoint.latitude, selectedPoint.longitude), 16);
                                                    });
                                                  },
                                                  child: Icon(Icons.location_pin),
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (!await launchUrl(Uri.parse(reports[index]['image']))) {
                                                      throw Exception('Could not launch url');
                                                    }
                                                  },
                                                  child: Icon(Icons.camera_enhance_rounded),
                                                )
                                              ],
                                            ),
                                            // Text("Timestamp", style: headingStyle,),
                                            // Text(DateFormat('MMM dd h:mm a').format((reports[index]['timestamp'] as Timestamp).toDate())),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                          child: SizedBox(
                                              height: 70,
                                              width: 70,
                                              child: Image.network(reports[index]['image'], fit: BoxFit.fitWidth,)
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              );
                            }),
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
