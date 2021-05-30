import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'user_service.dart';

class UserProvider extends ValueNotifier<ModelUser?> {
  UserService _userService = UserService.get();
  StreamSubscription<DocumentSnapshot<Object?>>? subscription;

  static UserProvider? _instance;
  static UserProvider get instance {
    if (_instance == null) {
      _instance = UserProvider();
    }
    return _instance!;
  }
  UserProvider(): super(null);

  Future<ModelUser> getOrCreateUser(User user) async {
    ModelUser u = await _userService.getOrCreateUser(user);
    subscription?.cancel();
    subscription = _userService.getUserStream(user.uid).listen((event) {
      Map<String, dynamic> data = event.data() as Map<String, dynamic>;
      updateUser(ModelUser.fromMap(data));
    });
    value = u;
    return u;
  }

  void updateUser(ModelUser user) {
    value = user;
  }

  void signOutUser() {
    subscription?.cancel();
    value = null;
  }

  ModelUser? getUser() {
    return value;
  }
}