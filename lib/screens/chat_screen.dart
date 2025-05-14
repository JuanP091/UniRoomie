import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uniroomie/services/messages_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart'; 
import 'package:uniroomie/screens/profile_detail_screen.dart';
import 'package:uniroomie/services/user_profile.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;

  const ChatScreen({super.key, required this.matchId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagesService _messagesService = MessagesService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _chatPartnerName = "Chat"; // Default title

  @override
  void initState() {
    super.initState();
    _fetchChatPartnerName(); // Fetch the name of the person being messaged
    _markMessagesAsRead(); // Mark messages as read when entering chat

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print(
            "📩 Foreground notification received: ${message.notification!.title} - ${message.notification!.body}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.body ?? "New message received"),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    });
  }

  Future<void> _fetchChatPartnerName() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    var matchDoc =
        await _firestore.collection("matches").doc(widget.matchId).get();
    if (!matchDoc.exists) return;

    var matchData = matchDoc.data() as Map<String, dynamic>;
    List<dynamic> userIds = matchData["userIds"] ?? [];

    // Find the other user's ID
    String chatPartnerId =
        userIds.firstWhere((id) => id != currentUser.uid, orElse: () => "");

    if (chatPartnerId.isNotEmpty) {
      var userDoc =
          await _firestore.collection("users").doc(chatPartnerId).get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _chatPartnerName =
              "${userData["First Name"]} ${userData["Last Name"]}";
        });
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    var notificationsSnapshot = await _firestore
        .collection("notifications")
        .where("recipientId", isEqualTo: user.uid)
        .where("isRead", isEqualTo: false)
        .get();

    for (var doc in notificationsSnapshot.docs) {
      await _firestore.collection("notifications").doc(doc.id).update({
        "isRead": true,
      });
      print("Marked notification as read: ${doc.id}");
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await _messagesService.sendMessage(widget.matchId, _messageController.text);
    _messageController.clear();

    setState(() {});

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[800], // Match background color
      appBar: AppBar(
        backgroundColor: Colors.orange[900], // Darker shade of orange
        elevation: 0,
        title: Text(
          _chatPartnerName, // Display the name of the person being messaged
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              User? currentUser = _auth.currentUser;
              if (currentUser == null) return;

              var matchDoc = await _firestore.collection("matches").doc(widget.matchId).get();
              if (!matchDoc.exists) return;

              var matchData = matchDoc.data() as Map<String, dynamic>;
              List<dynamic> userIds = matchData["userIds"] ?? [];
              String chatPartnerId = userIds.firstWhere((id) => id != currentUser.uid, orElse: () => "");

              if (chatPartnerId.isNotEmpty) {
                var userDoc = await _firestore.collection("users").doc(chatPartnerId).get();
                if (userDoc.exists) {
                  var userData = userDoc.data() as Map<String, dynamic>;
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileDetailScreen(
                        profile: UserProfile.fromDocument(chatPartnerId, userData),
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text(
              "View Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesService.getMessages(widget.matchId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      "Loading messages...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMine = message["senderId"] ==
                        FirebaseAuth.instance.currentUser!.uid;

                    //Extracts timestamp and format it
                    Timestamp? timestamp = message["timestamp"] as Timestamp?;
                    String formattedTime = timestamp != null
                        ? DateFormat('hh:mm a').format(timestamp.toDate())
                        : "Just now";

                    return Align(
                      alignment:
                          isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color:
                              Colors.blue[400], // Same shade for all messages
                          borderRadius: BorderRadius.only(
                            topLeft: isMine
                                ? const Radius.circular(20)
                                : Radius.zero,
                            topRight: isMine
                                ? Radius.zero
                                : const Radius.circular(20),
                            bottomLeft: const Radius.circular(20),
                            bottomRight: const Radius.circular(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message["message"],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              formattedTime, // Display timestamp
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[400],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
