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

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.toggleFavorite = functions.firestore
  .document('favorites/{repositoryId}')
  .onCreate((snapshot, context) => {
    // いいねが追加されたドキュメントのデータを取得
    const favorite = snapshot.data();
    // いいねが追加されたドキュメントのIDを取得
    const repositoryId = context.params.repositoryId;

    // いいねの状態を取得
    const isFavorite = favorite.isFavorite;

    // Firestoreのレポジトリドキュメントを更新
    try {
        admin.firestore().collection('repositories').doc(repositoryId).update({
        isFavorite: isFavorite
    });
    console.log('update success!');
    } catch(error) {
        console.error("Error updating like count:", error);
    }
    // return admin.firestore().collection('repositories').doc(repositoryId).update({
    //   isFavorite: isFavorite
    // });
  });