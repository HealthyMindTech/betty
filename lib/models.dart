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
  final String name;
  final String url;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> players;

  const Tournament(
      {
        required this.id,
        required this.name,
        required this.url,
        required this.status,
        required this.startTime,
        required this.endTime,
        required this.players});
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
