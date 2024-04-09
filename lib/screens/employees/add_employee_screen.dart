import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../firebase_service.dart';

class AddEmployeeScreen extends StatelessWidget {
  const AddEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Add Employee',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const AddEmployeeForm(),
    );
  }
}

class AddEmployeeForm extends StatefulWidget {
  const AddEmployeeForm({super.key});

  @override
  _AddEmployeeFormState createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<AddEmployeeForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController positionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: positionController,
            decoration: const InputDecoration(
              labelText: 'Position',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _addEmployee(context);
            },
            child: const Text('Add Employee'),
          ),
        ],
      ),
    );
  }

  void _addEmployee(BuildContext context) async {
    String empId = randomAlphaNumeric(10);
    Map<String, dynamic> employeeInfoMap = {
      "id": empId,
      "Name": nameController.text,
      "position": positionController.text
    };

    bool success =
        await DatabaseMethods().addEmployeeDetails(employeeInfoMap, empId);

    if (success) {
      positionController.text = "";
      nameController.text = "";
      Fluttertoast.showToast(
        msg: "Employee added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: "Failed to add employee",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
