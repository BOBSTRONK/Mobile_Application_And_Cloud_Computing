import 'package:app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMethods {
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  Future<void> addUsers(Map<String, String> userInfo) async {
    await users.add(userInfo);
    return;
  }

  Future<List<User>> getUsersFromFirestore() async {
    final snapshot = await users.get();
    // final beaconList =
    //     snapshot.docs.map((e) => BeaconModel.fromSnapShot(e)).toList();
    final userList = snapshot.docs
        .map((e) =>
            User.fromSnapShot(e as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
    return userList;
  }

  Future<User> getSpecificUserById(String userId) async {
    final snapshot = await users.where("Id", isEqualTo: userId).get();
    final userData = snapshot.docs
        .map((e) =>
            User.fromSnapShot(e as DocumentSnapshot<Map<String, dynamic>>))
        .toList();

    print(userData);
    return userData[0];
  }
}
