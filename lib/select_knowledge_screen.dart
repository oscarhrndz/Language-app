import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:language_app/home_screen.dart';

class SelectKnowledgeScreen extends StatefulWidget {
  @override
  _SelectKnowledgeScreenState createState() => _SelectKnowledgeScreenState();
}

class _SelectKnowledgeScreenState extends State<SelectKnowledgeScreen> {
  String? selectedKnowledge; // To hold the selected knowledge level
  final List<String> knowledgeLevels = ['Beginner', 'Basic', 'Advanced', 'Expert'];

  // Method to save the knowledge level to Firebase
  void saveKnowledgeLevel(BuildContext context) async {
    if (selectedKnowledge != null) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Save the knowledge level to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'knowledgeLevel': selectedKnowledge,
        }, SetOptions(merge: true)); // Merge to avoid overwriting other user data

        // Navigate to HomeScreen after saving
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: user.uid),
          ),
        );
      } else {
        // Handle the case where the user is not logged in
        print('User is not logged in');
      }
    } else {
      // Show an alert if no knowledge level is selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please select a knowledge level'),
            content: Text('You must select one of the options to continue.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Knowledge Level'),
        automaticallyImplyLeading: false, // Prevent back navigation to previous screen
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select your knowledge level:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Create cards for each knowledge level
            for (var knowledgeLevel in knowledgeLevels)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: selectedKnowledge == knowledgeLevel
                      ? Colors.blueAccent
                      : Colors.white,
                  elevation: 5,
                  child: ListTile(
                    title: Text(knowledgeLevel),
                    onTap: () {
                      setState(() {
                        selectedKnowledge = knowledgeLevel; // Update selected knowledge
                      });
                    },
                  ),
                ),
              ),
            SizedBox(height: 30),
            // Button to confirm the selection and save to Firestore
            ElevatedButton(
              onPressed: () => saveKnowledgeLevel(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Save and Go to Home',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
