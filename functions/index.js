const functions = require("firebase-functions");
const chessApi = require('./chess_api');
const chessSync = require('./chess_sync');
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

admin.initializeApp();
const app = express();

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));
app.get('/', async (req, res) => res.send(chessSync.registerNewTournaments()));

// Expose Express API as a single Cloud Function:
exports.bets = functions.https.onRequest(app);

        // // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
