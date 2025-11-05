import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void addEmployee() {
    employees.add({
      'name': name.text,
      'salary': double.tryParse(salary.text) ?? 0,
    });
    name.clear();
    salary.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee Manager")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: salary, decoration: const InputDecoration(labelText: "Salary")),
            ElevatedButton(onPressed: addEmployee, child: const Text("Add Employee")),
            Expanded(
              child: StreamBuilder(
                stream: employees.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView(
                    children: docs.map((doc) {
                      return ListTile(
                        title: Text(doc['name']),
                        subtitle: Text("Salary: ₹${doc['salary']}"),
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
