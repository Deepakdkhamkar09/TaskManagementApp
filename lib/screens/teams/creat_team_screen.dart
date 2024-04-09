import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_managemet_app/screens/employees/add_employee_screen.dart';
import 'package:task_managemet_app/screens/firebase_service.dart';
import 'package:task_managemet_app/screens/models/team_model.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  _CreateTeamPageState createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  final TextEditingController _teamNameController = TextEditingController();
  final List<String> _selectedMembers = []; // List to store selected member IDs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Team'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Employees')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No team members available'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final employee = snapshot.data?.docs[index].data()
                          as Map<String, dynamic>;
                      final employeeId = snapshot.data?.docs[index].id;
                      return Card(
                        child: ListTile(
                          title: Text(employee['Name']),
                          onTap: () {
                            setState(() {
                              if (_selectedMembers.contains(employeeId)) {
                                _selectedMembers.remove(employeeId);
                              } else {
                                _selectedMembers.add(employeeId!);
                              }
                            });
                          },
                          trailing: _selectedMembers.contains(employeeId)
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _createTeam();
            },
            child: const Text('Create Team'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTeam() async {
    if (_teamNameController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a team name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
      );
      return;
    }

    // Create team object
    final Team team = Team(
      id: UniqueKey().toString(), // Generate unique team ID
      name: _teamNameController.text,
      members: _selectedMembers,
    );

    // Add team to Firestore
    final bool success =
        await _databaseMethods.createTeam(team.toMap(), team.id);
    if (success) {
      Fluttertoast.showToast(
        msg: "Team created successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: "Failed to create team",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
