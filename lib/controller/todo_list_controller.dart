import 'package:get/get.dart';

import '../model/todo_model.dart';

class Todos extends GetxController {
  RxList<Todo> todos = <Todo>[
    Todo(id: '1', desc: 'Clean the room'),
    Todo(id: '2', desc: 'Do homework'),
    Todo(id: '3', desc: 'Wash the dish'),
  ].obs;

  static Todos get to => Get.find();

  void addTodo(String desc) {
    int? newNum;
    if (todos.isEmpty) {
      newNum = 1;
    } else {
      // 마지막 id 에서 1 증가
      newNum = int.parse(todos.last.id) + 1;
    }
    todos.add(Todo(id: newNum.toString(), desc: desc));
  }
}
