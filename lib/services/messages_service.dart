import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:uniroomie/services/notification_service.dart';

class MessagesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Send a message and trigger notification
  Future<void> sendMessage(String matchId, String message) async {
    if (message.trim().isEmpty) return;

    try {
      String userId = _auth.currentUser!.uid;

      await _firestore.collection("messages").add({
        "matchId": matchId,
        "senderId": userId,
        "message": message,
        "timestamp": FieldValue.serverTimestamp(),
      });

      // Fetch recipient info
      var matchSnapshot =
          await _firestore.collection("matches").doc(matchId).get();
      if (matchSnapshot.exists) {
        var matchData = matchSnapshot.data();
        if (matchData != null) {
          List<dynamic> userIds = matchData["userIds"];
          String recipientId = userIds.firstWhere((id) => id != userId);

          var recipientSnapshot =
              await _firestore.collection("users").doc(recipientId).get();
          if (recipientSnapshot.exists) {
            var recipientData = recipientSnapshot.data();
            String? recipientToken = recipientData?["fcmToken"];

            // **Send push notification directly**
            if (recipientToken != null) {
              await _notificationService.sendPushNotification(
                recipientToken,
                "New Message",
                message,
              );
            }

            // **Store notification in Firestore for queuing**
            await _notificationService.storeNotification(
              recipientId,
              "New Message",
              message,
            );
          }
        }
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get messages for a match
  Stream<QuerySnapshot> getMessages(String matchId) {
    return _firestore
        .collection("messages")
        .where("matchId", isEqualTo: matchId)
        .orderBy("timestamp", descending: false)
        .snapshots()
        .handleError((error) {
      print("Firestore error: $error");
    });
  }
}
