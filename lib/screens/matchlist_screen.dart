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
      backgroundColor: Colors.orange[800], // Match background color
      appBar: AppBar(
        backgroundColor: Colors.orange[800], // Consistent with LoginScreen
        elevation: 0,
        title: const Text(
          "Your Matches",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
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
              return const Center(
                child: Text(
                  "No matches yet!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                var matchData = matches[index].data() as Map<String, dynamic>;
                String matchedUserId =
                    matchData["userIds"].firstWhere((id) => id != userId);
                String matchId = matches[index].id;

                return FutureBuilder<DocumentSnapshot>(
                  future:
                      firestore.collection("users").doc(matchedUserId).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox();
                    var userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green[900], // Dark green background
                        border: Border.all(
                          color:
                              const Color.fromARGB(255, 9, 36, 142), // border
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              Colors.white, // Adds contrast
                          backgroundImage: AssetImage("assets/images/logo.png"),
                        ),
                        title: Text(
                          "${userData["First Name"]} ${userData["Last Name"]}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Visible text color
                          ),
                        ),
                        subtitle: const Text(
                          "Tap to start chatting",
                          style: TextStyle(
                              color: Colors.white), // Visible subtitle
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _removeMatch(context, firestore, matchId),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen(matchId: matchId)),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
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

