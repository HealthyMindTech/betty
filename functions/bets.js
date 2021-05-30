const admin = require('firebase-admin');
const functions = require("firebase-functions");

const { TOURNAMENT_COLLECTION, USER_COLLECTION, BET_COLLECTION } = require('./collections');

async function makeBet(tournamentId, player, userId, value) {
  const firestore = admin.firestore();
  console.log(tournamentId);
  const tournamentDoc = firestore.collection(TOURNAMENT_COLLECTION).doc(tournamentId);
  const tournament = await tournamentDoc.get();
  
  if (!tournament.exists) {
    throw new functions.https.HttpsError('failed-precondition', 'Tournament does not exist');
  }

  const bet = tournamentDoc.collection(BET_COLLECTION).doc(`${userId}-${player}`);
  const doc = bet.get();

  if (doc.exists) {
    throw new functions.https.HttpsError('failed-precondition', 'You have already bet for this fellow');
  }

  const betObject = {
    userId,
    player,
    value,
    tournamentId,
    status: "undetermined",
    visible: true,
    odds: 1 + Math.round(Math.random() * 5 * 10) / 10,
  }

  const userRef = firestore.collection(USER_COLLECTION).doc(userId);
  await userRef.update({
    balance: admin.firestore.FieldValue.increment(-value)
  });
  await bet.set(betObject);

  return betObject;
}

async function cleanBets() {
  const firestore = admin.firestore();

  const unfinishedBets = await firestore.collectionGroup(BET_COLLECTION).where(
    "status", "==", "undetermined"
  ).get();

  console.log(unfinishedBets.docs);
  unfinishedBets.docs.forEach(async (bet) => {
    const tournamentDoc = bet.ref.parent.parent;
    const tournament = await tournamentDoc.get();

    const tournamentData = tournament.data();
    if (tournamentData.status === "finished") {
      const player = bet.get("player");
      const userId = bet.get("userId");
      const winners = tournamentData["winners"] || [];
      const user = firestore.collection(USER_COLLECTION).doc(userId);
      if (winners.indexOf(player) !== -1) {
        console.log("Winner");
        user.update({
          balance: admin.firestore.FieldValue.increment(bet.get("odds") * bet.get("value"))
        });
        bet.ref.update({
          "status": "won",
        });
      } else {
        console.log("Loser");
        bet.ref.update({
          "status": "lost",
        });
      }
    }
  });
};

exports.cleanBets = cleanBets;
exports.makeBet = makeBet;
