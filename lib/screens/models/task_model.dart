class Task {
  final String id;
  final String name;
  final String description;
  final String teamId;
  final String status;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.teamId,
    required this.status,
  });

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      name: map['name'],
      description: map['description'],
      teamId: map['teamId'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'teamId': teamId,
      'status': status,
    };
  }
}
