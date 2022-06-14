import 'package:get/get.dart';

import '../model/todo_model.dart';

class TodoList extends GetxController {
  // 샘플 데이터 생성
  RxList<Todo> todos = <Todo>[
    Todo(id: '1', desc: 'Clean the room', completed: true),
    Todo(id: '2', desc: 'Do homework'),
    Todo(id: '3', desc: 'Wash the dish'),
  ].obs;

  static TodoList get to => Get.find();

  void addTodo({required String todoDesc}) {
    int? newNum;
    if (todos.isEmpty) {
      newNum = 1;
    } else {
      // 마지막 id 에서 1 증가
      newNum = int.parse(todos.last.id) + 1;
    }
    todos.add(Todo(id: newNum.toString(), desc: todoDesc));
  }

  void toggleTodo(String id) {
    todos.assignAll(todos.map((todo) {
      return todo.id == id
          ? Todo(
              id: id,
              desc: todo.desc,
              completed: !todo.completed,
            )
          : todo;
    }).toList());
  }
}

class TodosFilter extends GetxController {
  Rx<Filter> todosFilter = Filter.all.obs;

  static TodosFilter get to => Get.find();
}

class FilteredTodos extends GetxController {
  final todos = TodoList.to.todos;
  final filter = TodosFilter.to.todosFilter;

  // final search = TodosSearch.to.searchTerm;

  RxList<Todo> filteredTodos = <Todo>[].obs;

  static FilteredTodos get to => Get.find();

  @override
  void onInit() {
    filteredTodos.assignAll(todos);

    everAll([todos, filter], (_) {
      // everAll([todos, search, filter], (_) {
      List<Todo> tempTodos;

      switch (filter.value) {
        case Filter.active:
          tempTodos = todos.where((todo) => !todo.completed).toList();
          break;
        case Filter.completed:
          tempTodos = todos.where((todo) => todo.completed).toList();
          break;
        case Filter.all:
        default:
          tempTodos = todos.toList();
          break;
      }

      // if (search.value.isNotEmpty) {
      //   tempTodos =
      //       tempTodos.where((t) => t.text.contains(search.value)).toList();
      // }

      filteredTodos.assignAll(tempTodos);
    });

    super.onInit();
  }
}
