import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final nameController = TextEditingController();
  final salaryController = TextEditingController();
  final searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];
  QueryDocumentSnapshot? selectedCharacter;

  Future<void> searchCharacters(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        selectedCharacter = null;
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
        selectedCharacter = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  void selectCharacter(QueryDocumentSnapshot doc) {
    setState(() {
      selectedCharacter = doc;
      nameController.text = doc['name'];
      salaryController.text = doc['salary'].toString();
      searchResults = [];
    });
  }

  Future<void> updateCharacter() async {
    if (selectedCharacter == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(selectedCharacter!.id)
          .update({
            'name': nameController.text,
            'salary': double.tryParse(salaryController.text) ?? 0,
          });

      setState(() {
        selectedCharacter = null;
        nameController.clear();
        salaryController.clear();
        searchController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Character updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Characters")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search Hero Name to Update",
                suffixIcon: Icon(Icons.search, color: Colors.red),
              ),
              onChanged: searchCharacters,
            ),
            const SizedBox(height: 10),
            if (searchResults.isNotEmpty)
              Expanded(
                flex: 1,
                child: ListView(
                  children: searchResults.map((doc) {
                    return ListTile(
                      title: Text(doc['name'], style: const TextStyle(color: Colors.red)),
                      subtitle: Text("Power Level: ${doc['salary']}", style: const TextStyle(color: Colors.white70)),
                      onTap: () => selectCharacter(doc),
                      tileColor: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.red, width: 1),
                      ),
                    );
                  }).toList(),
                ),
              )
            else if (selectedCharacter != null)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Hero Name"),
                    ),
                    TextField(
                      controller: salaryController,
                      decoration: const InputDecoration(labelText: "Power Level"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateCharacter,
                      child: const Text("Update Character"),
                    ),
                  ],
                ),
              )
            else
              const Expanded(
                child: Center(child: Text("Search and select a character to update")),
              ),
          ],
        ),
      ),
    );
  }
}
