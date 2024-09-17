import 'dart:convert';
import 'dart:io';

import 'package:app/model/user.dart';
import 'package:app/screen/log_in.dart';
import 'package:app/service/Firebase_database.dart';
import 'package:app/service/deep_face_api.dart';
import 'package:app/service/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePageProvider extends ChangeNotifier {
  HomePageProvider({required this.context}) {}

  bool loading = false;
  DeepFaceApi deepFaceApi = DeepFaceApi();
  FirebaseMethods firebaseInstance = FirebaseMethods();

  BuildContext context;

  Future<void> processingLogIn(
      String caputuredImagePath, List<User> users) async {
    pageLoading();
    final file = File(caputuredImagePath);
    Uint8List filebytes = file.readAsBytesSync();
    String base64FileBytes = base64Encode(filebytes);
    try {
      for (var i = 0; i < users.length; i++) {
        bool reply =
            await deepFaceApi.verifyFace(base64FileBytes, users![i].image);
        if (reply == true) {
          loading = false;
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: ((context) => VotingPage(
                        user: users[i],
                      ))));
          notifyListeners();
          break;
        } else if (i + 1 == users.length && reply == false) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                "You are not Registered!",
                style: TextStyle(fontSize: 20, color: Colors.white),
              )));
        }
      }
    } on NoConnectionException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.black,
          content: Text(
            "Check your internet connectivity or maybe something went wrong with Server",
            style: TextStyle(fontSize: 20, color: Colors.white),
          )));
      loading = false;
      notifyListeners();
    }

    loading = false;
    notifyListeners();
  }

  void pageLoading() {
    loading = true;
    notifyListeners();
  }
}
