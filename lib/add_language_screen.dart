import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_flags/country_flags.dart';

class AddLanguagesScreen extends StatefulWidget {
  final String userId;

  AddLanguagesScreen({required this.userId});

  @override
  _AddLanguagesScreenState createState() => _AddLanguagesScreenState();
}

class _AddLanguagesScreenState extends State<AddLanguagesScreen> {
  final List<String> availableLanguages = ['English', 'Spanish', 'Portuguese', 'French', 'German'];
  final Map<String, String> languageFlags = {
    'English': 'US',
    'Spanish': 'ES',
    'Portuguese': 'PT',
    'French': 'FR',
    'German': 'DE',
  };

  String? selectedFromLanguage;
  String? selectedToLanguage;
  List<Map<String, String>> selectedLanguages = [];

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
      List<Map<String, String>> languages = List<Map<String, String>>.from(data?['languages'] ?? []);
      setState(() {
        selectedLanguages = languages;
      });
    }
  }

  // Select language from available options
  void selectLanguage({required bool isFromLanguage}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: availableLanguages.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CountryFlag.fromCountryCode(
                languageFlags[availableLanguages[index]]!,
                width: 30,
                height: 20,
              ),
              title: Text(availableLanguages[index]),
              onTap: () {
                setState(() {
                  if (isFromLanguage) {
                    selectedFromLanguage = availableLanguages[index];
                  } else {
                    selectedToLanguage = availableLanguages[index];
                  }
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // Save selected languages and prevent duplicates
  void saveLanguages() async {
    if (selectedFromLanguage != null && selectedToLanguage != null) {
      // Check for duplicate language pairs
      if (selectedFromLanguage != selectedToLanguage &&
          !selectedLanguages.any((pair) =>
              pair['from_language'] == selectedFromLanguage &&
              pair['to_language'] == selectedToLanguage)) {

        final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
        selectedLanguages.add({
          'from_language': selectedFromLanguage!,
          'to_language': selectedToLanguage!,
        });

        await userRef.update({
          'languages': selectedLanguages, // Update Firestore with the new language pair
        });

        setState(() {
          selectedFromLanguage = null;
          selectedToLanguage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Languages saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This language pair already exists!')),
        );
      }
    }
  }

  // When a language combination is clicked, it updates the HomeScreen
  void _selectCombination(Map<String, String> pair) {
    Navigator.pop(context, pair);  // Pass the selected combination back to HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add More Languages')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display existing language pairs that the user has selected
            if (selectedLanguages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Selected Language Pairs:', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  for (var pair in selectedLanguages)
                    GestureDetector(
                      onTap: () => _selectCombination(pair), // On tap, pass the pair back
                      child: Row(
                        children: [
                          CountryFlag.fromCountryCode(
                            languageFlags[pair['from_language']]!,
                            width: 30,
                            height: 20,
                          ),
                          SizedBox(width: 8),
                          Text('${pair['from_language']} -> ${pair['to_language']}'),
                        ],
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),

            // Select 'from' language button
            ElevatedButton(
              onPressed: () => selectLanguage(isFromLanguage: true),
              child: Row(
                children: [
                  if (selectedFromLanguage != null)
                    CountryFlag.fromCountryCode(
                      languageFlags[selectedFromLanguage!]!,
                      width: 30,
                      height: 20,
                    ),
                  SizedBox(width: 8),
                  Text(selectedFromLanguage ?? 'Select From Language'),
                ],
              ),
            ),
            SizedBox(height: 10),
            
            // Select 'to' language button
            ElevatedButton(
              onPressed: () => selectLanguage(isFromLanguage: false),
              child: Row(
                children: [
                  if (selectedToLanguage != null)
                    CountryFlag.fromCountryCode(
                      languageFlags[selectedToLanguage!]!,
                      width: 30,
                      height: 20,
                    ),
                  SizedBox(width: 8),
                  Text(selectedToLanguage ?? 'Select To Language'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Save selected languages
            ElevatedButton(
              onPressed: saveLanguages,
              child: Text('Save Selected Languages'),
            ),
          ],
        ),
      ),
    );
  }
}
