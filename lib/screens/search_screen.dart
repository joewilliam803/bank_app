import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];

  Future<void> searchCharacters(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      setState(() {
        searchResults = querySnapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Characters")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search by Hero Name",
                suffixIcon: Icon(Icons.search, color: Colors.red),
              ),
              onChanged: searchCharacters,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: searchResults.isEmpty && searchController.text.isEmpty
                  ? const Center(child: Text("Enter a name to search"))
                  : searchResults.isEmpty
                      ? const Center(child: Text("No characters found"))
                      : ListView(
                          children: searchResults.map((doc) {
                            return ListTile(
                              title: Text(doc['name'], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              subtitle: Text("Power Level: ${doc['salary']}", style: const TextStyle(color: Colors.white70)),
                              tileColor: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.red, width: 1),
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
