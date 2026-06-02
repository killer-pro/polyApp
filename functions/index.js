const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * Callable Cloud Function — remplace l'appel FCM direct depuis le client.
 * Appelée via cloud_functions Flutter : FirebaseFunctions.instance.httpsCallable('sendNotification')
 *
 * Payload attendu : { title: string, body: string }
 */
exports.sendNotification = onCall({ region: "europe-west1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const { title, body } = request.data;
  if (!title || !body) {
    throw new HttpsError("invalid-argument", "title et body sont requis.");
  }

  const db = getFirestore();
  const tokensSnapshot = await db
    .collection("TOKEN")
    .where("active", "==", true)
    .get();

  if (tokensSnapshot.empty) {
    return { sent: 0, failed: 0 };
  }

  const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);

  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
  });

  return {
    sent: response.successCount,
    failed: response.failureCount,
  };
});
