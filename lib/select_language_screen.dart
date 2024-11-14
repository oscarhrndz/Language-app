import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:language_app/select_knowledge_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectLanguageScreen extends StatefulWidget {
  @override
  _SelectLanguageScreenState createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  final List<String> languages = ['English', 'Spanish', 'Portuguese'];
  final Map<String, String> languageFlags = {
    'English': 'US', // Country code for English
    'Spanish': 'ES', // Country code for Spanish
    'Portuguese': 'PT', // Country code for Portuguese
  };

  String? selectedFromLanguage = null;
  String? selectedToLanguage = null;

  void selectLanguage({required bool isFromLanguage}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  leading: CountryFlag.fromCountryCode(
                    languageFlags[languages[index]]!,
                    width: 40, // Fixed width for the flag
                    height: 30, // Fixed height for the flag
                  ),
                  title: Text(languages[index]),
                  onTap: () {
                    setState(() {
                      if (isFromLanguage) {
                        selectedFromLanguage = languages[index];
                      } else {
                        selectedToLanguage = languages[index];
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
                Divider( // Thin gray line between the languages
                  thickness: 0.5,
                  color: Colors.grey, // Set the color to a consistent gray
                ),
              ],
            );
          },
        );
      },
    );
  }

  void saveSelectedLanguages() async {
    // Get the current user ID from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Reference to Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Save the selected languages to Firestore
      await firestore.collection('users').doc(user.uid).set({
        'from_language': selectedFromLanguage,
        'to_language': selectedToLanguage,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other user data

      print("Languages saved to Firestore");
    }
  }

  void navigateToSelectKnowledgeScreen() {
    saveSelectedLanguages(); // Save selected languages before navigating
    // Navigate to the SelectKnowledgeScreen when the button is pressed
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectKnowledgeScreen()), // Replace with your target screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Languages')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align widgets to the top
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
            children: [
              Text(
                'Select the language you speak:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => selectLanguage(isFromLanguage: true),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),  // More rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), // Smaller padding
                  maximumSize: Size(130, 55), // Smaller width while keeping height the same
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Display the flag of the selected language or placeholder
                    selectedFromLanguage != null
                        ? CountryFlag.fromCountryCode(
                            languageFlags[selectedFromLanguage!]!,
                            width: 30, height: 25,
                          ) // Consistent flag size
                        : Container(width: 30, height: 25), // Placeholder if no language selected
                    SizedBox(width: 6),
                    Text(
                      selectedFromLanguage ?? 'Select', // Default text is 'Select'
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Select the language you want to learn:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => selectLanguage(isFromLanguage: false),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),  // More rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), // Smaller padding
                  maximumSize: Size(130, 55), // Smaller width while keeping height the same
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Display the flag of the selected language or placeholder
                    selectedToLanguage != null
                        ? CountryFlag.fromCountryCode(
                            languageFlags[selectedToLanguage!]!,
                            width: 30, height: 25,
                          ) // Consistent flag size
                        : Container(width: 30, height: 25), // Placeholder if no language selected
                    SizedBox(width: 6),
                    Text(
                      selectedToLanguage ?? 'Select', // Default text is 'Select'
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40), // Space before the next button
              ElevatedButton(
                onPressed: selectedFromLanguage != null && selectedToLanguage != null
                    ? navigateToSelectKnowledgeScreen
                    : null, // Disable if languages aren't selected
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  minimumSize: Size(130, 45),
                ),
                child: Text(
                  'Go to Knowledge Screen',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
