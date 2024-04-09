import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_managemet_app/screens/models/task_model.dart';
import 'package:task_managemet_app/screens/models/team_model.dart';
import 'package:task_managemet_app/screens/tasks/task_list_screen.dart';
import 'package:task_managemet_app/screens/teams/creat_team_screen.dart';

class CreateTaskPage extends StatefulWidget {
  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); // Controller for description text field
  final TextEditingController _teamNameController = TextEditingController();
  String _selectedStatus = 'Pending';
  List<String> _teamOptions = [
    'Create New Team'
  ]; // Initialize team options with option to create new team
  String? _selectedTeam;

  @override
  void initState() {
    super.initState();
    // Fetch available teams from Firestore
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Teams').get();
      final Set<String> teams =
          snapshot.docs.map((doc) => doc['name'] as String).toSet();
      setState(() {
        _teamOptions.addAll(teams);
      });
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _taskNameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                // Add TextField for task description
                controller: _descriptionController,
                maxLines: 3, // Allow multiple lines for description
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedTeam,
                onChanged: (value) {
                  setState(() {
                    _selectedTeam = value;
                  });
                  if (value == 'Create New Team') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateTeamPage()),
                    ).then((result) {
                      setState(() {
                        _fetchTeams();
                      });
                    });
                  }
                },
                items: _teamOptions.map((team) {
                  return DropdownMenuItem<String>(
                    value: team,
                    child: Text(team),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Team',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                items: ['Pending', 'In Progress', 'Completed'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _createTask();
                },
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    try {
      final String taskName = _taskNameController.text;
      if (taskName.isEmpty) {
        Fluttertoast.showToast(msg: 'Please enter a task name');
        return;
      }

      String selectedTeam;
      if (_selectedTeam == 'Create New Team') {
        final String teamName = _teamNameController.text;
        if (teamName.isEmpty) {
          Fluttertoast.showToast(msg: 'Please enter a team name');
          return;
        }
        selectedTeam = await _createNewTeam(teamName);
      } else {
        selectedTeam = _selectedTeam!;
      }
      print("selectedTeam --$selectedTeam");
      final Task task = Task(
        id: '', // Leave id empty for Firestore to generate
        name: taskName,
        description: _descriptionController.text, // Add task description
        teamId: selectedTeam,
        status: _selectedStatus,
      );

      // Save task to Firestore
      await FirebaseFirestore.instance.collection('Tasks').add(task.toMap());

      // Show success message
      Fluttertoast.showToast(msg: 'Task created successfully');

      // Navigate to previous screen
      Navigator.pop(context);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => TaskListPage()),
      // );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating task: $e');
    }
  }

  Future<String> _createNewTeam(String teamName) async {
    try {
      final Team newTeam = Team(id: '', name: teamName, members: []);
      final DocumentReference teamRef = await FirebaseFirestore.instance
          .collection('Teams')
          .add(newTeam.toMap());
      Fluttertoast.showToast(msg: 'New team created: $teamName');
      return teamRef.id;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating new team: $e');
      return '';
    }
  }
}
