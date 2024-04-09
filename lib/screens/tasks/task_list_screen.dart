import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_managemet_app/screens/models/task_model.dart';
import 'package:task_managemet_app/screens/tasks/create_task.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList('Pending'),
          _buildTaskList('In Progress'),
          _buildTaskList('Completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskPage()),
          ).then((value) {
            if (value != null && value) {
              setState(() {});
            }
          });
        },
        tooltip: 'Create Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(String status) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Tasks')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No $status tasks found.'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          itemBuilder: (context, index) {
            final Task task = Task.fromMap(snapshot.data!.docs[index].id,
                snapshot.data!.docs[index].data() as Map<String, dynamic>);
            return Card(
              child: ListTile(
                title: Text(task.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${task.description}'),
                    Text('Status: ${task.status}'),
                    Text('Team: ${task.teamId}'),
                  ],
                ),
                onTap: () {
                  _showTaskDetailsDialog(context, task);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showTaskDetailsDialog(BuildContext context, Task task) async {
    String newStatus = task.status;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(task.name),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Description: ${task.description}'),
                  const SizedBox(height: 8),
                  Text('Team Name: ${task.teamId}'),
                  const SizedBox(height: 8),
                  const Text('Status:'),
                  DropdownButton<String>(
                    value: newStatus,
                    onChanged: (value) {
                      setState(() {
                        newStatus = value!;
                      });
                    },
                    items:
                        ['Pending', 'In Progress', 'Completed'].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _updateTaskStatus(task, newStatus);
                    Navigator.pop(context);
                  },
                  child: const Text('Update Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateTaskStatus(Task task, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tasks')
          .doc(task.id)
          .update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Task status updated successfully'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating task status: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
