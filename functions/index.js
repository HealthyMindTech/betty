const functions = require("firebase-functions");
const chessApi = require('./chess_api');
const chessSync = require('./chess_sync');
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

admin.initializeApp();
admin.firestore().settings({ ignoreUndefinedProperties: true });

const app = express();

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));
app.get('/', async (req, res) => res.send());

let isUpdatingNow = false;
exports.bets = functions.pubsub.schedule("every 1 minutes").onRun(() => {
  if (isUpdatingNow) {
    console.log("Not running as is already running");
    return;
  }
  console.log("Scheduling");
  isUpdatingNow = true;
  try {
    chessSync.scanTournaments()
  } catch (e) {
    console.log(e);
  }
  isUpdatingNow = false;
  return null;
});
