import 'package:cloud_firestore/cloud_firestore.dart';

class Bet {
  final String betText;
  final String betA;
  final String betB;
  final String tournamentId;
  final String tournamentUrl;

  final DateTime releaseTime;

  const Bet(
      {required this.betText,
      required this.betA,
      required this.betB,
      required this.releaseTime,
      required this.tournamentId,
      required this.tournamentUrl,
      });
}

class Tournament {
  final String id;
  final String? name;
  final String? liveUrl;
  final String? resultUrl;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String>? players;

  const Tournament(
      {
        required this.id,
        required this.status,
        this.name,
        this.liveUrl,
        this.resultUrl,
        this.startTime,
        this.endTime,
        this.players});

  static Tournament? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    var id = doc.id;
    var data = doc.data();
    if (data == null) {
      return null;
    }
    var name = data["name"];
    var liveUrl = data["liveUrl"];
    var resultUrl = data["resultUrl"];
    var status = data["status"];
    var startTimeMillis = data["startTime"];
    var startTime = startTimeMillis != null ? DateTime.fromMillisecondsSinceEpoch(startTimeMillis) : null;

    var endTimeMillis = data["endTime"];
    var endTime = endTimeMillis != null ? DateTime.fromMillisecondsSinceEpoch(endTimeMillis) : null;
    var players = data["players"];

    return Tournament(
      id: id,
      status: status as String,
      liveUrl: liveUrl,
      resultUrl: resultUrl,
      startTime: startTime,
      endTime: endTime,
      players: players
    );
  }
}

class Event {
  final String id;
  final String name;
  final String url;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> entities;

  const Event(
      {required this.id,
        required this.name,
        required this.url,
        required this.status,
        required this.startTime,
        required this.endTime,
        required this.entities});
}

class UserBet {
  final String betText;
  final String betA;
  final String betB;
  final String tournamentId;
  final String tournamentUrl;
  final DateTime releaseTime;

  final String betUser;
  final String betOutcome;
  final DateTime placedTime;

  const UserBet(
      {required this.betText,
        required this.betA,
        required this.betB,
        required this.tournamentId,
        required this.tournamentUrl,
        required this.releaseTime,
        required this.betUser,
        required this.betOutcome,
        required this.placedTime});
}

class ModelUser {
  String? id;
  String? profileImageUrl;
  String? email;
  String? displayName;
  DateTime? createdAt;
  List<String>? betsIds;
  num? balance;

  ModelUser(
      {this.id,
        this.profileImageUrl,
        this.email,
        this.displayName,
        this.createdAt,
        this.betsIds,
        this.balance,
      });

    Map<String, dynamic> toMap() {
      return {
        "id": id,
        "profileImageUrl": profileImageUrl,
        "email": email,
        "displayName": displayName,
        "createdAt": createdAt ?? DateTime.now(),
        "balance": balance,
      };
    }

    ModelUser.fromMap(Map<String, dynamic> map) {
      id = map["id"];
      profileImageUrl = map["profileImageUrl"];
      email = map["email"];
      displayName = map["displayName"];
      createdAt = (map["createdAt"] as Timestamp?)?.toDate();
      balance = map["balance"];
  }
}