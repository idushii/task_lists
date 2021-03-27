import 'dart:convert';

import 'imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static final Cache _singleton = Cache._internal();

  factory Cache() {
    return _singleton;
  }

  Cache._internal();

  SharedPreferences prefs;

  init() async {
    prefs = await SharedPreferences.getInstance();

    Future.delayed(Duration(seconds: 5)).then((_) {
      var res = <String, dynamic>{};
      prefs.getKeys().forEach((element) {
        res[element] = prefs.get(element);
      });

    });

    // updateIsOpenOnboarding();
  }

  String userToken() {
    return prefs.getString('token') ?? '';
  }

  updateUserToken(String token) {
    prefs.setString('token', token);
  }

  bool checkIsOpenOnboarding() {
    // return false;
    return prefs.getBool('open-onboarding') == true;
  }

  updateIsOpenOnboarding([bool isOpen]) {
    if (isOpen == true) {
      prefs.setBool('open-onboarding', true);
    } else {
      prefs.remove('open-onboarding');
    }
  }

  bool checkIsOpenSelectBenzine() {
    // return false;
    return prefs.getBool('open-select-benzine') == true;
  }

  updateIsOpenSelectBenzine([bool isOpen]) {
    if (isOpen == true) {
      prefs.setBool('open-select-benzine', true);
    } else {
      prefs.remove('open-select-benzine');
    }
  }

  updateJson(String key, Map<String, dynamic> json) {
    var source = jsonEncode(json);
    Cache().prefs.setString(key, source);
  }

  Map<String, dynamic> getJson(String key) {
    var source = Cache().prefs.getString(key);
    if (source != null) {
      return jsonDecode(source);
    }
    return null;
  }
}