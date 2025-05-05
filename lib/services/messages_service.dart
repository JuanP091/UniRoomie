import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send a message
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
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get messages for a match
  Stream<QuerySnapshot> getMessages(String matchId) {
    return FirebaseFirestore.instance
        .collection("messages")
        .where("matchId", isEqualTo: matchId)
        .orderBy("timestamp", descending: false)
        .snapshots()
        .handleError((error) {
      print("Firestore error: $error"); // Debugging Firestore issues
    });
  }

  // Check if messages exist for debugging
  Future<void> debugMessages(String matchId) async {
    var messages = await _firestore
        .collection("messages")
        .where("matchId", isEqualTo: matchId)
        .get();

    if (messages.docs.isEmpty) {
      print("No messages found for matchId: $matchId");
    } else {
      for (var msg in messages.docs) {
        print("Message: ${msg["message"]}, Sender: ${msg["senderId"]}");
      }
    }
  }
}
