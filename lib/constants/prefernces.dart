import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  late SharedPreferences _storage;

  SharedPreferences get storage => _storage;

  factory LocalStorage() {
    return _instance;
  }

  LocalStorage._internal();

  Future<void> initialize() async {
    _storage = await SharedPreferences.getInstance();
  }

  Map<String, dynamic> getDetails() {
    String? details = LocalStorage().storage.get('details') as String?;
    if(details == null){
      return {"isEmployee": null};
    }
    return jsonDecode(details as String);
  }

}