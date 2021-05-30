import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'user_service.dart';

class UserProvider extends ValueNotifier<ModelUser?> {
  UserService _userService = UserService.get();

  UserProvider(): super(null);

  Future<ModelUser> getOrCreateUser(User user) async {
    ModelUser u = await _userService.getOrCreateUser(user);
    value = u;
    return u;
  }

  void updateUser(ModelUser user) {
    value = user;
  }

  void signOutUser() {
    value = null;
  }

  ModelUser? getUser() {
    return value;
  }
}