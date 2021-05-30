import 'dart:ui';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';
import 'tournament_service.dart';
import 'user_provider.dart';
import 'user_service.dart';
import 'utils.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return _HomeScreen(user: userProvider.getUser());
    });
  }
}

class _HomeScreen extends StatefulWidget {
  final ModelUser? user;

  _HomeScreen({this.user});

  @override
  State<_HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<_HomeScreen> {
  late UserService userService;

  @override
  void initState() {
    super.initState();
    userService = UserService.get();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = context.watch<UserProvider>();
    ModelUser? user = userProvider.getUser() ?? null;

    return Scaffold(
        appBar: AppBar(
            leading: Padding(
                padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                child: Image(image: AssetImage('assets/betty_logo.png'))),
            title: Text("Betty"),
            actions: <Widget>[
              TextButton(
                  child: Row(children: <Widget>[
                    Text(user?.balance.toString() ?? "0",
                        style: TextStyle(color: Colors.yellow.shade400)),
                    SizedBox(width: 3),
                    Icon(Icons.monetization_on, color: Colors.yellow.shade400),
                  ]),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text("Balance"),
                                  Icon(Icons.monetization_on, size: 25),
                                  Icon(Icons.monetization_on, size: 25),
                                  Icon(Icons.monetization_on, size: 25),
                                ]),
                            content: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(user?.balance.toString() ?? "0",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                      )),
                                ]),
                            actions: <Widget>[
                              // TextButton(
                              //   onPressed: () => Navigator.pop(context, 'OK'),
                              //   child: const Text('Deposit funds'),
                              // ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        });
                  }),
              Padding(
                  padding: EdgeInsets.only(right: 30),
                  child: TextButton(
                    child: Row(children: <Widget>[
                      Icon(Icons.person, color: Colors.white),
                    ]),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(Icons.person, size: 25),
                                    Text("Your profile"),
                                  ]),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(user?.displayName ?? "",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                        )),
                                    Text(user?.email ?? "",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                        )),
                                  ],
                                ),
                              ),
                              // Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: <Widget>[
                              //
                              //     ]
                              // ),
                              actions: <Widget>[
                                // TextButton(
                                //   onPressed: () => Navigator.pop(context, 'OK'),
                                //   child: const Text('Deposit funds'),
                                // ),
                                TextButton(
                                  child: Text("Sign Out"),
                                  onPressed: () {
                                    _signOut(context);
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            "/login", (route) => route.isFirst);
                                  },
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                    },
                  ))
            ]),
        body: Stack(children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: BettingColumn()),
            Expanded(child: ActionColumn())
          ]),
          Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                  "2021 \u00a9 Betty | Terms of Service | Privacy Policy | About"))
        ]));
  }

  Future<void> _signOut(BuildContext context) async {
    UserProvider userProvider = context.read<UserProvider>();
    await FirebaseAuth.instance.signOut();
    userProvider.signOutUser();
  }
}

class ActionColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(20.0),
        child:
            Text("Placed bets", style: Theme.of(context).textTheme.headline6),
      ),
      Expanded(
          child: PlacedBetList(bets: [
        UserBet(
          betText: "Will Magnus Carlsen win the FTX Crypto Cup?",
          betA: "Yes",
          betB: "No",
          tournamentId: "1",
          tournamentUrl: "",
          releaseTime: DateTime.now().add(Duration(minutes: 10)),
          betUser: "Yes",
          betOutcome: "",
          placedTime: DateTime.now().add(Duration(minutes: -5)),
        ),
        UserBet(
            betText:
                "Will Ian Nepomniachtchi win their Semifinals Series of the FTX Crypto Cup?",
            betA: "Yes",
            betB: "No",
            tournamentId: "1",
            tournamentUrl: "",
            releaseTime: DateTime.now().add(Duration(minutes: -5)),
            betUser: "Yes",
            betOutcome: "Yes",
            placedTime: DateTime.now().add(Duration(minutes: -10))),
        UserBet(
            betText:
                "Will Wesley So win their Semifinals Series of the FTX Crypto Cup?",
            betA: "Yes",
            betB: "No",
            tournamentId: "1",
            tournamentUrl: "",
            releaseTime: DateTime.now().add(Duration(minutes: -5)),
            betUser: "No",
            betOutcome: "Yes",
            placedTime: DateTime.now().add(Duration(minutes: -10)))
      ])),
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
        });
  }

  Widget slideIt(BuildContext context, int index, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: Padding(
          padding: EdgeInsets.all(10),
          child: getPlacedBetWidget(
              context, bets[index], index) //BetWidget(bet: bets[index])
          ),
    );
  }

  Widget getPlacedBetWidget(BuildContext context, UserBet bet, int index) {
    return Card(
        color: bet.releaseTime.isAfter(DateTime.now())
            ? Colors.white
            : bet.betUser == bet.betOutcome
                ? Colors.green.shade50
                : Colors.grey.shade100,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  child: Text(
                    bet.betText,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    maxLines: 5,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text("Your bet: ",
                        style: TextStyle(
                          fontSize: 16.0,
                        ))),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: bet.releaseTime
                                  .isAfter(DateTime.now())
                              ? MaterialStateProperty.all(Colors.yellow[700])
                              : bet.betUser == bet.betOutcome
                                  ? MaterialStateProperty.all(Colors.green[700])
                                  : MaterialStateProperty.all(Colors.red[700])),
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(bet.betText),
                          content: Text("Your bet: " +
                              bet.betUser +
                              "\n\nOutcome: " +
                              bet.betOutcome +
                              "\n\nPlaced at: " +
                              friendlyDateFormat.format(bet.placedTime) +
                              "\nEnds: " +
                              friendlyDateFormat.format(bet.releaseTime)),
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
                    child: Text(bet.releaseTime.isAfter(DateTime.now())
                        ? "Ends: " + friendlyDateFormat.format(bet.releaseTime)
                        : "Ended: " +
                            friendlyDateFormat.format(bet.releaseTime)))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                GestureDetector(
                    child: Text("View Details",
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      launch(bet.tournamentUrl);
                    })
              ]),
            ])));
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
      Expanded(child: BetList(tournamentService: TournamentService.instance))
    ]);
  }
}

class BetList extends StatefulWidget {
  final TournamentService tournamentService;

  BetList({required this.tournamentService});

  @override
  _BetListState createState() => _BetListState();
}

class _BetListState extends State<BetList> {
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  Map<String, int> tournamentHash = <String, int>{};
  List<Tournament> tournaments = <Tournament>[];

  @override
  void initState() {
    super.initState();
    Map<String, Tournament> allTournaments =
        widget.tournamentService.getActiveBets();
    if (allTournaments.isNotEmpty) {
      addFirstList(allTournaments);
    }
    widget.tournamentService.addListener(updateList);
  }

  void addFirstList(Map<String, Tournament> allTournaments) {
    var tournaments = allTournaments.values.toList();
    tournaments.sort((a, b) {
      var startTimeA = a.startTime;
      var startTimeB = b.startTime;
      if (startTimeA == null && startTimeB == null) {
        return 0;
      }
      if (startTimeA == null) {
        return -1;
      }
      if (startTimeB == null) {
        return 1;
      }
      return startTimeA.compareTo(startTimeB);
    });
    tournamentHash = <String, int>{};
    for (var i = 0; i < tournaments.length; i++) {
      tournamentHash[tournaments[i].id] = i;
      listKey.currentState?.insertItem(i);
    }
  }

  @override
  void didUpdateWidget(BetList oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateList();
  }

  void updateList() {
    setState(() {
      Map<String, Tournament> newTournaments =
          widget.tournamentService.getActiveBets();
      if (newTournaments.isEmpty) {
        addFirstList(newTournaments);
        return;
      }
      newTournaments.keys.forEach((k) {
        if (!tournamentHash.containsKey(k)) {
          tournaments.add(newTournaments[k]!);
          listKey.currentState?.insertItem(tournaments.length - 1);
          tournamentHash[k] = tournaments.length - 1;
        }
      });
      tournamentHash.keys.toList().forEach((k) {
        if (!newTournaments.containsKey(k)) {
          var idx = tournamentHash[k]!;
          var tournament = tournaments[idx];
          tournaments.removeAt(idx);
          tournamentHash.remove(k);
          var widget = getBetWidget(context, tournament, idx);
          listKey.currentState?.removeItem(idx, (context, animation) => widget);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.tournamentService.removeListener(updateList);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
        key: listKey,
        initialItemCount: tournaments.length,
        itemBuilder: (context, idx, animation) {
          return slideIt(context, idx, animation);
        });
  }

  Widget slideIt(BuildContext context, int index, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: Padding(
          padding: EdgeInsets.all(10),
          child: getBetWidget(
              context, tournaments[index], index) //BetWidget(bet: bets[index])
          ),
    );
  }

  Widget getBetWidget(BuildContext context, Tournament tournament, int index) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  child: Text(
                    "Bet on who will win: ${tournament.name}",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                    maxLines: 5,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              Table(
                  border: TableBorder.symmetric(
                    inside: BorderSide(width: 0.2),
                  ),
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: tournament.players?.map((player) {
                        return TableRow(children: [
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("Will $player win?")),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: ElevatedButton(
                                onPressed: () async {
                                  var res = await FirebaseFunctions.instance.httpsCallable("makeBet").call(
                                    [tournament.id, player]
                                  );
                                  print(res);
                                  /*listKey.currentState?.removeItem(
                                index, (_, animation) => slideIt(context, index, animation),
                                duration: const Duration(milliseconds: 500));
                            widget.tournamentService.removeAt(index); */
                                },
                                child: Text("Bet on $player"),
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.blue)),
                              ))
                        ]);
                      }).toList() ??
                      []),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text("Tournament starts: " +
                        friendlyDateFormat
                            .format(tournament.startTime ?? DateTime.now())))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                GestureDetector(
                    child: Text("View Details",
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      String? resultUrl = tournament.resultUrl;
                      if (resultUrl != null) {
                        launch(resultUrl);
                      }
                    })
              ]),
            ])));
  }
}
