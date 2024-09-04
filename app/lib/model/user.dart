import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part "user.g.dart";

@JsonSerializable(explicitToJson: true)
class User {
  User(
      {required this.image,
      required this.email,
      required this.name,
      required this.id});

  String email;
  String image;
  String name;
  String id;
  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  //   factory BeaconModel.fromSnapShot(
  //     DocumentSnapshot<Map<String, dynamic>> document) {
  //   final data = document.data();
  //   return BeaconModel(
  //       proximityUUID: data!["proximityUUID"],
  //       major: data["major"],
  //       minor: data["minor"],
  //       accuracy: data["accuracy"],
  //       macAddress: data["macAddress"],
  //       id: document.id,
  //       rssi: data["rssi"],
  //       proximity: data["proximity"],
  //       txPower: data["txPower"]);
  // }

  factory User.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return User(
      image: data!["Image"],
      email: data["Email"],
      name: data['Name'],
      id: data["Id"],
    );
  }
}
