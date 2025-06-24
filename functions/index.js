
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendMenuNotification = functions.https.onCall(async (data, context) => {
  const message = {
    notification: {
      title: '📢 Mess Menu Uploaded!',
      body: 'Check out what’s cooking today!',
    },
    data: {
      type: 'menu_upload',
    },
    topic: 'allUsers', // Or use tokens if you want targeted delivery
  };

  try {
    await admin.messaging().send(message);
    return { success: true };
  } catch (error) {
    console.error('Error sending FCM:', error);
    throw new functions.https.HttpsError('internal', 'Notification failed');
  }
});