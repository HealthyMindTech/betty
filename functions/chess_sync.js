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

  const totalRounds = tournamentDetails.settings.total_rounds;
  let players, playerScores;
  
  try {
    tournamentPlayers = await chessApi.lookupTournamentRound(tournamentId, totalRounds);
    players = tournamentPlayers.players.map(player => player.username);
    playerScores = tournamentPlayers.players.map(player => player.points);
  } catch (e) {
    console.log(e);
  }
  console.log(players);
  if (players === null || players === undefined || players.length === 0) {
    try {
      tournamentPlayers = await chessApi.lookupTournamentRound(tournamentId, 1);
      players = tournamentPlayers.players.map(player => player.username);
      playerScores = tournamentPlayers.players.map(player => player.points);
    } catch (e) {
      console.log(e);
    }
  }
  console.log(players);

  if (players === null || players === undefined || players.length === 0) {
    try {
      tournamentPlayers = await chessApi.lookupTournamentRound(tournamentId, 0);
      players = tournamentPlayers.players.map(player => player.username);
      playerScores = tournamentPlayers.players.map(player => player.points);
    } catch (e) {
      console.log(e);
    }
  }
  console.log(players);

  if (players === null || players === undefined || players.length === 0) {
    players = tournamentDetails.players.filter(
      player => player.status != "withdrew" && player.status != "removed"
    ).map(player => player.username);
    playerScores = players.map(_ => 0);
  }

  const status = tournamentDetails.status;
  if ((players === null || players === undefined || players.length === 0) &&
      status != "finished") {
    return;
  }
  
  const winners = tournamentDetails.players.filter(
    player => player.status === "winner"
  ).map(player => player.username);
  
  const doc = firestore.collection(TOURNAMENT_COLLECTION).doc(tournamentId);
  
  const startTime = tournamentDetails.start_time;
  const endTime = tournamentDetails.end_time;
  let resultUrl = tournamentDetails.url;
  const name = tournamentDetails.name;
  
  const tournamentObject = {
    startTime,
    endTime,
    name,
    status,
    players,
    playerScores,
    resultUrl,
    winners
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
    console.log(`Looking at: ${doc.id}`);
    await createOrUpdateTournament(doc.id);
  }
}

async function scanTournaments() {
  const ignoreIds = await registerNewTournaments();
  await updateUnfinishedTournaments(ignoreIds);
}

exports.scanTournaments = scanTournaments;
exports.registerNewTournaments = registerNewTournaments;
