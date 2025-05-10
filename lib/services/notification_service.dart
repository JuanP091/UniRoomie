import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendPushNotification(
      String recipientToken, String title, String body) async {
    try {
      await _firebaseMessaging.sendMessage(
        to: recipientToken,
        data: {
          "title": title,
          "body": body,
        },
      );
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  Future<void> storeNotification(
      String recipientId, String title, String body) async {
    await _firestore.collection("notifications").add({
      "recipientId": recipientId,
      "title": title,
      "body": body,
      "timestamp": FieldValue.serverTimestamp(),
      "isRead": false, // Mark as unread
    });
  }

  void startListeningForAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print("🚨 No user logged in, skipping notification check.");
        return;
      }

      print("🔍 User logged in: ${user.uid}, checking notifications...");
      checkQueuedNotifications(user);
    });
  }

  Future<void> checkQueuedNotifications(User user) async {
    var notificationsSnapshot = await _firestore
        .collection("notifications")
        .where("recipientId", isEqualTo: user.uid)
        .where("isRead", isEqualTo: false)
        .get();

    if (notificationsSnapshot.docs.isEmpty) {
      print("No unread notifications found.");//debiging
      return;
    }

    for (var doc in notificationsSnapshot.docs) {
      var data = doc.data();
      print(
          "📩 Sending queued notification: ${data["title"]} - ${data["body"]}");

      String? recipientToken = await _firebaseMessaging.getToken();
      if (recipientToken != null) {
        await sendPushNotification(recipientToken, data["title"], data["body"]);
        print("Notification sent successfully!");//debuging
      } else {
        print("🚨 Failed to get FCM token for user.");
      }
    }
  }
}