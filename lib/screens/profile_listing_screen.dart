import 'package:flutter/material.dart';
import 'package:uniroomie/screens/profile_detail_screen.dart';
import 'package:uniroomie/services/user_profile.dart';

class ProfileListingScreen extends StatefulWidget {
  const ProfileListingScreen({super.key});

  @override
  State<ProfileListingScreen> createState() => _ProfileListingScreenState();
}

class _ProfileListingScreenState extends State<ProfileListingScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  UserProfile? _currentUserProfile;
  List<UserProfile> _otherProfiles = [];
  bool _isLoading = true;
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    try {
      // Fetch profile from user_profiles services
      Map<String, dynamic> profiles = await _userProfileService.fetchProfiles();

      setState(() {
        _currentUserProfile = profiles["currentUserProfile"];
        _otherProfiles = profiles["otherProfiles"];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Roommates")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorOccurred
              ? const Center(
                  child: Text("Error loading profiles. Try again later."))
              : ListView(
                  children: [
                    if (_currentUserProfile != null)...[
                      Card(
                        color: Colors.blue.shade100,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                              "${_currentUserProfile!.firstName} ${_currentUserProfile!.lastName} (You)"),
                          subtitle: Text(_currentUserProfile!.university),
                          trailing: Text(_currentUserProfile!.major),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileDetailScreen(
                                    profile: _currentUserProfile!),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                    ],
                    // Display other users
                    if (_otherProfiles.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No other users found."),
                        ),
                      )
                    else
                      ..._otherProfiles.map((profile) {
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                                "${profile.firstName} ${profile.lastName}"),
                            subtitle: Text(profile.university),
                            trailing: Text(profile.major),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileDetailScreen(profile: profile),
                                ),
                              );
                            },
                          ),
                        );
                      })
                  ],
                ),
    );
  }
}
