import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';

const MaterialColor materialBlack = MaterialColor(
  0xFF000000,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(0xFF000000),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);

var friendlyDateFormat = DateFormat('dd-MM-yyyy, kk:mm');

var exampleModelUser = ModelUser(
    id: "1",
    displayName: "Paula",
    createdAt: DateTime.now(),
    balance: 100
);