import 'package:flutter/material.dart';
import 'package:uniroomie/services/user_profile.dart';

class ProfileDetailScreen extends StatelessWidget {
  final UserProfile profile;

  const ProfileDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${profile.firstName} ${profile.lastName}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("University: ${profile.university}", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Major: ${profile.major}", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Sleep Schedule: ${profile.sleepSchedule}", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Party or Study: ${profile.partyOrStudy}", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Gender: ${profile.gender}", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Hobbies:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: profile.hobbies
                  .map((hobby) => Chip(label: Text(hobby)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}