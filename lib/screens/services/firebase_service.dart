import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
//add Employee
  Future<bool> addEmployeeDetails(
      Map<String, dynamic> employeeInfoMap, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('Employees')
          .doc(id)
          .set(employeeInfoMap);
      return true;
    } catch (e) {
      print("Error adding employee: $e");
      return false;
    }
  }

  // Function to create a new team in Firestore
  Future<bool> createTeam(
      Map<String, dynamic> teamInfoMap, String teamId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Teams')
          .doc(teamId)
          .set(teamInfoMap);
      return true;
    } catch (e) {
      print("Error creating team: $e");
      return false;
    }
  }

  // Function to add a member to a team
  Future<bool> addMemberToTeam(String teamId, String memberId) async {
    try {
      await FirebaseFirestore.instance.collection('Teams').doc(teamId).update({
        'members': FieldValue.arrayUnion([memberId]),
      });
      return true;
    } catch (e) {
      print("Error adding member to team: $e");
      return false;
    }
  }

  Future<bool> createTask(Map<String, dynamic> taskInfo) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').add(taskInfo);
      return true;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }
}
