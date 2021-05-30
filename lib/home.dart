import 'dart:ui';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bet_service.dart';
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
        ]),
      bottomNavigationBar: new Container(
        alignment: Alignment.center,
        height: 40.0,
        child: Text("2021 \u00a9 Betty | Terms of Service | Privacy Policy | About",
            style: TextStyle(color: Colors.grey)
        ),
      )
    );
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
          child: PlacedBetList(),
      )]);
  }
}

class PlacedBetList extends StatefulWidget {

  PlacedBetList();

  @override
  _PlacedBetListState createState() => _PlacedBetListState();
}

class _PlacedBetListState extends State<PlacedBetList> {
  List<Bet> bets = [];
  late BetService betService;

  @override
  void initState() {
    super.initState();
    betService = BetService(userId: FirebaseAuth.instance.currentUser!.uid);
    bets = betService.getMyBets().values.toList();
    betService.addListener(updateBets);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    betService.removeListener(updateBets);
    betService = BetService(userId: FirebaseAuth.instance.currentUser!.uid);
    bets = betService.getMyBets().values.toList();
    betService.addListener(updateBets);
  }

  void updateBets() {
    setState(() {
      this.bets = betService.getMyBets().values.toList();
      print("My bets: ${bets}");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (bets.isEmpty) {
      return Container();
    }
    print("The bets are: ${bets}");
    return SingleChildScrollView(
        child: Column(
            children: bets.map((b) =>
                Padding(
                    padding: EdgeInsets.all(10),
                    child: getPlacedBetWidget(context, b))).toList()
        ));
  }

  Widget getPlacedBetWidget(BuildContext context, Bet bet) {
    var betText = "Bet on tournament ${bet.tournament.name}";
    return Card(
        color: bet.status == "undetermined"
            ? Colors.white :
        bet.status == "won" ? Colors.green.shade50
            : Colors.grey.shade100,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(
                  child: Text(
                    betText,
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
                          backgroundColor: bet.status == "undetermined"
                              ? MaterialStateProperty.all(Colors.yellow[700])
                              : bet.status == "won"
                                  ? MaterialStateProperty.all(Colors.green[700])
                                  : MaterialStateProperty.all(Colors.red[700])),
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          var winners = bet.tournament.winners ?? [];
                          return AlertDialog(
                              title: Text(betText),
                              content:
                              SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text("You bet: ${bet.player}"), //\n\nOutcome: ${winners.join(", ")}"),
                                    SizedBox(height: 20),
                                    Text(bet.status == "undetermined" ?
                                    "Status: Bet is still on. Hang in there..."
                                        : "Status: Bet has ended"),
                                    SizedBox(height: 20),
                                    bet.status == "undetermined"
                                        ? Image.asset(
                                      "assets/cat_waiting.gif",
                                      height: 125.0,
                                      width: 125.0,
                                    )
                                        : bet.status == "won" ? Image.asset(
                                      "assets/cat_won.gif",
                                      height: 125.0,
                                      width: 125.0,
                                    ) :
                                    Image.asset(
                                      "assets/cat_lost.gif",
                                      height: 125.0,
                                      width: 125.0,
                                    )
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text('OK'),
                                ),
                              ],
                          );
                        },
                      ),
                      child: Text(bet.player),
                    )),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(bet.status == "undetermined" ?
                        "Bet is still on. Tournament starts: " + friendlyDateFormat
                            .format(bet.tournament.startTime ?? DateTime.now())
                        : "Bet has ended")),
              ]),

              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                GestureDetector(
                    child: Text("View Details",
                        style: TextStyle(color: Colors.blue)),
                    onTap: () {
                      var resultUrl = bet.tournament.liveUrl;
                      if (resultUrl != null) {
                        launch(resultUrl);
                      }
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
    tournaments = allTournaments.values.toList();
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
      if (tournaments.isEmpty) {
        addFirstList(newTournaments);
        return;
      }
      newTournaments.keys.forEach((k) {
        if (!tournamentHash.containsKey(k)) {
          tournaments.add(newTournaments[k]!);
          tournamentHash[k] = tournaments.length - 1;
        }
      });
      tournamentHash.keys.toList().forEach((k) {
        if (!newTournaments.containsKey(k)) {
          var idx = tournamentHash[k]!;
          tournaments.removeAt(idx);
          tournamentHash.remove(k);
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
    if (tournaments.isEmpty) {
      return Container();
    }
    return SingleChildScrollView(
      child: Column(
        children: tournaments.map((t) =>
            Padding(
                padding: EdgeInsets.all(10),
                child: getBetWidget(context, t))).toList()
    ));
  }

  Widget getBetWidget(BuildContext context, Tournament tournament) {
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
                      String? resultUrl = tournament.liveUrl;
                      if (resultUrl != null) {
                        launch(resultUrl);
                      }
                    })
              ]),
            ])));
  }
}
