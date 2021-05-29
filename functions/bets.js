const admin = require('firebase-admin');
const functions = require("firebase-functions");

const { TOURNAMENT_COLLECTION, USER_COLLECTION, BET_COLLECTION } = require('./collections');

async function makeBet(tournamentId, player, userId, value) {
  const firestore = admin.firestore();
  const tournament = await firestore.collection(TOURNAMENT_COLLECTION).doc(tournamentId).get();

  if (!tournament.exists()) {
    throw new functions.https.HttpsError('failed-precondition', 'Tournament does not exist');
  }

  const bet = tournament.subcollection(BET_COLLECTION).doc(`${userId}-${player}`);
  const doc = bet.get();

  if (doc.exists()) {
    throw new functions.https.HttpsError('failed-precondition', 'You have already bet for this fellow');
  }

  const betObject = {
    userId,
    player,
    value,
    tournamentId,
    status: "undetermined",
    odds: 1 + Math.round(Math.random() * 5 * 10) / 10,
  }

  const userRef = firestore.collection(USER_COLLECTION).doc(userId);

  await userRef.update("balance", firestore.FieldValue.increment(-value));
  await bet.set(betObject);

  return betObject;
}
  
  
  
  
  
