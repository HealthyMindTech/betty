class Bet {
  final String betText;
  final String betA;
  final String betB;

  final DateTime releaseTime;

  const Bet(
      {required this.betText,
      required this.betA,
      required this.betB,
      required this.releaseTime});
}

class UserBet {
  final String betText;
  final String betA;
  final String betB;
  final DateTime releaseTime;

  final String betUser;
  final String betOutcome;
  final DateTime placedTime;

  const UserBet(
      {required this.betText,
        required this.betA,
        required this.betB,
        required this.releaseTime,
        required this.betUser,
        required this.betOutcome,
        required this.placedTime});
}
