import 'package:app/model/user.dart';
import 'package:app/screen/home.dart';
import 'package:app/service/Firebase_database.dart';
import 'package:app/service/contract_provider.dart';
import 'package:app/service/deep_face_api.dart';
import 'package:app/service/exceptions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:m7_livelyness_detection/index.dart';
import 'package:web3dart/web3dart.dart';

class SignUpPageProvider extends ChangeNotifier {
  SignUpPageProvider({required this.context});
  bool loading = false;
  DeepFaceApi deepFaceApi = DeepFaceApi();
  FirebaseMethods firebaseInstance = FirebaseMethods();
  BuildContext context;

  void pageLoading() {
    loading = true;
    notifyListeners();
  }

  Future<void> registration(
      List<User> registeredUsers,
      ContractProvider contractProvider,
      String base64FileBytes,
      Map<String, String> userInformation,
      String id) async {
    pageLoading();
    try {
      if (registeredUsers.isEmpty) {
        try {
          firebaseInstance.addUsers(userInformation);
          contractProvider.registerVoter(id);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.black,
              content: Text(
                "Registered Successfully",
                style: TextStyle(fontSize: 20, color: Colors.white),
              )));
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: ((context) => Home())));
        } on FirebaseException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              "Firebase Errors, check your internet connection",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ));
        }
      } else if (registeredUsers.isNotEmpty) {
        for (var i = 0; i < registeredUsers.length; i++) {
          bool reply = await deepFaceApi.verifyFace(
              base64FileBytes, registeredUsers[i].image);
          if (reply == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: Colors.black,
                content: Text(
                  "You are already Registered!",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )));
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: ((context) => Home())));
            loading = false;
            notifyListeners();
            break;
          } else if (i + 1 == registeredUsers!.length && reply == false) {
            try {
              firebaseInstance.addUsers(userInformation);
              contractProvider.registerVoter(id!);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.black,
                  content: Text(
                    "Registered Successfully",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )));
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: ((context) => Home())));
            } on FirebaseException catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                backgroundColor: Colors.black,
                content: Text(
                  "Firebase Errors, check your internet connection",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ));
            }
          }
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
}
