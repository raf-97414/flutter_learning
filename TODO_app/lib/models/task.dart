class Task {
  final int id;
  String title;
  String description;
  DateTime dueDate;
  bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.completed = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(
        json['dueDate'],
      ), // FIXED: Was 'datetime', should be 'dueDate'
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'completed': completed,
    };
  }
}
