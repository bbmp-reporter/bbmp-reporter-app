import 'dart:io';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("BBMP Reporter"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
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
                    child: Text("Upload picture", style: TextStyle(color: Colors.white),),
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
