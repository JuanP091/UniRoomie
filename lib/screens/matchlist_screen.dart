import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uniroomie/screens/chat_screen.dart'; // Import ChatScreen

class MatchesListScreen extends StatelessWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Matches")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection("matches")
            .where("userIds", arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var matches = snapshot.data!.docs;

          if (matches.isEmpty) {
            return const Center(child: Text("No matches yet!"));
          }

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              var matchData = matches[index].data() as Map<String, dynamic>;
              String matchedUserId =
                  matchData["userIds"].firstWhere((id) => id != userId);
              String matchId = matches[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: firestore.collection("users").doc(matchedUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox();
                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(userData["profilePicture"] ?? ""),
                    ),
                    title: Text(
                        "${userData["First Name"]} ${userData["Last Name"]}"),
                    subtitle: Text("Tap to start chatting"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(matchId: matchId)),
                      );
                    },
                    onLongPress: () => _removeMatch(context, firestore,
                        matchId), // Long press to remove match
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Function to remove match
  void _removeMatch(
      BuildContext context, FirebaseFirestore firestore, String matchId) async {
    bool confirmDelete = await _showDeleteConfirmation(context);
    if (confirmDelete) {
      await firestore.collection("matches").doc(matchId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Match removed successfully")),
      );
    }
  }

  // Show confirmation dialog before deleting
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Remove Match"),
            content: const Text("Are you sure you want to remove this match?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Remove"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
