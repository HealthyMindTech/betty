import 'dart:html';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp defaultApp = await Firebase.initializeApp();
  runApp(BettingBee());
}

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

class BettingBee extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betty',
      theme: ThemeData(
        primarySwatch: materialBlack,
      ),
      home: BettingBeeLayout(title: 'Betty'),
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
        body: Stack(
            children : <Widget> [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: BettingColumn()),
                Expanded(child: ActionColumn())
              ]),
              Positioned(
                bottom : 20,
                left: 20,
                child: Text("2021 \u00a9 Betty | Terms of Service | Privacy Policy | About")
              )]
    ));
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
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  BetList({required this.bets});

  @override
  Widget build(BuildContext context) {

    return AnimatedList(
      key: listKey,
      initialItemCount: bets.length,
      itemBuilder: (context, idx, animation) {
        return slideIt(context, idx, animation);
      }
    );
  }

  Widget slideIt(BuildContext context, int index, animation) {
    TextStyle? textStyle = Theme.of(context).textTheme.headline4;
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getBetWidget(context, bets[index], index) //BetWidget(bet: bets[index])
      ),
    );
  }

  Widget getBetWidget(BuildContext context, Bet bet, int index) {
    return Card(
        child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            children : <Widget> [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  child: Text(bet.betText,
                    style: TextStyle(fontSize: 18.0,),
                    maxLines: 5,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        listKey.currentState?.removeItem(
                            index, (_, animation) => slideIt(context, index, animation),
                            duration: const Duration(milliseconds: 500));
                        bets.removeAt(index);
                      },
                      child: Text(bet.betA),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blue)),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10),
                  child: ElevatedButton(
                      onPressed: () {},
                      child: Text(bet.betB),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue)),
                  ),
                )]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text("Ends: " + friendlyDateFormat.format(bet.releaseTime)))
              ]),
            ])));
  }

}

class ActionColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(20.0),
        child: Text("Placed bets",
            style: Theme.of(context).textTheme.headline6),
      ),
      Expanded(
          child: PlacedBetList(
              bets: [
                UserBet(
                    betText: "Will the Bongcloud be played during the FTX Crypto Cup?",
                    betA: "Yes",
                    betB: "No",
                    releaseTime:  DateTime.now().add(Duration(minutes:10)),
                    betUser: "Yes",
                    betOutcome: "",
                    placedTime: DateTime.now().add(Duration(minutes:-5))
                ),
                UserBet(
                    betText: "Will Magnus Carlsen win the FTX Crypto Cup?",
                    betA: "Yes",
                    betB: "No",
                    releaseTime:  DateTime.now().add(Duration(minutes:-5)),
                    betUser: "Yes",
                    betOutcome: "Yes",
                    placedTime: DateTime.now().add(Duration(minutes:-10))
                ),
                UserBet(
                    betText: "Will Ian Nepomniachtchi or Wesley So win their Semifinals Series of the FTX Crypto Cup?",
                    betA: "Yes",
                    betB: "No",
                    releaseTime:  DateTime.now().add(Duration(minutes:-5)),
                    betUser: "No",
                    betOutcome: "Yes",
                    placedTime: DateTime.now().add(Duration(minutes:-10))
                )
              ]
          )),
    ]);
  }
}


class PlacedBetList extends StatelessWidget {
  final List<UserBet> bets;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  PlacedBetList({required this.bets});

  @override
  Widget build(BuildContext context) {

    return AnimatedList(
        key: listKey,
        initialItemCount: bets.length,
        itemBuilder: (context, idx, animation) {
          return slideIt(context, idx, animation);
        }
    );
  }

  Widget slideIt(BuildContext context, int index, animation) {
    TextStyle? textStyle = Theme.of(context).textTheme.headline4;
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: Padding(
          padding: EdgeInsets.all(10),
          child: getPlacedBetWidget(context, bets[index], index) //BetWidget(bet: bets[index])
      ),
    );
  }

  Widget getPlacedBetWidget(BuildContext context, UserBet bet, int index) {
    return Card(
        color:
        bet.releaseTime.isAfter(DateTime.now()) ?
          Colors.white :
          bet.betUser == bet.betOutcome ?
            Colors.green.shade50 :
              Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children : <Widget> [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  child: Text(bet.betText,
                    style: TextStyle(fontSize: 18.0,),
                    maxLines: 5,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(padding: EdgeInsets.only(top: 10),
                    child: Text("Your bet: ", style: TextStyle(fontSize: 16.0,))),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          bet.releaseTime.isAfter(DateTime.now()) ?
                          MaterialStateProperty.all(Colors.yellow[700]) :
                          bet.betUser == bet.betOutcome ?
                          MaterialStateProperty.all(Colors.green[700]) :
                          MaterialStateProperty.all(Colors.red[700])
                      ),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text(bet.betText),
                            content: Text(
                                "Your bet: " + bet.betUser +
                                "\n\nOutcome: " + bet.betOutcome +
                                "\n\nPlaced at: " + friendlyDateFormat.format(bet.placedTime) +
                                "\nEnds: " + friendlyDateFormat.format(bet.releaseTime)
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ),
                      child: Text(bet.betUser),
                    )),
                ]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                        bet.releaseTime.isAfter(DateTime.now()) ?
                        "Ends: " + friendlyDateFormat.format(bet.releaseTime) :
                            "Ended: " + friendlyDateFormat.format(bet.releaseTime)
                            ))
              ]),
            ])));
  }

}