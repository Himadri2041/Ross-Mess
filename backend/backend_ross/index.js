const express = require("express");
const admin = require("firebase-admin");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
app.post("/notify-menu-upload", async (req, res) => {
  const { day = "today" } = req.body;

  try {
    const snapshot = await admin.firestore().collection("users").get();
    const tokens = snapshot.docs.map(doc => doc.data()?.fcmToken).filter(Boolean);

    if (tokens.length === 0) {
      return res.status(404).json({ message: "No user tokens found" });
    }

    let successCount = 0;
    for (const token of tokens) {
      const message = {
        notification: {
          title: "🍛 New Mess Menu Uploaded!",
          body: `Check out the delicious options for ${day}!`,
        },
        token,
      };

      try {
        await admin.messaging().send(message);
        successCount++;
      } catch (err) {
        console.warn("Failed to send to token:", token, err.message);
      }
    }

    console.log(`📨 Menu notification sent to ${successCount} users`);
    res.json({ success: true, sent: successCount });
  } catch (error) {
    console.error("Menu upload notification failed:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post("/notify-order-placed", async (req, res) => {
  const { userName = "Someone" } = req.body;

  try {
    const adminSnap = await admin
      .firestore()
      .collection("users")
      .where("isAdmin", "==", true)
      .get();

    const tokens = adminSnap.docs.map(doc => doc.data()?.fcmToken).filter(Boolean);

    if (tokens.length === 0) {
      return res.status(404).json({ message: "No admin tokens found" });
    }

    let successCount = 0;
    for (const token of tokens) {
      const message = {
        notification: {
          title: "📦 New Order Alert!",
          body: `${userName} just placed a food order!`,
        },
        token,
      };

      try {
        await admin.messaging().send(message);
        successCount++;
      } catch (err) {
        console.warn("Failed to send to admin token:", token, err.message);
      }
    }

    console.log(`📨 Order alert sent to ${successCount} admins`);
    res.json({ success: true, sent: successCount });
  } catch (error) {
    console.error("Order placed notification failed:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post("/notify-order-ready", async (req, res) => {
  const { userId, name = "User" } = req.body;

  try {
    const userDoc = await admin.firestore().collection("users").doc(userId).get();
    const token = userDoc.data()?.fcmToken;

    if (!token) {
      return res.status(404).json({ message: "User token not found" });
    }

    const message = {
      notification: {
        title: "✅ Your Order is Ready!",
        body: `${name}, come pick it up while it’s hot 🔥`,
      },
      token,
    };

    const response = await admin.messaging().send(message);
    console.log(`📨 Order ready notification sent to ${name}`);
    res.json({ success: true, response });
  } catch (error) {
    console.error("Order ready notification failed:", error);
    res.status(500).json({ error: error.message });
  }
});
app.post("/notify-new-item", async (req, res) => {
  const { itemTitle = "A new item" } = req.body;

  try {v
    const snapshot = await admin.firestore().collection("users").get();
    const tokens = snapshot.docs.map(doc => doc.data()?.fcmToken).filter(Boolean);

    if (tokens.length === 0) {
      return res.status(404).json({ message: "No user tokens found" });
    }

    let successCount = 0;
    for (const token of tokens) {
      const message = {
        notification: {
          title: "🆕 New Arrival in the Mess!",
          body: `${itemTitle} just hit the menu. Go grab it now!`,
        },
        token,
      };

      try {
        await admin.messaging().send(message);
        successCount++;
      } catch (err) {
        console.warn("Failed to send to token:", token, err.message);
      }
    }

    console.log(`📨 New item notification sent to ${successCount} users`);
    res.json({ success: true, sent: successCount });
  } catch (error) {
    console.error("New item notification failed:", error);
    res.status(500).json({ error: error.message });
  }
});
app.post("/notify-attendance-marked", async (req, res) => {
  const { rollNo = "", meal = "Meal" } = req.body;

  if (!rollNo) {
    return res.status(400).json({ message: "rollno is required" });
  }

  try {
    
    const userSnap = await admin
      .firestore()
      .collection("users")
      .where("rollNo", "==", rollNo)
      .limit(1)
      .get();

    if (userSnap.empty) {
      return res.status(404).json({ message: "User with this roll number not found" });
    }

    const userDoc = userSnap.docs[0];
    const userData = userDoc.data();
    const token = userData?.fcmToken;
    const name = userData?.name || "User";

    if (!token) {
      return res.status(404).json({ message: "FCM token not found for this user" });
    }

    const message = {
      notification: {
        title: "✅ Attendance Marked!",
        body: `Hey ${name}, your attendance for ${meal} has been marked successfully. Enjoy! 🍽️`,
      },
      token,
    };

    const response = await admin.messaging().send(message);
    console.log(`📨 Attendance notification sent to ${name} (roll: ${rollNo})`);
    res.json({ success: true, response });
  } catch (error) {
    console.error("Attendance notification failed:", error);
    res.status(500).json({ error: error.message });
  }
});

app.post("/notify-custom-message", async (req, res) => {
  const { title = "Notification", body = "Hello from Admin!" } = req.body;

  try {
    
    const snapshot = await admin.firestore().collection("users").get();
    const tokens = snapshot.docs.map(doc => doc.data()?.fcmToken).filter(Boolean);

    if (tokens.length === 0) {
      return res.status(404).json({ message: "No user tokens found" });
    }

    let successCount = 0;
    for (const token of tokens) {
      const message = {
        notification: {
          title,
          body,
        },
        token,
      };

      try {
        await admin.messaging().send(message);
        successCount++;
      } catch (err) {
        console.warn("Failed to send to token:", token, err.message);
      }
    }

    console.log(`📨 Custom message sent to ${successCount} users`);
    res.json({ success: true, sent: successCount });
  } catch (error) {
    console.error("Custom notification failed:", error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT} and accepting all network requests`);
});
