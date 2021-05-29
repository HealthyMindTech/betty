import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'user_service.dart';

class UserProvider extends ChangeNotifier {
  UserService _userService = UserService.get();
  ModelUser? user;

  Future<ModelUser> getOrCreateUser(User user) async {
    ModelUser u = await _userService.getOrCreateUser(user);
    this.user = u;
    return u;
  }

  void updateUser(ModelUser user) {
    this.user = user;
    notifyListeners();
  }

  void signOutUser() {
    ModelUser? user = this.user;
    this.user = null;
    notifyListeners();
  }

  ModelUser? getUser() {
    return user;
  }
}