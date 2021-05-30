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
app.post('/cleanBets', async (req, res) => res.send(await bets.cleanBets()));

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

exports.makeBet = functions.runWith({
  timeoutSeconds: 300
}).https.onCall(async (data, context) => {
  console.log(data);
  const tournamentId = data[0]
  const player = data[1];
  const userId = context.auth.uid;
  const value = data[2] || 5.0;

  if (!userId) {
    throw new functions.https.HttpsError('failed-precondition', 'You must be logged in to run this');
  }
  
  return await bets.makeBet(tournamentId, player, userId, value);
});

exports.cleanBets = functions.runWith({
  timeoutSeconds: 300
}).pubsub.schedule("every 1 minute").onRun(bets.cleanBets);
exports.app = functions.runWith({
  timeoutSeconds: 300
}).https.onRequest(app);
exports.updateTournaments = functions.runWith({
  timeoutSeconds: 300
}).pubsub.schedule("every 1 minutes").onRun(updateTournaments);


