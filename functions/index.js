/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();

// Firestoreのドキュメントにいいねが追加されるとトリガーされる関数
exports.updateLikeCount = functions.firestore
    .document("likes/{likeId}")
    .onCreate(async (snapshot, context) => {
      // いいねが追加されたドキュメントのIDを取得
      const likeId = context.params.likeId;

      // いいねが追加されたドキュメントのデータを取得
      const likeData = snapshot.data();

      // いいねが追加された対象のドキュメントを取得
      const documentRef = firestore.doc(`documents/${likeData.documentId}`);

      try {
        // いいねが追加された対象のドキュメントのカウントをインクリメント
        await documentRef.update({likeCount: admin.firestore.FieldValue.increment(1)});
        console.log("Like count updated successfully!");
      } catch (error) {
        console.error("Error updating like count:", error);
      }
    });