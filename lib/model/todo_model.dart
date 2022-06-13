import 'package:uuid/uuid.dart';

Uuid uuid = const Uuid();

class Todo {
  final String id;
  final String desc;
  final bool completed;

  Todo({
    String? id,
    required this.desc,
    this.completed = false,
  }) : id = id ?? uuid.v4();

  @override
  String toString() {
    return 'Todo(id: $id, desc: $desc, completed: $completed)';
  }
}