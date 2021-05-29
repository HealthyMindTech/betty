import 'models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TournamentService extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Map<String, Tournament> _cache = <String, Tournament>{};
  static TournamentService? _instance;
  static TournamentService get instance {
    if (_instance == null) {
      _instance = TournamentService();
    }
    return _instance!;
  }

  TournamentService();

  Future<Map<String, Tournament>> lookupTournaments(List<String> tournamentIds) async {
    var futureTournaments = tournamentIds.map((id) async {
      var tournament = _cache[id];
      if (tournament == null) {
        var doc = firestore.collection("tournament").doc(id);
        var tournamentData = await doc.get();
        tournament = _registerTournament(tournamentData);
      }
      return tournament;
    });

    var tournaments = await Future.wait(futureTournaments);
    Map<String, Tournament> result = <String, Tournament>{};

    tournaments.forEach((tournament) {
      if (tournament == null) {
        return;
      }
      result[tournament.id] = tournament;
    });
    return result;
  }

  Tournament? _registerTournament(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Tournament? tournament = Tournament.fromDoc(doc);
      if (tournament == null)
        return null;
      _cache[doc.id] = tournament;
      return tournament;
    } catch (e) {
      print(e);
    }
    return null;
  }

  void setup() async {
    firestore.collection("tournament").where(
        "status", whereIn: [
      "scheduled", "registration", "in_progress"
    ]).snapshots().forEach(
            (event) {
              event.docChanges.forEach((change) {
                  var doc = change.doc;
                  _registerTournament(doc);
              });
              notifyListeners();
            });
  }
}