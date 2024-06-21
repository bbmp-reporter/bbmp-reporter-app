import 'dart:io';
import 'package:bbmp_reporter/constants/prefernces.dart';
import 'package:bbmp_reporter/screens/detailsscreen.dart';
import 'package:bbmp_reporter/screens/nearby_trash.dart';
import 'package:bbmp_reporter/screens/reportdetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    print("LocalStorage().storage.getBool('isEmployee')");
    print(LocalStorage().storage.getBool('isEmployee'));

    return Scaffold(
      appBar: AppBar(
        title: const Text("BBMP Reporter"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LocalStorage().storage.getBool('isEmployee') != true
                ? GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
                      if (pickedFile == null) return; //Checks if the user did actually pick something

                      final File image = (File(pickedFile.path));
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReportDetailsScreen(image: image)));
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                      ),
                      child: const SizedBox(
                        width: 200,
                        height: 50,
                        child: Center(
                          child: Text(
                            "Upload picture",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NearbyTrashScreen()));
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                      ),
                      child: const SizedBox(
                        width: 200,
                        height: 50,
                        child: Center(
                          child: Text(
                            "Nearby Trash",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const DetailScreen()));
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                ),
                child: const SizedBox(
                  width: 200,
                  height: 50,
                  child: Center(
                    child: Text(
                      "Edit details",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
