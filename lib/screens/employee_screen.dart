import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'search_screen.dart';
import 'update_screen.dart';
import 'auth_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final name = TextEditingController();
  final salary = TextEditingController();

  final CollectionReference employees =
      FirebaseFirestore.instance.collection('employees');

  Future<void> addEmployee() async {
    try {
      await employees.add({
        'name': name.text,
        'salary': double.tryParse(salary.text) ?? 0,
      });
      name.clear();
      salary.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add employee: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Character Manager")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Hero Name")),
            TextField(controller: salary, decoration: const InputDecoration(labelText: "Power Level")),
            ElevatedButton(onPressed: addEmployee, child: const Text("Add Character")),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                  child: const Text("Search"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateScreen())),
                  child: const Text("Update"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                  child: const Text("Auth"),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: employees.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView(
                    children: docs.map((doc) {
                      return ListTile(
                        title: Text(doc['name'], style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        subtitle: Text("Power Level: ${doc['salary']}", style: TextStyle(color: Colors.white70)),
                        tileColor: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red, width: 1),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
