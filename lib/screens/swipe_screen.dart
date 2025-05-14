import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  List<UserProfile> _leftSwipedProfiles = [];
  bool _reloadedLeftProfiles = false;
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
        _leftSwipedProfiles = profiles["leftSwipedProfiles"] ?? [];
        _isLoading = false;
        _errorOccurred = false;
        _currentIndex = 0;
        _reloadedLeftProfiles = false;
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

  Future<void> _resetSwipes() async {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) return;

  final swipeCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection('swipes');

  final leftSwipesSnapshot = await swipeCollection
      .where('liked', isEqualTo: false)
      .get();

  for (var doc in leftSwipesSnapshot.docs) {
    await doc.reference.delete();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Reloading profiles...")),
  );
  await _fetchProfiles();
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

      DocumentSnapshot targetUserSwipe = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('swipes')
          .doc(currentUserId)
          .get();

      if (targetUserSwipe.exists && targetUserSwipe['liked'] == true) {
        DocumentReference matchRef =
            await FirebaseFirestore.instance.collection('matches').add({
          'userIds': [currentUserId, targetUserId],
          'timestamp': FieldValue.serverTimestamp(),
        });

        String matchId = matchRef.id;
        print("Match ID created: $matchId");

        _showMatchDialog(swipedProfile.firstName);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You've liked ${swipedProfile.firstName}"),
      ));
    } else if (direction == DismissDirection.endToStart) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('swipes')
          .doc(targetUserId)
          .set({'liked': false});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You skipped ${swipedProfile.firstName}")),
      );
    }

    setState(() {
      _currentIndex++;
    });

    if (_currentIndex >= _profiles.length) {
      if (_leftSwipedProfiles.isNotEmpty && !_reloadedLeftProfiles) {
        setState(() {
          _profiles = _leftSwipedProfiles;
          _currentIndex = 0;
          _reloadedLeftProfiles = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No more new profiles. Showing skipped profiles.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No more profiles!")),
        );
      }
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
                const Icon(Icons.house, color: Colors.deepOrange, size: 80),
                const SizedBox(height: 16),
                const Text(
                  "Roommate Match!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "You and $name are interested in rooming together!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text(
                    "Awesome!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
      backgroundColor: Colors.orange[800],
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: const Text(
          "Swipe Profiles",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset Swipes",
            onPressed: _resetSwipes,
          ),
        ],
      ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${profile.firstName} ${profile.lastName}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  profile.university,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profile.major,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "View Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
