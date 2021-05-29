import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp defaultApp = await Firebase.initializeApp();
  runApp(BettingBee());
}

class BettingBee extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betting Bee',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: BettingBeeLayout(title: 'Betting Bee'),
    );
  }
}

class BettingBeeLayout extends StatelessWidget {
  BettingBeeLayout({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: BettingColumn()),
          Expanded(child: ActionColumn())
        ]));
  }
}

class BettingColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(20.0),
        child: Text("Available bets",
            style: Theme.of(context).textTheme.headline6),
      ),
      Expanded(
          child: BetList(
            bets: [
              Bet(
                  betText: "BitCoin will go above \$50000",
                  betA: "Yes, above \$50000",
                  betB: "No, not above \$50000",
                  releaseTime:  DateTime.now().add(Duration(minutes: 10))
              ),
              Bet(
                  betText: "Ethereum will go above \$50000",
                  betA: "Yes, above \$50000",
                  betB: "No, not above \$50000",
                  releaseTime:  DateTime.now().add(Duration(minutes: 10))
              )
            ]

          )),
    ]);
  }
}

class BetList extends StatelessWidget {
  final List<Bet> bets;

  BetList({required this.bets});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bets.length,
      itemBuilder: (context, idx) {
        return BetWidget(bet: bets[idx]);
      }
    );
  }
}

class BetWidget extends StatelessWidget {
  final Bet bet;

  BetWidget({required this.bet});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Padding(
            padding: EdgeInsets.all(5),
            child: Text(bet.betText)),
        subtitle: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: () {},
                child: Text(bet.betA),
              )),
          Padding(
              padding: EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: () {},
                child: Text(bet.betB)
              )),
        ]));
  }



}

class ActionColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column();
  }
}
