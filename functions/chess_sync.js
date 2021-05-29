const admin = require('firebase-admin');
const chessApi = require("./chess_api");
const { TOURNAMENT_COLLECTION } = require('./collections');

async function createOrUpdateTournament(tournamentId, idNumber) {
  firestore = admin.firestore();
  let tournamentDetails, tournamentPlayers = null;
  console.log(`Updating ${tournamentId}`);
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
  }

  if (players === null || players.length === 0) {
    players = tournamentDetails.players.map(player => player.username);
    playerScores = players.map(_ => 0);
  }
  console.log(players);

  const doc = firestore.collection(TOURNAMENT_COLLECTION).doc(tournamentId);
  
  const startTime = tournamentDetails.start_time;
  const endTime = tournamentDetails.end_time;
  let resultUrl = tournamentDetails.url;
  resultUrl = resultUrl ? resultUrl.replace(/live\/([^\/]+)$/, "live/arena/$1") : resultUrl;
  const name = tournamentDetails.name;
  const status = tournamentDetails.status;

  
  const tournamentObject = {
    startTime,
    endTime,
    name,
    status,
    players,
    playerScores,
    resultUrl
  };
  if (idNumber) {
    tournamentObject["liveUrl"] = `https://www.chess.com/live#r=${idNumber}`;
  }
  doc.set(tournamentObject, { merge: true });
}

async function registerNewTournaments() {
  const firestore = admin.firestore();
  const res = [];
  for await (const tournament of chessApi.getUpcomingTournaments()) {
    const tournamentId = chessApi.getTournamentId(tournament);
    await createOrUpdateTournament(tournamentId, tournament.id);
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
