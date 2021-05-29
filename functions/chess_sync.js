admin = require('firebase-admin');
chessApi = require("./chess_api");

TOURNAMENT_COLLECTION = "tournament";

async function registerNewTournaments() {
  const firestore = admin.firestore();
  firestore.settings({ ignoreUndefinedProperties: true });
  
  const res = [];
  for await (const tournament of chessApi.getUpcomingTournaments()) {
    const tournamentId = chessApi.getTournamentId(tournament);
    let tournamentDetails;
    try {
      tournamentDetails = await chessApi.lookupTournament(tournamentId);
    } catch (e) {
      console.log(e);
      continue;
    }

    res.push(tournamentId);
    
    const doc = firestore.collection(TOURNAMENT_COLLECTION).doc(tournamentId);
    console.log(tournamentDetails);
    const players = tournamentDetails.players.filter(
      player => player.status === 'registered' ||  player.status === 'winner'
    ).map(player => player.username);

    const startTime = tournamentDetails.start_time;
    const endTime = tournamentDetails.end_time;
    const url = tournamentDetails.url;
    const name = tournamentDetails.name;
    const status = tournamentDetails.status;
    
    const tournamentObject = {
      startTime,
      endTime,
      url,
      name,
      status,
      players
    };

    doc.set(tournamentObject);
  }
  return res;
}

exports.registerNewTournaments = registerNewTournaments;
