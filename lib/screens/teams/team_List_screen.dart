import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_managemet_app/screens/models/team_model.dart';
import 'package:task_managemet_app/screens/teams/creat_team_screen.dart';

class TeamListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team List'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateTeamPage()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Teams').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return _buildNoTeamsWidget(context);
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            itemBuilder: (context, index) {
              final team = Team.fromMap(
                  snapshot.data!.docs[index].data() as Map<String, dynamic>);
              return Dismissible(
                key: Key(snapshot.data!.docs[index].id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Delete team from Firestore
                  FirebaseFirestore.instance
                      .collection('Teams')
                      .doc(snapshot.data!.docs[index].id)
                      .delete();
                },
                child: Card(
                  child: ListTile(
                    title: Text(team.name),
                    subtitle: Text('Members: ${team.members.length}'),
                    onTap: () {},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNoTeamsWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No teams found. Please create a team.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateTeamPage()),
              );
            },
            child: const Text('Create Team'),
          ),
        ],
      ),
    );
  }
}
