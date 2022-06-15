import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/todo_model.dart';

class TodosFilter extends GetxController {
  Rx<Filter> todosFilter = Filter.all.obs;

  static TodosFilter get to => Get.find();
}

class TodosSearch extends GetxController {
  RxString searchWord = ''.obs;

  static TodosSearch get to => Get.find();
}

// 클래스명 변경함 TodoList => TodosList
class TodosList extends GetxController {
  // 샘플 데이터 생성
  RxList<Todo> todos = <Todo>[
    Todo(id: '1', desc: 'Clean the room', completed: true),
    Todo(id: '2', desc: 'Do homework'),
    Todo(id: '3', desc: 'Wash the dish'),
  ].obs;

  static TodosList get to => Get.find();

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

  void deleteTodo({required String id}) {
    todos.assignAll(todos.where((t) => t.id != id).toList());
  }

  void toggleTodo({required String id}) {
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

  void editTodo({required String id, required String desc}) {
    todos.assignAll(todos.map((todo) {
      return todo.id == id
          ? Todo(
              id: id,
              desc: desc,
              completed: todo.completed,
            )
          : todo;
    }).toList());
  }
}

class ActiveCount extends GetxController {
  final todos = TodosList.to.todos;
  RxInt activeCount = 0.obs;

  static ActiveCount get to => Get.find();

  @override
  void onInit() {
    activeCount.value = todos.where((todo) => !todo.completed).toList().length;
    ever(todos, (_) {
      activeCount.value =
          todos.where((todo) => !todo.completed).toList().length;
      debugPrint('active count: ${activeCount.value}');
    });
    super.onInit();
  }
}

class FilteredTodos extends GetxController {
  final todos = TodosList.to.todos;
  final filter = TodosFilter.to.todosFilter;
  final search = TodosSearch.to.searchWord;

  RxList<Todo> filteredTodos = <Todo>[].obs;

  static FilteredTodos get to => Get.find();

  @override
  void onInit() {
    // 초기에 화면에 표시할 리스트를 filteredTodos 에 할당.
    filteredTodos.assignAll(todos);

    everAll([todos, search, filter], (_) {
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

      if (search.value.isNotEmpty) {
        tempTodos =
            tempTodos.where((t) => t.desc.toLowerCase().contains(search.value)).toList();
      }

      filteredTodos.assignAll(tempTodos);
    });

    super.onInit();
  }
}
