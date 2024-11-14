import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_flags/country_flags.dart';
import 'package:language_app/add_language_screen.dart'; // Import the AddLanguagesScreen

class HomeScreen extends StatefulWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedFromLanguage;
  String? selectedToLanguage;

  @override
  void initState() {
    super.initState();
    _fetchSelectedLanguages();
  }

  // Fetch previously selected languages from Firestore
  void _fetchSelectedLanguages() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final data = userDoc.data();
      if (data?['languages'] != null && data?['languages'].isNotEmpty) {
        setState(() {
          selectedFromLanguage = data?['languages'][0]['from_language'];
          selectedToLanguage = data?['languages'][0]['to_language'];
        });
      }
    }
  }

  // Navigate to the AddLanguagesScreen to allow the user to add more language pairs
  void _navigateToAddLanguages() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLanguagesScreen(userId: widget.userId),
      ),
    );
  }

  // Update the HomeScreen with the selected combination from AddLanguagesScreen
  void _updateLanguageCombination(Map<String, String> selectedPair) {
    setState(() {
      selectedFromLanguage = selectedPair['from_language'];
      selectedToLanguage = selectedPair['to_language'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        automaticallyImplyLeading: false, // Prevent back navigation to login
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display selected language combination at the top
            if (selectedFromLanguage != null && selectedToLanguage != null)
              Row(
                children: [
                  CountryFlag.fromCountryCode(
                    'US', // Assuming US flag for the "from" language
                    width: 30,
                    height: 20,
                  ),
                  SizedBox(width: 8),
                  Text('$selectedFromLanguage -> $selectedToLanguage'),
                ],
              ),
            SizedBox(height: 20),

            // Button to navigate to AddLanguagesScreen
            ElevatedButton(
              onPressed: _navigateToAddLanguages,
              child: Text('Add More Languages'),
            ),
          ],
        ),
      ),
    );
  }
}
