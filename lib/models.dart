import 'package:bettingbee/tournament_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Bet {
  String id;
  String userId;
  String player;
  String tournamentId;
  bool visible;
  num odds;
  String status;
  num value;
  Tournament tournament;

  Bet({
    required this.id,
    required this.userId,
    required this.player,
    required this.tournamentId,
    required this.visible,
    required this.odds,
    required this.status,
    required this.value,
    required this.tournament
  });

  static Future<Bet?> fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) async {
    var id = doc.id;
    var tournamentDoc = doc.reference.parent.parent!;
    var tournamentMap = await TournamentService.instance.lookupTournaments([tournamentDoc.id]);
    var tournament = tournamentMap[tournamentDoc.id]!;
    var data = doc.data();
    if (data == null) {
      return null;
    }
    var visible = data["visible"] ?? true;
    var odds = data["odds"] ?? 3;
    var status = data["status"] ?? "undetermined";
    var value = data["value"] ?? 5;
    var player = data["player"]!;
    var userId = data["userId"]!;
    return Bet(
        userId: userId,
        player: player,
        tournament: tournament,
        tournamentId: tournament.id,
        visible: visible,
        odds: odds,
        status: status,
        value: value,
        id: id
    );
  }
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
  final List<String>? winners;

  const Tournament(
      {
        required this.id,
        required this.status,
        this.name,
        this.liveUrl,
        this.resultUrl,
        this.startTime,
        this.endTime,
        this.winners,
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
    var startTime = startTimeMillis != null ? DateTime.fromMillisecondsSinceEpoch(startTimeMillis * 1000) : null;

    var endTimeMillis = data["endTime"];
    var endTime = endTimeMillis != null ? DateTime.fromMillisecondsSinceEpoch(endTimeMillis * 1000) : null;
    var players = (data["players"] as List<dynamic>?)?.whereType<String>().toList();
    var winners = (data["winners"] as List<dynamic>?)?.whereType<String>().toList();

    return Tournament(
      id: id,
      name: name,
      status: status as String,
      liveUrl: liveUrl,
      resultUrl: resultUrl,
      startTime: startTime,
      endTime: endTime,
      players: players,
      winners: winners
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