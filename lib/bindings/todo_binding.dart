import 'package:get/get.dart';

import '../controller/todo_list_controller.dart';

class TodoBinding extends Bindings {
  @override
  void dependencies() {
    // dependency injection
    Get.put<TodoList>(TodoList());
  }
}
