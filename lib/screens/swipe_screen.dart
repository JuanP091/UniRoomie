import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniroomie/screens/profile_detail_screen.dart';
import 'package:uniroomie/services/user_profile.dart';

class ProfileSwipeScreen extends StatefulWidget {
  const ProfileSwipeScreen({super.key});

  @override
  State<ProfileSwipeScreen> createState() => _ProfileSwipeScreenState();
}

class _ProfileSwipeScreenState extends State<ProfileSwipeScreen>
    with SingleTickerProviderStateMixin {
  final UserProfileService _userProfileService = UserProfileService();
  List<UserProfile> _profiles = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _errorOccurred = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfiles() async {
    try {
      Map<String, dynamic> profiles = await _userProfileService.fetchProfiles();

      setState(() {
        _profiles = profiles["otherProfiles"];
        _isLoading = false;
        _errorOccurred = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorOccurred = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profiles: $e")),
      );
    }
  }

  void _handleSwipe(DismissDirection direction) async {
    if (_currentIndex >= _profiles.length) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final swipedProfile = _profiles[_currentIndex];
    final targetUserId = swipedProfile.uid;

    if (direction == DismissDirection.startToEnd) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('swipes')
          .doc(targetUserId)
          .set({'liked': true});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('swipes')
          .doc(currentUserId)
          .set({'liked': true});

      // Check if the other user also liked back (match)
      DocumentSnapshot targetUserSwipe = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('swipes')
          .doc(currentUserId)
          .get();

      if (targetUserSwipe.exists && targetUserSwipe['liked'] == true) {
        // **Add Match to Firestore**
        DocumentReference matchRef = await FirebaseFirestore.instance.collection('matches').add({
          'userIds': [currentUserId, targetUserId],
          'timestamp': FieldValue.serverTimestamp(),
        });

        String matchId = matchRef.id; // Capture the match document ID
        print("Match ID created: $matchId"); // For debugging or storing the match ID

        _showMatchDialog(swipedProfile.firstName);
      }
    } else if (direction == DismissDirection.endToStart) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You skipped ${swipedProfile.firstName}")),
      );
    }

    setState(() {
      _currentIndex++;
    });

    if (_currentIndex >= _profiles.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No more profiles!")),
      );
    }
  }

  void _showMatchDialog(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 80),
                const SizedBox(height: 10),
                Text(
                  "It's a Match!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text("You and $name liked each other!"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Yay!"),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Swipe Profiles")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorOccurred
              ? const Center(child: Text("Error loading profiles."))
              : _profiles.isEmpty
                  ? const Center(child: Text("No profiles available."))
                  : (_currentIndex >= _profiles.length)
                      ? const Center(child: Text("No more profiles!"))
                      : Stack(
                          children: [
                            Dismissible(
                              key: Key(_profiles[_currentIndex].uid),
                              direction: DismissDirection.horizontal,
                              onDismissed: _handleSwipe,
                              child: _buildProfileCard(
                                _profiles[_currentIndex],
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileDetailScreen(
                                          profile: _profiles[_currentIndex]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
    );
  }

  Widget _buildProfileCard(UserProfile profile, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${profile.firstName} ${profile.lastName}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(profile.university, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text(profile.major, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onTap,
                  child: const Text("View Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
