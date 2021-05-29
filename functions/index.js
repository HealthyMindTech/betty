const functions = require("firebase-functions");
const chessApi = require('./chess_api');
const chessSync = require('./chess_sync');
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const bets = require('./bets');

admin.initializeApp();
admin.firestore().settings({ ignoreUndefinedProperties: true });

const app = express();

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));
app.post('/update', async (req, res) => res.send(await updateTournaments()));

let isUpdatingNow = false;
async function updateTournaments() {
  if (isUpdatingNow) {
    console.log("Will not run as is already running");
    return;
  }
  console.log("Scheduling");
  isUpdatingNow = true;
  try {
    await chessSync.scanTournaments()
  } catch (e) {
    console.log(e);
  }
  isUpdatingNow = false;
  return null;
}

exports.makeBet = functions.https.onCall((data, context) => {
  const tournamentId = data.tournamentId;
  const player = data.player;
  const userId = context.auth.uid;
  const value = data.value || 5.0;

  if (!userId) {
    throw new functions.https.HttpsError('failed-precondition', 'You must be logged in to run this');
  }
  
  return bets.makeBet(tournamentId, player, userId, value);
});

exports.app = functions.https.onRequest(app);
exports.updateTournaments = functions.pubsub.schedule("every 1 minutes").onRun(updateTournaments);


