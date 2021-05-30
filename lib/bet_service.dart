import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class BetService extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, Bet> bets = {};
  String userId;

  BetService({required this.userId}) {
    listenForUser(userId);
  }

  void listenForUser(String userId) {
    firestore.collectionGroup("bets").where(
      "userId", isEqualTo: userId
    ).where(
      "visible", isEqualTo: true
    ).snapshots().forEach((event) async {
      print("Got event");
      var events = event.docChanges.map((change) async {
        var bet = await Bet.fromDocument(change.doc);

        if (bet == null) {
          return null;
        }
        bets[bet.id] = bet;
        return null;
      });
      await Future.wait(events);
      print("my bets: $bets");
      notifyListeners();
    });
  }

  Map<String, Bet> getMyBets() {
    return bets;
  }
}