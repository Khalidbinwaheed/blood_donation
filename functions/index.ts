/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

admin.initializeApp();

// Scenario A: New Request Notification
export const sendNewRequestNotification = onDocumentCreated(
  "requests/{requestId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }

    const requestData = snapshot.data();
    const bloodGroupNeeded = requestData.bloodGroupNeeded;
    const hospitalName = requestData.hospitalName;

    // Query users with matching blood group
    const usersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("bloodGroup", "==", bloodGroupNeeded)
      .get();

    if (usersSnapshot.empty) {
      console.log("No matching donors found.");
      return;
    }

    const tokens: string[] = [];
    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("No tokens found.");
      return;
    }

    const payload = {
      notification: {
        title: "Urgent: Blood Needed!",
        body: `${bloodGroupNeeded} blood needed at ${hospitalName}. Please help!`,
      },
    };

    // Send notifications to all tokens
    // Note: sendMulticast is legacy but common. For v2, iterate or use batch.
    // Here using simple multicast for demonstration.
    await admin.messaging().sendEachForMulticast({
      tokens: tokens,
      notification: payload.notification,
    });

    console.log(`Sent notifications to ${tokens.length} users.`);
  }
);

// Scenario B: 24-Hour Warning
export const checkRequestDeadlines = onSchedule("every 1 hours", async (event) => {
  const now = admin.firestore.Timestamp.now();
  const twentyFourHoursLater = new Date(now.toMillis() + 24 * 60 * 60 * 1000);
  const twentyFiveHoursLater = new Date(now.toMillis() + 25 * 60 * 60 * 1000); // 1 hour window

  const startTimestamp = admin.firestore.Timestamp.fromDate(twentyFourHoursLater);
  const endTimestamp = admin.firestore.Timestamp.fromDate(twentyFiveHoursLater);

  const requestsSnapshot = await admin
    .firestore()
    .collection("requests")
    .where("status", "==", "Open")
    .where("deadline", ">=", startTimestamp)
    .where("deadline", "<=", endTimestamp)
    .get();

  if (requestsSnapshot.empty) {
    console.log("No requests expiring in 24 hours.");
    return;
  }

  const promises: Promise<any>[] = [];

  requestsSnapshot.forEach((doc) => {
    const requestData = doc.data();
    const bloodGroupNeeded = requestData.bloodGroupNeeded;

    const promise = admin
      .firestore()
      .collection("users")
      .where("bloodGroup", "==", bloodGroupNeeded)
      .get()
      .then(async (usersSnapshot) => {
        const tokens: string[] = [];
        usersSnapshot.forEach((userDoc) => {
          const userData = userDoc.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        });

        if (tokens.length > 0) {
          await admin.messaging().sendEachForMulticast({
            tokens: tokens,
            notification: {
              title: "High Priority Reminder",
              body: `Urgent: Only 24 hours left for a ${bloodGroupNeeded} request to save a life!`,
            },
          });
        }
      });
    promises.push(promise);
  });

  await Promise.all(promises);
  console.log("Checked deadlines and sent reminders.");
});
