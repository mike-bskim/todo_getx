import 'package:get/get.dart';
import '../controller/todo_focus_controller.dart';
import '../controller/todo_list_controller.dart';

class TodoBinding extends Bindings {
  @override
  void dependencies() {
    // dependency injection
    Get.put<TodosList>(TodosList());
    Get.put<TodosFilter>(TodosFilter());
    Get.put<TodosSearch>(TodosSearch());
    // 상기 3개의 controller 는 ActiveCount/FilteredTodos 에 영향을 주기때문에
    // ActiveCount/FilteredTodos 보다 위에/먼저 선언되어야 한다
    Get.put<ActiveCount>(ActiveCount());
    Get.put<FilteredTodos>(FilteredTodos());
    // put 으로 injection 하면 편집시 모든 텍스트가 변경된다. 그래서 create 로 해야 함
    Get.create<TodoFocusController>(() => TodoFocusController());
  }
}
