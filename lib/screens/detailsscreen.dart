import 'dart:convert';

import 'package:bbmp_reporter/constants/prefernces.dart';
import 'package:bbmp_reporter/homescreen.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool isBBMPEmployee = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
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
            Row(
              children: [
                const Text("BBMP Employee?", style: TextStyle(fontSize: 20.0),),
                Checkbox(value: isBBMPEmployee, onChanged: (value){
                  setState(() {
                    isBBMPEmployee = value!;
                  });
                })
              ],
            )
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: (){
          if(nameController.text.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name')));
            return;
          }
          if(phoneController.text.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a phone')));
            return;
          }
          Map<String, dynamic> details = {
            'name': nameController.text,
            'phone': phoneController.text,
          };
          LocalStorage().storage.setString("details", jsonEncode(details));
          LocalStorage().storage.setBool("isEmployee", isBBMPEmployee);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details saved successfully.')));
          Navigator.of(context).pop();
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(99))
          ),
          child: const Icon(Icons.navigate_next, color: Colors.white,),
        ),
      ),
    );
  }
}
