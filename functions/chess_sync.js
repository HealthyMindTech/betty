admin = require('firebase-admin');
chessApi = require("./chess_api");

TOURNAMENT_COLLECTION = "tournament";

async function createOrUpdateTournament(tournamentId) {
  firestore = admin.firestore();
  let tournamentDetails, tournamentPlayers = null;
  try {
    tournamentDetails = await chessApi.lookupTournament(tournamentId);
  } catch (e) {
    console.log(e);
    return;
  }

  let players, playerScores;
  try {
    tournamentPlayers = await chessApi.lookupTournamentRound(tournamentId, 0);
    players = tournamentPlayers.players.map(player => player.username);
    playerScores = tournamentPlayers.players.map(player => player.points);
  } catch (e) {
    console.log(e);
    players = tournamentDetails.players.map(player => player.username);
    playerScores = players.map(_ => 0);
  }

  
  const doc = firestore.collection(TOURNAMENT_COLLECTION).doc(tournamentId);
  
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
    players,
    playerScores
  };
  
  doc.set(tournamentObject);
}

async function registerNewTournaments() {
  const firestore = admin.firestore();
  const res = [];
  for await (const tournament of chessApi.getUpcomingTournaments()) {
    const tournamentId = chessApi.getTournamentId(tournament);
    await createOrUpdateTournament(tournamentId);
    res.push(tournamentId);
  }
  return res;
}

async function updateUnfinishedTournaments(ignoredIds) {
  const firestore = admin.firestore();
  const docs = await firestore.collection(TOURNAMENT_COLLECTION).where("status", "in", [
    "scheduled", "registration", "in_progress"
  ]).get();
  const ignoredDocs = ignoredIds ? new Set(ignoredIds) : new Set();
  for (var doc of docs.docs) {
    console.log(doc.id);
    if (ignoredDocs.has(doc.id)) {
      continue;
    }
    await createOrUpdateTournament(doc.id);
  }
}

async function scanTournaments() {
  const ignoreIds = await registerNewTournaments();
  await updateUnfinishedTournaments(ignoreIds);
}

exports.scanTournaments = scanTournaments;
exports.registerNewTournaments = registerNewTournaments;
