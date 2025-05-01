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

class _ProfileSwipeScreenState extends State<ProfileSwipeScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  List<UserProfile> _profiles = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
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
      final swipeBackDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('swipes')
          .doc(currentUserId)
          .get();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('swipes')
          .doc(targetUserId)
          .set({'liked': true});

      if (swipeBackDoc.exists && swipeBackDoc.data()?['liked'] == true) {
        await FirebaseFirestore.instance.collection('matches').add({
          'user1': currentUserId,
          'user2': targetUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("It's a Match!"),
            content: Text("You and ${swipedProfile.firstName} liked each other!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Nice!"),
              )
            ],
          ),
        );
      }
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
                                      builder: (context) =>
                                          ProfileDetailScreen(profile: _profiles[_currentIndex]),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${profile.firstName} ${profile.lastName}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
