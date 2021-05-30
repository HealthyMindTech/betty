import 'dart:math';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference users = FirebaseFirestore.instance.collection("users");

  static UserService? _userService;

  static UserService get() {
    UserService? userService = _userService;
    if (userService == null) {
      _userService = userService = UserService();
    }
    return userService;
  }

  static List<String> randInitialDisplayNames = [
    "Beth",
    "Betty",
    "Bet",
  ];

  static num defaultBalance = 100.0;

  Future<ModelUser> getOrCreateUser(User user) async {
    DocumentReference userDoc = users.doc(user.uid);
    DocumentSnapshot userDocSnapshot = await userDoc.get();

    if (userDocSnapshot.exists) {
      var data = userDocSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        ModelUser user = ModelUser.fromMap(data);
        return user;
      }
    }
    ModelUser modelUser = ModelUser(
        id: user.uid,
        email: user.email,
        displayName: getRandDisplayName(),
        balance: defaultBalance,
        createdAt: DateTime.now(),
        );
    Map<String, dynamic> userData = modelUser.toMap();
    await userDoc.set(userData);
    return modelUser;
  }

  Future<ModelUser?> getUserById(String userid) async {
    DocumentReference userDoc = users.doc(userid);
    DocumentSnapshot userDocSnapshot = await userDoc.get();
    if (userDocSnapshot.exists) {
      var data = userDocSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        return ModelUser.fromMap(data);
      }
    }
    return null;
  }

  static String getRandDisplayName() {
    return (randInitialDisplayNames[
    Random().nextInt(randInitialDisplayNames.length)] +
        (Random().nextInt(8999) + 1000).toString());
  }

}